# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

IGE Hospital is a Flutter-based hospital management system with role-based access control (RBAC). The application manages patients, doctors, nurses/receptionists, appointments, consultations, and accounting operations. It uses GetX for state management, Provider for theme management, and communicates with a REST API at `https://api.igehospital.com/api`.

## Development Commands

### Flutter Commands
```bash
# Install dependencies
flutter pub get

# Run the application (development)
flutter run

# Run in release mode
flutter run --release

# Build for specific platforms
flutter build web
flutter build apk
flutter build ios
flutter build macos

# Run tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Analyze code
flutter analyze

# Format code
dart format .
```

## Architecture Overview

### State Management Pattern
The app uses a **dual state management** approach:
- **GetX**: Primary state management for controllers, routing, and dependency injection
- **Provider**: Theme/color management via `ColourNotifier`

All services and controllers are initialized in `main.dart` using GetX dependency injection with proper order:
1. Core services: `AuthService`, `PermissionService`
2. Feature services: `DashboardService`, `DepartmentService`, `ConsultationService`, `VitalSignsService`
3. Controllers: `AuthController`, `AccountingController`, `NurseController`, `ConsultationController`

### Authentication & Authorization System

**Authentication Flow** (lib/provider/auth_service.dart):
- Token-based auth with automatic expiration checking
- Tokens stored in SharedPreferences
- Session validation occurs every request via `HttpClient`
- Auto-refresh when token expires within 10 minutes
- Session timeout dialog for inactive users

**Authorization (RBAC)** (lib/provider/permission_service.dart, lib/utils/role_permissions.dart):
- Four user roles: `admin`, `doctor`, `receptionist`, `patient`
- Role normalization: `nurse` is aliased to `receptionist` for backward compatibility
- Permissions defined in `lib/constants/permissions.dart`
- Page-level access control via `PermissionMiddleware` in routes
- UI-level access control via `PermissionWrapper` widget in components

**Middleware Chain** (lib/routes.dart):
- `AuthMiddleware`: Validates authentication, redirects unauthenticated users to login
- `PermissionMiddleware`: Checks role-based page access, redirects unauthorized users to homepage

### API Communication Pattern

**HttpClient Singleton** (lib/utils/http_client.dart):
- Centralized HTTP client with automatic token refresh
- Auto-handles 401 responses by logging out user
- Adds Authorization header to all requests
- Methods: `get()`, `post()`, `put()`, `patch()`, `delete()`

**Service Pattern**:
Each feature has a service class (in `lib/provider/`) that:
- Uses `HttpClient` for API calls
- Endpoints defined in `lib/constants/api_endpoints.dart`
- Returns parsed responses to controllers
- Examples: `PatientService`, `DoctorService`, `AppointmentService`

### Page Navigation & Structure

**Navigation System**:
- Main entry: `home_page.dart` with drawer navigation
- Route mapping: `lib/pages/page_mappings.dart` - maps page keys to Widget instances
- Page selection: `AppConst.selectedPageKey` observable controls which page displays
- Drawer: `drawer.dart` with permission-based menu items

**Page Structure**:
```
lib/pages/
├── home.dart              # Dashboard (role-based)
├── appointments.dart      # Appointments management
├── patients_page.dart     # Patient records
├── doctor_page.dart       # Doctor management
├── nurse_page.dart        # Nurse/receptionist management
├── admin_page.dart        # Admin management
├── live_consultations_page.dart  # Video consultations
├── accounting_page.dart   # Financial operations
├── profile_page.dart      # User profile
└── vital_signs_page.dart  # Patient vital signs
```

### Component Organization

**Widget Structure**:
- Reusable widgets: `lib/widgets/`
- Feature-specific components: `lib/widgets/{feature}_components/`
- Form fields: `lib/widgets/form/` (app_text_field, app_date_field, app_currency_field, app_search_field)
- UI components: `lib/widgets/ui/` (status_badge, stat_card, info_item, section_header)

**Model Classes** (lib/models/):
- Follow JSON serialization pattern with `fromJson()` and `toJson()`
- Examples: `PatientModel`, `DoctorModel`, `AppointmentModel`, `ConsultationModel`, `VitalSignsModel`

### Role-Based Access Control Details

**Role Permissions**:
- **Admin**: Full access to all features
- **Doctor**: View/edit patients, appointments, consultations; start/end consultations
- **Receptionist**: View/create/edit patients, view consultations; NO appointment management
- **Patient**: View own profile, view own appointments, book appointments, join consultations

**Permission Checking**:
```dart
// In services/controllers
final permissionService = Get.find<PermissionService>();
if (permissionService.hasPermission('create_patients')) {
  // Allow action
}

// In widgets
PermissionWrapper(
  permission: 'view_patients',
  child: Widget(),
)

// Check multiple permissions (any)
PermissionWrapper(
  anyOf: ['view_appointments', 'view_own_appointments'],
  child: Widget(),
)
```

## Important Patterns & Conventions

### User Type Normalization
Always use `UserRoles.normalizeRole()` when handling user types from API responses, as the backend may return `nurse` but the app uses `receptionist` internally.

### Session Management
The app has automatic session timeout monitoring. Use `SessionTimeoutDialog.resetSessionTimer()` when user performs actions to keep the session alive.

### Logging
Use GetX logging: `Get.log("message")` for debug output visible in console.

### Responsive Design
- Breakpoint: 600px width
- Desktop (>600px): Persistent drawer, AppBar in page
- Mobile (<600px): Hamburger menu drawer, AppBar at top

### API Response Format
All API responses follow this structure:
```json
{
  "status": 200,
  "message": "Success message",
  "data": { ... }
}
```

### Color Theme System
- `ColourNotifier` (Provider) manages light/dark mode
- Access via: `Provider.of<ColourNotifier>(context)` or `notifier` variable
- Theme colors defined in `lib/constants/color_theme.dart`

## Testing Strategy

When adding new features:
1. Create model classes with proper JSON serialization
2. Create service class with API methods using `HttpClient`
3. Create controller with GetX for state management
4. Add permissions to `lib/constants/permissions.dart`
5. Update role permissions in `lib/utils/role_permissions.dart`
6. Create page widget and add to `lib/pages/page_mappings.dart`
7. Add drawer menu item with `PermissionWrapper` in `drawer.dart`
8. Register routes if needed in `routes.dart`

## Common Issues & Solutions

### "Not authenticated" errors
- Check that `AuthService` is initialized before other services in `main.dart`
- Verify token is not expired via `AuthService.checkTokenExpiration()`

### Permission denied / blank screens
- Verify user role is normalized correctly
- Check `RolePermissions` has permissions for the role
- Ensure `PermissionService.canAccessPage()` includes the page key

### GetX dependency not found
- Services must be initialized in `main.dart` before use
- Use `Get.find<Service>()` only after `Get.put()` or `Get.putAsync()`

## API Endpoints Reference

Base URL: `https://api.igehospital.com/api`

Key endpoints (see `lib/constants/api_endpoints.dart`):
- Auth: `/auth/login`, `/auth/validate-token`, `/auth/logout`
- Dashboard: `/admin/dashboard`
- Patients: `/patient`
- Doctors: `/doctor`
- Appointments: `/appointments`
- Consultations: `/live-consultations`
- Accounting: Various accounting endpoints
