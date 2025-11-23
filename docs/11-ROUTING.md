# Routing Documentation

> **Document Version:** 1.0.0
> **Last Updated:** November 2024

## Overview

IGE Hospital uses GetX for routing with middleware-based access control. The routing system provides named routes, middleware chains, and page transitions.

---

## Route Configuration

### Location: `lib/routes.dart`

```dart
class Routes {
  static String initial = "/";
  static const String login = "/login";
  static String homepage = "/home";
}

final getPage = [
  GetPage(
    name: Routes.initial,
    page: () => SplashScreen(),
  ),
  GetPage(
    name: Routes.login,
    page: () => LoginPage(),
    middlewares: [AuthMiddleware()],
  ),
  GetPage(
    name: Routes.homepage,
    page: () => MyHomepage(),
    middlewares: [AuthMiddleware(), PermissionMiddleware()],
  ),
];
```

---

## Route Types

### Initial Route (Splash)

```dart
GetPage(
  name: Routes.initial,   // "/"
  page: () => SplashScreen(),
)
```

**Purpose:** App initialization, check auth state, redirect appropriately.

### Login Route

```dart
GetPage(
  name: Routes.login,     // "/login"
  page: () => LoginPage(),
  middlewares: [AuthMiddleware()],
)
```

**Purpose:** User authentication. AuthMiddleware redirects authenticated users away.

### Home Route

```dart
GetPage(
  name: Routes.homepage,  // "/home"
  page: () => MyHomepage(),
  middlewares: [AuthMiddleware(), PermissionMiddleware()],
)
```

**Purpose:** Main app shell with drawer navigation. Protected by both middlewares.

---

## Middleware Chain

### Execution Order

```
Incoming Request
       │
       ▼
┌──────────────────┐
│  AuthMiddleware  │  Priority: 1
│  (Authentication)│
└────────┬─────────┘
         │
    ┌────┴────┐
    │Allowed? │
    └────┬────┘
         │
    ┌────┴────┐         ┌─────────────┐
    │   No    │────────▶│ Redirect to │
    └─────────┘         │   /login    │
         │              └─────────────┘
    ┌────┴────┐
    │   Yes   │
    └────┬────┘
         │
         ▼
┌────────────────────┐
│PermissionMiddleware│  Priority: 2
│   (Authorization)  │
└────────┬───────────┘
         │
    ┌────┴────┐
    │Allowed? │
    └────┬────┘
         │
    ┌────┴────┐         ┌─────────────┐
    │   No    │────────▶│ Redirect to │
    └─────────┘         │   /home     │
         │              └─────────────┘
    ┌────┴────┐
    │   Yes   │
    └────┬────┘
         │
         ▼
┌──────────────────┐
│   Target Page    │
└──────────────────┘
```

---

## Auth Middleware

### Implementation

```dart
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();

    // Public routes - no check needed
    if (route == Routes.initial) {
      return null;
    }

    // Going to login while authenticated
    if (route == Routes.login) {
      if (authService.isAuthenticated.value) {
        return RouteSettings(name: Routes.homepage);
      }
      return null;
    }

    // Protected routes - require authentication
    if (!authService.isAuthenticated.value) {
      return const RouteSettings(name: Routes.login);
    }

    // Validate token expiration
    authService.checkTokenExpiration();

    // Reset session timer on navigation
    SessionTimeoutDialog.resetSessionTimer();

    return null; // Allow access
  }
}
```

### Behavior

| Scenario | Route | Authenticated | Result |
|----------|-------|---------------|--------|
| App start | `/` | Any | Allow (splash handles logic) |
| Go to login | `/login` | Yes | Redirect to `/home` |
| Go to login | `/login` | No | Allow |
| Go to home | `/home` | Yes | Allow |
| Go to home | `/home` | No | Redirect to `/login` |

---

## Permission Middleware

### Implementation

```dart
class PermissionMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    // Skip public routes
    if (route == Routes.login || route == Routes.initial) {
      return null;
    }

    try {
      final permissionService = Get.find<PermissionService>();
      final pageKey = _extractPageKey(route);

      if (!permissionService.canAccessPage(pageKey)) {
        Get.log('Access denied to page: $pageKey');
        return RouteSettings(name: Routes.homepage);
      }
    } catch (e) {
      Get.log('Permission check error: $e');
      // Fail open - allow access on error
    }

    return null;
  }

  String _extractPageKey(String? route) {
    if (route == null || route.isEmpty) return '';

    // Handle query parameters
    final pathPart = route.split('?').first;

    // "/home" → ""
    // "/home/patients" → "patients"
    final parts = pathPart.split('/');

    if (parts.length > 2) {
      return parts[2];
    }

    return '';
  }
}
```

### Page Key Mapping

| Route | Page Key | Permission Check |
|-------|----------|------------------|
| `/home` | `''` | `view_dashboard` |
| `/home/patients` | `patients` | `view_patients` OR `view_own_profile` |
| `/home/doctors` | `doctors` | `view_doctors` |
| `/home/appointments` | `appointments` | `view_appointments` OR `view_own_appointments` |
| `/home/accounting` | `accounting` | `view_accounting` |

---

## In-App Navigation

### Page Selection System

The app uses a single-page architecture with dynamic content switching:

```dart
// lib/static_data.dart
class AppConst extends GetxController implements GetxService {
  RxString selectedPageKey = "".obs;
}

// lib/pages/page_mappings.dart
final Map<String, Widget> pages = {
  '': const RoleBasedDashboard(),
  'overview': const RoleBasedDashboard(),
  'patients': const PatientsPage(),
  'doctors': DoctorsPage(),
  'nurses': const NursesPage(),
  'admins': const AdminsPage(),
  'appointments': const AppointmentsPage(),
  'live-consultations': const LiveConsultationsPage(),
  'accounting': const AccountingPage(),
  'profile': const ProfilePage(),
  'vital-signs': VitalSignsPage(),
};
```

### Changing Pages

```dart
// In drawer or navigation
AppConst.selectedPageKey.value = 'patients';

// In home_page.dart
Obx(() {
  final pageKey = AppConst.selectedPageKey.value;
  return pages[pageKey] ?? const RoleBasedDashboard();
})
```

---

## Navigation Methods

### GetX Navigation

```dart
// Navigate to named route
Get.toNamed(Routes.homepage);

// Replace current route
Get.offNamed(Routes.homepage);

// Clear stack and navigate
Get.offAllNamed(Routes.login);

// Navigate with arguments
Get.toNamed('/home/patients', arguments: {'filter': 'active'});

// Get arguments in target
final args = Get.arguments as Map<String, dynamic>?;

// Navigate back
Get.back();

// Navigate back with result
Get.back(result: true);

// Check if can pop
if (Get.isDialogOpen ?? false) {
  Get.back();
}
```

### Page-to-Page Navigation

```dart
// Using page selection (within home shell)
void navigateToPatients() {
  AppConst.selectedPageKey.value = 'patients';
}

// Navigate to vital signs with patient context
void navigateToVitalSigns(String patientId, String patientName) {
  final appConst = Get.find<AppConst>();
  appConst.selectedPatientId = patientId;
  appConst.selectedPatientName = patientName;
  appConst.selectedPageKey.value = 'vital-signs';
}
```

---

## Splash Screen Flow

### Location: `lib/screen/auth/splash_screen.dart`

```dart
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(Duration(seconds: 2)); // Show splash

    final authService = Get.find<AuthService>();

    if (authService.isAuthenticated.value) {
      // Validate token is still valid
      final isValid = await authService.isTokenValid();

      if (isValid) {
        Get.offAllNamed(Routes.homepage);
      } else {
        Get.offAllNamed(Routes.login);
      }
    } else {
      Get.offAllNamed(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 100),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
```

---

## App Configuration

### MaterialApp Setup

```dart
// lib/main.dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'IGE Hospital',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        fontFamily: "Gilroy",
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF0059E7),
        ),
      ),
      initialRoute: Routes.initial,
      getPages: getPage,
      defaultTransition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 200),
    );
  }
}
```

---

## Best Practices

### 1. Always Use Named Routes

```dart
// ✓ Good
Get.toNamed(Routes.homepage);

// ✗ Avoid
Get.to(() => MyHomepage());
```

### 2. Handle Loading States

```dart
Future<void> navigateWithLoading() async {
  isLoading.value = true;
  try {
    await someAsyncOperation();
    Get.toNamed(Routes.homepage);
  } finally {
    isLoading.value = false;
  }
}
```

### 3. Clear Navigation Stack on Logout

```dart
Future<void> logout() async {
  await authService.logout();
  Get.offAllNamed(Routes.login); // Clears entire stack
}
```

### 4. Pass Data via Arguments

```dart
// Navigate with data
Get.toNamed('/details', arguments: {'id': patientId});

// Retrieve data
final id = Get.arguments['id'] as String;
```
