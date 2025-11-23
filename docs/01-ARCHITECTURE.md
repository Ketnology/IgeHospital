# Architecture Documentation

> **Document Version:** 1.0.0
> **Last Updated:** November 2024

## Overview

IGE Hospital follows a layered architecture pattern with clear separation of concerns. The application is built using Flutter with GetX for state management and routing, and Provider for theme management.

---

## System Architecture

### High-Level Architecture Diagram

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                              PRESENTATION LAYER                               │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────────────────┐  │
│  │   Pages    │  │  Widgets   │  │  Dialogs   │  │   Form Components      │  │
│  │ (Screens)  │  │ (Reusable) │  │  (Modals)  │  │   (Input Fields)       │  │
│  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘  └───────────┬────────────┘  │
│        └───────────────┴───────────────┴─────────────────────┘               │
└──────────────────────────────────────────┬───────────────────────────────────┘
                                           │
┌──────────────────────────────────────────┴───────────────────────────────────┐
│                              STATE MANAGEMENT LAYER                           │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                        CONTROLLERS (GetX)                                │ │
│  │  ┌──────────────┐ ┌────────────────┐ ┌────────────────┐ ┌─────────────┐ │ │
│  │  │AuthController│ │PatientController│ │ConsultController│ │AccountingCtrl│ │
│  │  └──────────────┘ └────────────────┘ └────────────────┘ └─────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                        THEME PROVIDER (Provider)                         │ │
│  │  ┌──────────────────────────────────────────────────────────────────┐   │ │
│  │  │                     ColourNotifier                                │   │ │
│  │  └──────────────────────────────────────────────────────────────────┘   │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────┬───────────────────────────────────┘
                                           │
┌──────────────────────────────────────────┴───────────────────────────────────┐
│                              BUSINESS LOGIC LAYER                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                           SERVICES (GetX)                                │ │
│  │  ┌───────────┐ ┌──────────────┐ ┌─────────────────┐ ┌────────────────┐  │ │
│  │  │AuthService│ │PatientService│ │ConsultationServ.│ │AccountingServ. │  │ │
│  │  └───────────┘ └──────────────┘ └─────────────────┘ └────────────────┘  │ │
│  │  ┌─────────────┐ ┌──────────────┐ ┌────────────────┐ ┌───────────────┐  │ │
│  │  │DoctorService│ │NurseService  │ │DashboardService│ │VitalSignsServ.│  │ │
│  │  └─────────────┘ └──────────────┘ └────────────────┘ └───────────────┘  │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                      PERMISSION SERVICE                                  │ │
│  │  ┌──────────────────────────────────────────────────────────────────┐   │ │
│  │  │  PermissionService + RolePermissions                              │   │ │
│  │  └──────────────────────────────────────────────────────────────────┘   │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────┬───────────────────────────────────┘
                                           │
┌──────────────────────────────────────────┴───────────────────────────────────┐
│                              DATA ACCESS LAYER                                │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                          HTTP CLIENT (Singleton)                         │ │
│  │  ┌──────────────────────────────────────────────────────────────────┐   │ │
│  │  │  Token Injection | Auto-Refresh | Request Validation | 401 Handling│  │ │
│  │  └──────────────────────────────────────────────────────────────────┘   │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                        LOCAL STORAGE                                     │ │
│  │  ┌──────────────────────────────────────────────────────────────────┐   │ │
│  │  │                   SharedPreferences                               │   │ │
│  │  └──────────────────────────────────────────────────────────────────┘   │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────┬───────────────────────────────────┘
                                           │
┌──────────────────────────────────────────┴───────────────────────────────────┐
│                                 DATA LAYER                                    │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                              MODELS                                      │ │
│  │  ┌────────────┐ ┌────────────┐ ┌─────────────┐ ┌─────────────────────┐  │ │
│  │  │PatientModel│ │DoctorModel │ │Consultation │ │AccountingModels     │  │ │
│  │  └────────────┘ └────────────┘ └─────────────┘ └─────────────────────┘  │ │
│  │  ┌────────────┐ ┌────────────┐ ┌─────────────┐ ┌─────────────────────┐  │ │
│  │  │NurseModel  │ │Appointment │ │VitalSigns   │ │UserModel            │  │ │
│  │  └────────────┘ └────────────┘ └─────────────┘ └─────────────────────┘  │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────────────┘
                                           │
                                           ▼
                              ┌─────────────────────────┐
                              │       REST API          │
                              │  api.igehospital.com    │
                              └─────────────────────────┘
```

---

## Design Patterns

### 1. Singleton Pattern

**Used For:** HTTP Client

```dart
// lib/utils/http_client.dart
class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;
  HttpClient._internal();

  // All HTTP methods use single instance
  Future<http.Response> get(String url) { ... }
  Future<http.Response> post(String url, dynamic body) { ... }
}
```

**Benefits:**
- Single point of API communication
- Consistent token handling
- Centralized error handling

---

### 2. Observer Pattern (Reactive)

**Used For:** GetX Observables

```dart
// lib/provider/auth_service.dart
class AuthService extends GetxController {
  final RxBool isAuthenticated = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  void login() {
    isAuthenticated.value = true;  // Notifies all listeners
    currentUser.value = user;
  }
}

// Usage in widgets
Obx(() => Text(authService.isAuthenticated.value ? 'Logged In' : 'Guest'))
```

**Benefits:**
- Automatic UI updates
- No manual setState calls
- Clean reactive data flow

---

### 3. Dependency Injection Pattern

**Used For:** GetX Service Registration

```dart
// lib/main.dart
Future<void> main() async {
  // Order matters - dependencies first
  await Get.putAsync<AuthService>(() async {
    final service = AuthService();
    await service.init();
    return service;
  });

  Get.put(PermissionService());
  Get.put(DashboardService());
  Get.put(PatientController());
}

// Usage anywhere
final authService = Get.find<AuthService>();
final permService = Get.find<PermissionService>();
```

**Benefits:**
- Loose coupling between components
- Easy testing with mock injection
- Centralized service lifecycle

---

### 4. Middleware Pattern

**Used For:** Route Protection

```dart
// lib/routes.dart
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    if (!authService.isAuthenticated.value) {
      return const RouteSettings(name: Routes.login);
    }
    return null;  // Allow access
  }
}

class PermissionMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final permService = Get.find<PermissionService>();
    final pageKey = extractPageKey(route);
    if (!permService.canAccessPage(pageKey)) {
      return RouteSettings(name: Routes.homepage);
    }
    return null;
  }
}
```

**Benefits:**
- Clean separation of auth/permission logic
- Route-level access control
- Easy to add new middleware

---

### 5. Repository Pattern (Service Layer)

**Used For:** API Communication

```dart
// lib/provider/patient_service.dart
class PatientService extends GetxController {
  final HttpClient _http = HttpClient();

  Future<List<PatientModel>> getPatients() async {
    final response = await _http.get(ApiEndpoints.patients);
    return parsePatients(response);
  }

  Future<void> createPatient(Map<String, dynamic> data) async {
    await _http.post(ApiEndpoints.patients, data);
  }
}
```

**Benefits:**
- Abstracts API details from controllers
- Consistent data parsing
- Easy to mock for testing

---

### 6. Provider Pattern

**Used For:** Theme Management

```dart
// lib/provider/colors_provider.dart
class ColourNotifier with ChangeNotifier {
  bool _isDark = false;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();  // Rebuild dependent widgets
  }

  Color get primaryColor => _isDark ? darkPrimary : lightPrimary;
}

// Usage
Consumer<ColourNotifier>(
  builder: (context, notifier, _) => Container(color: notifier.primaryColor),
)
```

**Benefits:**
- Simple state for theme
- Automatic rebuilds on change
- Works alongside GetX

---

## Data Flow Architecture

### Request Flow

```
User Action (Button Press)
         │
         ▼
┌─────────────────┐
│    Widget       │  UI Layer
│  (Button/Form)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Controller    │  State Management
│  (GetxController)│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│    Service      │  Business Logic
│  (API Methods)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   HttpClient    │  Data Access
│  (Token Inject) │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   REST API      │  External
│  (Backend)      │
└─────────────────┘
```

### Response Flow

```
API Response (JSON)
         │
         ▼
┌─────────────────┐
│   HttpClient    │  Parse response
│  (Response)     │  Handle errors
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│    Service      │  Deserialize JSON
│  (Model.fromJson)│  Business validation
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Controller    │  Update Rx state
│  (.value = x)   │  Notify listeners
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│    Widget       │  Auto-rebuild
│  (Obx/GetX)     │  Show new data
└─────────────────┘
```

---

## Module Architecture

### Feature Module Structure

Each feature follows this pattern:

```
feature/
├── model/
│   └── feature_model.dart       # Data structure
├── service/
│   └── feature_service.dart     # API communication
├── controller/
│   └── feature_controller.dart  # State management
├── page/
│   └── feature_page.dart        # Main screen
└── widgets/
    ├── feature_card.dart        # Display component
    ├── feature_dialog.dart      # Create/Edit form
    ├── feature_filters.dart     # Filter controls
    └── feature_pagination.dart  # Pagination UI
```

### Example: Patient Feature

```
lib/
├── models/
│   └── patient_model.dart
├── provider/
│   └── patient_service.dart
├── controllers/
│   └── patient_controller.dart
├── pages/
│   └── patients_page.dart
└── widgets/
    └── patient_component/
        ├── patient_card.dart
        ├── patient_detail_dialog.dart
        ├── add_patient_dialog.dart
        ├── edit_patient_dialog.dart
        ├── patient_filters.dart
        └── patient_pagination.dart
```

---

## Initialization Sequence

```dart
// lib/main.dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Core Services (order matters)
  await Get.putAsync<AuthService>(() async {
    final service = AuthService();
    await service.init();  // Load saved session
    return service;
  });

  // 2. Permission Service (depends on AuthService)
  Get.put(PermissionService());

  // 3. Data Services
  await Get.putAsync<DashboardService>(() async {
    final service = DashboardService();
    await service.init();
    return service;
  });
  Get.put(DepartmentService());
  Get.put(ConsultationService());
  Get.put(VitalSignsService());

  // 4. Controllers
  Get.put(AuthController());
  Get.put(AccountingController());
  Get.put(NurseController());
  Get.put(ConsultationController());

  // 5. Run App
  runApp(
    ChangeNotifierProvider(
      create: (_) => ColourNotifier(),
      child: MyApp(),
    ),
  );
}
```

---

## Security Architecture

### Token-Based Authentication

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Login     │────▶│  AuthService │────▶│   REST API  │
│   Page      │     │  (Token Mgmt)│     │   /login    │
└─────────────┘     └──────┬───────┘     └──────┬──────┘
                           │                     │
                           │◀────────────────────┘
                           │     JWT Token
                           ▼
                    ┌──────────────┐
                    │SharedPrefs   │
                    │(Persist Token)│
                    └──────────────┘
```

### Request Authentication

```
Every API Request
        │
        ▼
┌──────────────────┐
│ HttpClient.get() │
│ HttpClient.post()│
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Check Token      │
│ Expiration       │
└────────┬─────────┘
         │
    ┌────┴────┐
    │Expired? │
    └────┬────┘
         │
    ┌────┴────┐         ┌────────────────┐
    │  Yes    │────────▶│ Refresh Token  │
    └─────────┘         │ /validate-token│
         │              └────────┬───────┘
    ┌────┴────┐                  │
    │   No    │◀─────────────────┘
    └────┬────┘
         │
         ▼
┌──────────────────┐
│ Add Bearer Token │
│ to Header        │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Execute Request  │
└──────────────────┘
```

---

## Responsive Design Architecture

### Breakpoint Strategy

```
                    600px
                      │
    ┌─────────────────┼─────────────────┐
    │                 │                 │
    │    MOBILE       │    DESKTOP      │
    │    < 600px      │    >= 600px     │
    │                 │                 │
    │  ┌───────────┐  │  ┌───────────┐  │
    │  │ Hamburger │  │  │ Persistent│  │
    │  │ Menu      │  │  │ Drawer    │  │
    │  └───────────┘  │  └───────────┘  │
    │                 │                 │
    │  ┌───────────┐  │  ┌───────────┐  │
    │  │ Top       │  │  │ In-Page   │  │
    │  │ AppBar    │  │  │ AppBar    │  │
    │  └───────────┘  │  └───────────┘  │
    │                 │                 │
    └─────────────────┴─────────────────┘
```

### Responsive Implementation

```dart
// lib/home_page.dart
class MyHomepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return DesktopLayout();  // Persistent drawer
        } else {
          return MobileLayout();   // Hamburger menu
        }
      },
    );
  }
}
```

---

## Error Handling Architecture

### Error Flow

```
API Error / Exception
         │
         ▼
┌──────────────────┐
│   HttpClient     │  Catch & parse error
└────────┬─────────┘
         │
    ┌────┴────┐
    │ 401?    │
    └────┬────┘
         │
    ┌────┴────┐         ┌────────────────┐
    │  Yes    │────────▶│ Force Logout   │
    └─────────┘         │ Redirect Login │
         │              └────────────────┘
    ┌────┴────┐
    │   No    │
    └────┬────┘
         │
         ▼
┌──────────────────┐
│   Service        │  Update error state
│ hasError = true  │
│ errorMessage = x │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│   Controller     │  Notify UI
│ (Rx update)      │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│   Widget         │  Show error
│ (SnackBar/Dialog)│
└──────────────────┘
```

---

## Caching Strategy

### Local Storage (SharedPreferences)

| Key | Type | Purpose |
|-----|------|---------|
| `auth_token` | String | JWT authentication token |
| `token_expiration` | String | Unix timestamp of expiry |
| `user_data` | String | JSON serialized UserModel |

### In-Memory Cache

| Location | Data | Lifetime |
|----------|------|----------|
| AuthService | currentUser | App session |
| DashboardService | counts | Until refresh |
| PatientController | patients list | Until page change |

---

## Future Considerations

### Scalability

1. **Modular Architecture** - Each feature is self-contained
2. **Lazy Loading** - Pages loaded on demand
3. **Pagination** - All lists support pagination
4. **Caching** - Reduce API calls with local cache

### Extensibility

1. **New Roles** - Add to `user_roles.dart` and `role_permissions.dart`
2. **New Features** - Follow existing module pattern
3. **New Endpoints** - Add to `api_endpoints.dart`
4. **New Permissions** - Add to `permissions.dart`

### Maintainability

1. **Consistent Patterns** - All features follow same structure
2. **Centralized Config** - Constants in dedicated files
3. **Clear Separation** - Layers don't cross boundaries
4. **Documentation** - Comprehensive inline and external docs
