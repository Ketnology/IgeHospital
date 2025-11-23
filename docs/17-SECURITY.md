# Security Documentation

> **Document Version:** 1.0.0
> **Last Updated:** November 2024

## Overview

IGE Hospital implements multiple security layers to protect user data and ensure secure operations. This document covers authentication, authorization, data protection, and security best practices.

---

## Authentication Security

### Token-Based Authentication

The application uses JWT (JSON Web Token) for authentication:

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Client    │────▶│   Server     │────▶│  Database   │
│   (App)     │     │   (API)      │     │   (Users)   │
└──────┬──────┘     └──────┬───────┘     └─────────────┘
       │                   │
       │ 1. Login Request  │
       │ (email, password) │
       │──────────────────▶│
       │                   │
       │ 2. Validate       │
       │    credentials    │
       │                   │
       │ 3. JWT Token      │
       │◀──────────────────│
       │                   │
       │ 4. Store Token    │
       │   (SharedPrefs)   │
       │                   │
       │ 5. API Requests   │
       │   (Bearer Token)  │
       │──────────────────▶│
```

### Token Management

**Token Storage:**
- Stored in SharedPreferences
- Platform-specific secure storage
- Never exposed in logs or error messages

**Token Lifecycle:**
- Short-lived tokens (configurable on backend)
- Automatic refresh before expiration
- Session timeout warning to users

```dart
// Token refresh timing
const tokenRefreshBuffer = Duration(minutes: 10);  // Refresh 10 min before expiry
const tokenWarningBuffer = Duration(minutes: 2);   // Warn 2 min before expiry
```

### Session Management

```dart
class SessionTimeoutDialog {
  static void startSessionTimer() {
    // Calculate time until warning
    final warningTime = expirationDate.subtract(Duration(minutes: 2));
    final timeUntilWarning = warningTime.difference(DateTime.now());

    // Show warning dialog before expiration
    _sessionTimer = Timer(timeUntilWarning, _showSessionTimeoutWarning);
  }

  static void resetSessionTimer() {
    // Reset on user activity
    stopSessionTimer();
    startSessionTimer();
  }
}
```

---

## Authorization Security

### Role-Based Access Control (RBAC)

**Roles:**
- Admin - Full system access
- Doctor - Medical operations
- Receptionist - Patient management
- Patient - Self-service only

**Permission Levels:**

```
┌─────────────────────────────────────────────────────────────┐
│                    PERMISSION LAYERS                         │
├─────────────────────────────────────────────────────────────┤
│  1. Route Middleware                                         │
│     - AuthMiddleware: Validates authentication              │
│     - PermissionMiddleware: Validates page access           │
├─────────────────────────────────────────────────────────────┤
│  2. Service Layer                                            │
│     - Permission checks before API calls                    │
│     - Resource ownership validation                         │
├─────────────────────────────────────────────────────────────┤
│  3. UI Layer                                                 │
│     - PermissionWrapper: Hide unauthorized elements         │
│     - Conditional rendering based on role                   │
└─────────────────────────────────────────────────────────────┘
```

### Permission Checking

```dart
// Always check permissions before sensitive operations
Future<void> deletePatient(String id) async {
  final permService = Get.find<PermissionService>();

  if (!permService.hasPermission(Permissions.deletePatients)) {
    throw Exception('Unauthorized: Cannot delete patients');
  }

  await _patientService.deletePatient(id);
}
```

---

## API Security

### Request Authentication

All API requests include authentication headers:

```dart
Map<String, String> _addAuthHeader(Map<String, String>? headers) {
  final authService = Get.find<AuthService>();
  final token = authService.token.value;

  return {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    ...?headers,
    if (token.isNotEmpty) 'Authorization': 'Bearer $token',
  };
}
```

### 401 Handling

Automatic logout on unauthorized responses:

```dart
if (response.statusCode == 401) {
  // Token invalid - force logout
  await authService.logout();
  throw Exception('Session expired. Please login again.');
}
```

### HTTPS Enforcement

All API communication uses HTTPS:

```dart
static const String baseUrl = 'https://api.igehospital.com/api';
```

---

## Data Protection

### Sensitive Data Handling

**Do NOT log:**
- Passwords
- Tokens
- Personal health information
- Financial data

```dart
// ✗ Wrong - logging sensitive data
Get.log('User token: $token');
Get.log('Password: $password');

// ✓ Correct - sanitized logging
Get.log('User authenticated: ${user.id}');
Get.log('Login attempt for: ${user.email}');
```

### Secure Storage

```dart
// Token storage
await prefs.setString('auth_token', token);

// User data storage (JSON encoded)
await prefs.setString('user_data', jsonEncode(userData));
```

### Data Clearing on Logout

```dart
Future<void> _clearSession() async {
  final prefs = await SharedPreferences.getInstance();

  // Clear all sensitive data
  await prefs.remove('auth_token');
  await prefs.remove('token_expiration');
  await prefs.remove('user_data');

  // Clear reactive state
  token.value = '';
  tokenExpiration.value = '';
  currentUser.value = null;
  isAuthenticated.value = false;
}
```

---

## Input Validation

### Client-Side Validation

```dart
bool _validateInputs() {
  final email = emailController.text.trim();
  final password = passwordController.text;

  // Email validation
  if (email.isEmpty) {
    SnackBarUtils.showError('Please enter your email');
    return false;
  }

  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
    SnackBarUtils.showError('Please enter a valid email');
    return false;
  }

  // Password validation
  if (password.isEmpty) {
    SnackBarUtils.showError('Please enter your password');
    return false;
  }

  if (password.length < 6) {
    SnackBarUtils.showError('Password must be at least 6 characters');
    return false;
  }

  return true;
}
```

### Safe JSON Parsing

```dart
factory Model.fromJson(Map<String, dynamic> json) {
  return Model(
    // Safe string parsing
    id: json['id']?.toString() ?? '',

    // Safe integer parsing
    count: int.tryParse(json['count']?.toString() ?? '0') ?? 0,

    // Safe boolean parsing
    isActive: json['is_active'] == true,

    // Safe date parsing
    createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
  );
}
```

---

## Security Best Practices

### 1. Never Hardcode Secrets

```dart
// ✗ Wrong
const apiKey = 'sk-abc123...';

// ✓ Correct - use environment variables
const apiKey = String.fromEnvironment('API_KEY');
```

### 2. Validate Token Before Sensitive Operations

```dart
Future<void> sensitiveOperation() async {
  // Always verify token is valid
  if (!await authService.isTokenValid()) {
    await authService.logout();
    return;
  }

  // Proceed with operation
}
```

### 3. Use HTTPS Exclusively

```dart
// All API URLs should use HTTPS
static const String baseUrl = 'https://api.igehospital.com/api';
```

### 4. Implement Rate Limiting Awareness

```dart
// Handle rate limit responses
if (response.statusCode == 429) {
  throw Exception('Too many requests. Please wait and try again.');
}
```

### 5. Secure Error Messages

```dart
// ✗ Wrong - exposes internal details
throw Exception('SQL Error: Column "password" not found in table "users"');

// ✓ Correct - generic error
throw Exception('An error occurred. Please try again.');
```

### 6. Clear Data on App Close (Optional)

```dart
// For high-security requirements
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused) {
    // Optionally clear sensitive data when app is backgrounded
  }
}
```

---

## Security Checklist

### Authentication
- [x] JWT token-based authentication
- [x] Secure token storage
- [x] Automatic token refresh
- [x] Session timeout handling
- [x] Forced logout on 401

### Authorization
- [x] Role-based access control
- [x] Permission-based route protection
- [x] UI-level permission checks
- [x] Service-level permission validation

### Data Protection
- [x] HTTPS for all API calls
- [x] Sensitive data cleared on logout
- [x] No sensitive data in logs
- [x] Safe JSON parsing

### Input Security
- [x] Client-side validation
- [x] Email format validation
- [x] Password length requirements
- [x] Null-safe data handling

---

## Reporting Security Issues

If you discover a security vulnerability:

1. Do NOT open a public issue
2. Contact the security team directly
3. Provide detailed reproduction steps
4. Allow time for fix before disclosure
