# Authentication Documentation

> **Document Version:** 1.0.0
> **Last Updated:** November 2024

## Overview

IGE Hospital uses JWT-based token authentication with automatic refresh and session timeout management. The authentication system is implemented in `AuthService` and integrates with the HTTP client for seamless request authentication.

---

## Authentication Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        AUTHENTICATION FLOW                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────┐    ┌──────────────┐    ┌─────────────────────┐   │
│  │  LoginPage  │───▶│ AuthController│───▶│    AuthService      │   │
│  │  (UI Form)  │    │ (Validation) │    │    (API + Storage)  │   │
│  └─────────────┘    └──────────────┘    └──────────┬──────────┘   │
│                                                     │              │
│                                         ┌───────────┴───────────┐  │
│                                         │                       │  │
│                                         ▼                       ▼  │
│                              ┌─────────────────┐    ┌───────────┐  │
│                              │  SharedPrefs    │    │  REST API │  │
│                              │  (Token Store)  │    │  /login   │  │
│                              └─────────────────┘    └───────────┘  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Key Components

### 1. AuthService (`lib/provider/auth_service.dart`)

The core authentication service managing:
- Login/logout operations
- Token storage and validation
- User session management
- Automatic token refresh

```dart
class AuthService extends GetxController implements GetxService {
  // Reactive state
  final RxBool isAuthenticated = false.obs;
  final RxString token = ''.obs;
  final RxString tokenExpiration = ''.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isRefreshing = false.obs;

  // SharedPreferences keys
  static const String _tokenKey = 'auth_token';
  static const String _tokenExpirationKey = 'token_expiration';
  static const String _userKey = 'user_data';

  // Initialization
  Future<AuthService> init() async {
    await loadToken();
    await loadUser();
    return this;
  }
}
```

### 2. AuthController (`lib/controllers/auth_controller.dart`)

UI controller for login form and user state display.

```dart
class AuthController extends GetxController {
  final AuthService authService = Get.find<AuthService>();

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // UI state
  final RxBool isLoading = false.obs;
  final RxString userName = "".obs;
  final RxString userEmail = "".obs;
  final RxString userRole = "".obs;
}
```

### 3. UserModel

User data structure stored after authentication.

```dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String designation;
  final String gender;
  final String userType;       // Normalized role
  final String? profileImage;
  final Map<String, dynamic>? additionalData;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id'] ?? '',
      name: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      designation: json['designation'] ?? '',
      gender: json['gender'] ?? '',
      userType: UserRoles.normalizeRole(json['user_type'] ?? ''),
      profileImage: json['profile_image'],
      additionalData: json,
    );
  }
}
```

---

## Login Flow

### Step-by-Step Process

```
1. User enters credentials
         │
         ▼
2. AuthController.login()
   - Validate inputs
   - Set isLoading = true
         │
         ▼
3. AuthService.login(email, password)
   - POST to /auth/login
   - Parse response
         │
    ┌────┴────┐
    │ Success │
    └────┬────┘
         │
         ▼
4. AuthService._saveSession()
   - Store token in SharedPreferences
   - Store expiration timestamp
   - Store user data JSON
   - Update reactive state
         │
         ▼
5. Get.offAllNamed(Routes.homepage)
   - Clear navigation stack
   - Navigate to home
         │
         ▼
6. AuthMiddleware validates
   - Check isAuthenticated
   - Check token expiration
   - Reset session timer
         │
         ▼
7. Home page displays
   - Dashboard loads
   - Permission checks apply
```

### Implementation

```dart
// AuthController
Future<void> login() async {
  if (!_validateInputs()) return;

  isLoading.value = true;
  try {
    await authService.login(
      emailController.text.trim(),
      passwordController.text,
    );
    // Navigation handled in AuthService
  } catch (e) {
    SnackBarUtils.showError(e.toString());
  } finally {
    isLoading.value = false;
  }
}

// AuthService
Future<void> login(String email, String password) async {
  final response = await http.post(
    Uri.parse(ApiEndpoints.login),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
    }),
  );

  final json = jsonDecode(response.body);

  if (response.statusCode == 200 && json['status'] == 200) {
    final data = json['data'];
    await _saveSession(
      data['access_token'],
      data['token_expiration'],
      data['user'],
    );
    Get.offAllNamed(Routes.homepage);
  } else {
    throw Exception(json['message'] ?? 'Login failed');
  }
}
```

---

## Token Management

### Token Storage

Tokens are stored in SharedPreferences for persistence:

```dart
Future<void> _saveSession(
  String accessToken,
  String expiration,
  Map<String, dynamic> userData,
) async {
  final prefs = await SharedPreferences.getInstance();

  // Save to storage
  await prefs.setString(_tokenKey, accessToken);
  await prefs.setString(_tokenExpirationKey, expiration);
  await prefs.setString(_userKey, jsonEncode(userData));

  // Update reactive state
  token.value = accessToken;
  tokenExpiration.value = expiration;
  currentUser.value = UserModel.fromJson(userData);
  isAuthenticated.value = true;
}
```

### Token Expiration Format

The API returns expiration as Unix timestamp (seconds since epoch):

```dart
// Example: "1700000000" = Unix timestamp
// Convert to DateTime
DateTime expirationDate = DateTime.fromMillisecondsSinceEpoch(
  int.parse(tokenExpiration) * 1000,
);
```

### Token Validation

```dart
void checkTokenExpiration() {
  if (token.value.isEmpty || tokenExpiration.value.isEmpty) {
    return;
  }

  try {
    final expirationTime = int.parse(tokenExpiration.value);
    final expirationDate = DateTime.fromMillisecondsSinceEpoch(
      expirationTime * 1000,
    );
    final now = DateTime.now();

    if (now.isAfter(expirationDate)) {
      Get.log('Token has expired');
      logout();
    }
  } catch (e) {
    Get.log('Error checking token expiration: $e');
  }
}
```

### Automatic Token Refresh

The HttpClient checks token expiration before each request:

```dart
// lib/utils/http_client.dart
bool _isTokenExpired() {
  final authService = Get.find<AuthService>();
  final expiration = authService.tokenExpiration.value;

  if (expiration.isEmpty) return true;

  try {
    final expirationTime = int.parse(expiration);
    final expirationDate = DateTime.fromMillisecondsSinceEpoch(
      expirationTime * 1000,
    );
    final now = DateTime.now();

    // Consider expired if within 5 minutes
    final buffer = Duration(minutes: 5);
    return now.isAfter(expirationDate.subtract(buffer));
  } catch (e) {
    return true;
  }
}

Future<void> _validateToken() async {
  final authService = Get.find<AuthService>();

  if (authService.isRefreshing.value) {
    // Wait for ongoing refresh
    while (authService.isRefreshing.value) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    return;
  }

  await authService.validateToken();
}
```

---

## Session Timeout

### Warning Dialog

Shows 2 minutes before token expiration:

```dart
// lib/utils/session_timeout_dialog.dart
class SessionTimeoutDialog {
  static Timer? _sessionTimer;
  static Timer? _countdownTimer;
  static bool _isDialogShowing = false;

  static void startSessionTimer() {
    stopSessionTimer();

    final authService = Get.find<AuthService>();
    final expiration = authService.tokenExpiration.value;

    if (expiration.isEmpty) return;

    try {
      final expirationTime = int.parse(expiration);
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(
        expirationTime * 1000,
      );
      final now = DateTime.now();

      // Show warning 2 minutes before expiration
      final warningTime = expirationDate.subtract(Duration(minutes: 2));
      final timeUntilWarning = warningTime.difference(now);

      if (timeUntilWarning.isNegative) {
        // Already past warning time
        _showSessionTimeoutWarning();
      } else {
        _sessionTimer = Timer(timeUntilWarning, _showSessionTimeoutWarning);
      }
    } catch (e) {
      Get.log('Error starting session timer: $e');
    }
  }

  static void resetSessionTimer() {
    final authService = Get.find<AuthService>();
    if (authService.isAuthenticated.value) {
      startSessionTimer();
    }
  }
}
```

### Timeout Dialog UI

```dart
static void _showSessionTimeoutWarning() {
  if (_isDialogShowing) return;
  _isDialogShowing = true;

  int remainingSeconds = 120; // 2 minutes

  Get.dialog(
    WillPopScope(
      onWillPop: () async => false,
      child: StatefulBuilder(
        builder: (context, setState) {
          // Start countdown
          _countdownTimer ??= Timer.periodic(
            Duration(seconds: 1),
            (timer) {
              remainingSeconds--;
              if (remainingSeconds <= 0) {
                timer.cancel();
                Get.back();
                _isDialogShowing = false;
                Get.find<AuthService>().logout();
              } else {
                setState(() {});
              }
            },
          );

          return AlertDialog(
            title: Text('Session Expiring'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Your session will expire in:'),
                SizedBox(height: 16),
                Text(
                  '$remainingSeconds seconds',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                LinearProgressIndicator(
                  value: remainingSeconds / 120,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _countdownTimer?.cancel();
                  _countdownTimer = null;
                  Get.back();
                  _isDialogShowing = false;
                  Get.find<AuthService>().logout();
                },
                child: Text('Logout'),
              ),
              ElevatedButton(
                onPressed: () async {
                  _countdownTimer?.cancel();
                  _countdownTimer = null;
                  Get.back();
                  _isDialogShowing = false;
                  await Get.find<AuthService>().validateToken();
                  startSessionTimer();
                },
                child: Text('Continue Session'),
              ),
            ],
          );
        },
      ),
    ),
    barrierDismissible: false,
  );
}
```

---

## Logout Flow

```dart
Future<void> logout() async {
  try {
    // Notify server (optional, best effort)
    if (token.value.isNotEmpty) {
      await http.post(
        Uri.parse(ApiEndpoints.logout),
        headers: {'Authorization': 'Bearer ${token.value}'},
      );
    }
  } catch (e) {
    // Ignore errors, proceed with local logout
  }

  await _clearSession();
  Get.offAllNamed(Routes.login);
}

Future<void> _clearSession() async {
  final prefs = await SharedPreferences.getInstance();

  // Clear storage
  await prefs.remove(_tokenKey);
  await prefs.remove(_tokenExpirationKey);
  await prefs.remove(_userKey);

  // Reset reactive state
  token.value = '';
  tokenExpiration.value = '';
  currentUser.value = null;
  isAuthenticated.value = false;

  // Stop session timer
  SessionTimeoutDialog.stopSessionTimer();
}
```

---

## Request Authentication

### HttpClient Integration

All API requests go through HttpClient which handles authentication:

```dart
// lib/utils/http_client.dart
class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;
  HttpClient._internal();

  Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    await _validateTokenIfNeeded();
    return await http.get(
      Uri.parse(url),
      headers: _addAuthHeader(headers),
    );
  }

  Map<String, String> _addAuthHeader(Map<String, String>? headers) {
    final authService = Get.find<AuthService>();
    final token = authService.token.value;

    return {
      ...?headers,
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _validateTokenIfNeeded() async {
    if (_isTokenExpired()) {
      await _validateToken();
    }
  }
}
```

### 401 Response Handling

```dart
dynamic _parseResponse(http.Response response) {
  if (response.statusCode == 401) {
    // Token invalid/expired, force logout
    Get.find<AuthService>().logout();
    throw Exception('Session expired. Please login again.');
  }

  final json = jsonDecode(response.body);

  if (response.statusCode >= 400) {
    throw Exception(json['message'] ?? 'Request failed');
  }

  return json;
}
```

---

## Authentication Middleware

### AuthMiddleware

Protects routes requiring authentication:

```dart
// lib/routes.dart
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();

    // Check if going to login page while authenticated
    if (route == Routes.login && authService.isAuthenticated.value) {
      return RouteSettings(name: Routes.homepage);
    }

    // Check if going to protected page while not authenticated
    if (route != Routes.login && route != Routes.initial) {
      if (!authService.isAuthenticated.value) {
        return const RouteSettings(name: Routes.login);
      }

      // Validate token expiration
      authService.checkTokenExpiration();

      // Reset session timer on navigation
      SessionTimeoutDialog.resetSessionTimer();
    }

    return null; // Allow navigation
  }
}
```

---

## Role Normalization

The backend may return different role strings that need normalization:

```dart
// lib/constants/user_roles.dart
class UserRoles {
  static const String admin = 'admin';
  static const String doctor = 'doctor';
  static const String receptionist = 'receptionist';
  static const String nurse = 'receptionist'; // Alias
  static const String patient = 'patient';

  static String normalizeRole(String role) {
    final normalized = role.toLowerCase().trim();

    // Map variations
    switch (normalized) {
      case 'nurse':
        return receptionist;
      case 'administrator':
        return admin;
      default:
        return normalized;
    }
  }
}
```

---

## Security Considerations

### Token Security

1. **Storage**: Tokens stored in SharedPreferences (platform-specific secure storage)
2. **Transmission**: Always over HTTPS
3. **Expiration**: Short-lived tokens with refresh mechanism
4. **Validation**: Server-side validation on every request

### Session Security

1. **Timeout Warning**: User warned before session expires
2. **Automatic Logout**: On token expiration
3. **Activity Reset**: Timer resets on user actions
4. **Single Session**: One active session per user

### Best Practices

```dart
// ✓ Always check authentication before API calls
if (!authService.isAuthenticated.value) {
  return;
}

// ✓ Handle 401 gracefully
try {
  await apiCall();
} catch (e) {
  if (e.toString().contains('401')) {
    await authService.logout();
  }
}

// ✓ Clear sensitive data on logout
await _clearSession();

// ✓ Validate token before sensitive operations
await authService.validateToken();
```

---

## Testing Authentication

### Unit Test Example

```dart
void main() {
  group('AuthService', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('login sets authenticated state', () async {
      // Mock HTTP response
      await authService.login('test@example.com', 'password');

      expect(authService.isAuthenticated.value, true);
      expect(authService.token.value, isNotEmpty);
    });

    test('logout clears all state', () async {
      // Setup authenticated state
      authService.isAuthenticated.value = true;
      authService.token.value = 'test-token';

      await authService.logout();

      expect(authService.isAuthenticated.value, false);
      expect(authService.token.value, isEmpty);
    });
  });
}
```
