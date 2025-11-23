# Authorization & RBAC Documentation

> **Document Version:** 1.0.0
> **Last Updated:** November 2024

## Overview

IGE Hospital implements Role-Based Access Control (RBAC) with four user roles. The system provides multi-level access control at routes, pages, and UI components.

---

## User Roles

### Role Definitions

```dart
// lib/constants/user_roles.dart
class UserRoles {
  static const String admin = 'admin';
  static const String doctor = 'doctor';
  static const String receptionist = 'receptionist';
  static const String patient = 'patient';

  // Alias (backend may return 'nurse')
  static const String nurse = 'receptionist';

  static const List<String> allRoles = [
    admin,
    doctor,
    receptionist,
    patient,
  ];

  static String normalizeRole(String role) {
    switch (role.toLowerCase().trim()) {
      case 'nurse':
        return receptionist;
      case 'administrator':
        return admin;
      default:
        return role.toLowerCase().trim();
    }
  }
}
```

### Role Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│                         ADMIN                                │
│  Full system access - all features, all users               │
├─────────────────────────────────────────────────────────────┤
│                         DOCTOR                               │
│  Medical operations - patients, appointments, consultations │
├─────────────────────────────────────────────────────────────┤
│                      RECEPTIONIST                            │
│  Patient care - patient records, view consultations         │
├─────────────────────────────────────────────────────────────┤
│                         PATIENT                              │
│  Self-service - own profile, appointments, consultations    │
└─────────────────────────────────────────────────────────────┘
```

---

## Permission Definitions

### Permission Constants

```dart
// lib/constants/permissions.dart
class Permissions {
  // Dashboard
  static const String viewDashboard = 'view_dashboard';
  static const String viewAnalytics = 'view_analytics';

  // Patients
  static const String viewPatients = 'view_patients';
  static const String createPatients = 'create_patients';
  static const String editPatients = 'edit_patients';
  static const String deletePatients = 'delete_patients';
  static const String viewOwnProfile = 'view_own_profile';

  // Doctors
  static const String viewDoctors = 'view_doctors';
  static const String createDoctors = 'create_doctors';
  static const String editDoctors = 'edit_doctors';
  static const String deleteDoctors = 'delete_doctors';

  // Nurses/Receptionists
  static const String viewNurses = 'view_nurses';
  static const String createNurses = 'create_nurses';
  static const String editNurses = 'edit_nurses';
  static const String deleteNurses = 'delete_nurses';

  // Admins
  static const String viewAdmins = 'view_admins';
  static const String createAdmins = 'create_admins';
  static const String editAdmins = 'edit_admins';
  static const String deleteAdmins = 'delete_admins';

  // Appointments
  static const String viewAppointments = 'view_appointments';
  static const String createAppointments = 'create_appointments';
  static const String editAppointments = 'edit_appointments';
  static const String deleteAppointments = 'delete_appointments';
  static const String viewOwnAppointments = 'view_own_appointments';

  // Consultations
  static const String viewConsultations = 'view_consultations';
  static const String createConsultations = 'create_consultations';
  static const String editConsultations = 'edit_consultations';
  static const String deleteConsultations = 'delete_consultations';
  static const String joinConsultations = 'join_consultations';
  static const String startConsultations = 'start_consultations';
  static const String endConsultations = 'end_consultations';

  // Accounting
  static const String viewAccounting = 'view_accounting';
  static const String createAccounting = 'create_accounting';
  static const String editAccounting = 'edit_accounting';
  static const String deleteAccounting = 'delete_accounting';

  // System Settings
  static const String viewSystemSettings = 'view_system_settings';
  static const String editSystemSettings = 'edit_system_settings';

  // Vital Signs
  static const String viewVitalSigns = 'view_vital_signs';
  static const String createVitalSigns = 'create_vital_signs';
  static const String editVitalSigns = 'edit_vital_signs';
  static const String deleteVitalSigns = 'delete_vital_signs';
}
```

---

## Role-Permission Mapping

### RolePermissions Class

```dart
// lib/utils/role_permissions.dart
class RolePermissions {
  static final Map<String, List<String>> _rolePermissions = {
    // ADMIN - Full access
    UserRoles.admin: [
      // Dashboard
      Permissions.viewDashboard,
      Permissions.viewAnalytics,

      // All user management
      Permissions.viewPatients,
      Permissions.createPatients,
      Permissions.editPatients,
      Permissions.deletePatients,
      Permissions.viewDoctors,
      Permissions.createDoctors,
      Permissions.editDoctors,
      Permissions.deleteDoctors,
      Permissions.viewNurses,
      Permissions.createNurses,
      Permissions.editNurses,
      Permissions.deleteNurses,
      Permissions.viewAdmins,
      Permissions.createAdmins,
      Permissions.editAdmins,
      Permissions.deleteAdmins,

      // Appointments
      Permissions.viewAppointments,
      Permissions.createAppointments,
      Permissions.editAppointments,
      Permissions.deleteAppointments,

      // Consultations
      Permissions.viewConsultations,
      Permissions.createConsultations,
      Permissions.editConsultations,
      Permissions.deleteConsultations,
      Permissions.joinConsultations,
      Permissions.startConsultations,
      Permissions.endConsultations,

      // Accounting
      Permissions.viewAccounting,
      Permissions.createAccounting,
      Permissions.editAccounting,
      Permissions.deleteAccounting,

      // System
      Permissions.viewSystemSettings,
      Permissions.editSystemSettings,

      // Vital Signs
      Permissions.viewVitalSigns,
      Permissions.createVitalSigns,
      Permissions.editVitalSigns,
      Permissions.deleteVitalSigns,

      // Profile
      Permissions.viewOwnProfile,
    ],

    // DOCTOR - Medical operations
    UserRoles.doctor: [
      Permissions.viewDashboard,
      Permissions.viewPatients,
      Permissions.editPatients,
      Permissions.viewAppointments,
      Permissions.createAppointments,
      Permissions.editAppointments,
      Permissions.viewConsultations,
      Permissions.createConsultations,
      Permissions.editConsultations,
      Permissions.joinConsultations,
      Permissions.startConsultations,
      Permissions.endConsultations,
      Permissions.viewVitalSigns,
      Permissions.createVitalSigns,
      Permissions.editVitalSigns,
      Permissions.viewOwnProfile,
    ],

    // RECEPTIONIST - Patient care
    UserRoles.receptionist: [
      Permissions.viewDashboard,
      Permissions.viewPatients,
      Permissions.createPatients,
      Permissions.editPatients,
      Permissions.viewConsultations,
      Permissions.joinConsultations,
      Permissions.viewOwnProfile,
    ],

    // PATIENT - Self-service
    UserRoles.patient: [
      Permissions.viewOwnProfile,
      Permissions.viewOwnAppointments,
      Permissions.createAppointments,
      Permissions.joinConsultations,
    ],
  };

  /// Get all permissions for a role
  static List<String> getPermissionsForRole(String role) {
    final normalizedRole = UserRoles.normalizeRole(role);
    return _rolePermissions[normalizedRole] ?? [];
  }

  /// Check if role has specific permission
  static bool hasPermission(String role, String permission) {
    final permissions = getPermissionsForRole(role);
    return permissions.contains(permission);
  }

  /// Check if role has any of the permissions
  static bool hasAnyPermission(String role, List<String> permissions) {
    final rolePermissions = getPermissionsForRole(role);
    return permissions.any((p) => rolePermissions.contains(p));
  }

  /// Check if role has all permissions
  static bool hasAllPermissions(String role, List<String> permissions) {
    final rolePermissions = getPermissionsForRole(role);
    return permissions.every((p) => rolePermissions.contains(p));
  }
}
```

---

## Permission Service

### Service Implementation

```dart
// lib/provider/permission_service.dart
class PermissionService extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  /// Get current user's role (normalized)
  String get currentUserRole {
    final userType = _authService.currentUser.value?.userType ?? '';
    return UserRoles.normalizeRole(userType);
  }

  /// Get current user's ID
  String get currentUserId {
    return _authService.currentUser.value?.id ?? '';
  }

  /// Check if user has a specific permission
  bool hasPermission(String permission) {
    return RolePermissions.hasPermission(currentUserRole, permission);
  }

  /// Check if user has any of the permissions
  bool hasAnyPermission(List<String> permissions) {
    return RolePermissions.hasAnyPermission(currentUserRole, permissions);
  }

  /// Check if user has all permissions
  bool hasAllPermissions(List<String> permissions) {
    return RolePermissions.hasAllPermissions(currentUserRole, permissions);
  }

  /// Check if user can access a specific page
  bool canAccessPage(String pageKey) {
    switch (pageKey) {
      case '':
      case 'overview':
        return hasPermission(Permissions.viewDashboard);

      case 'patients':
        return hasAnyPermission([
          Permissions.viewPatients,
          Permissions.viewOwnProfile,
        ]);

      case 'doctors':
        return hasPermission(Permissions.viewDoctors);

      case 'nurses':
      case 'receptionists':
        return hasPermission(Permissions.viewNurses);

      case 'admins':
        return hasPermission(Permissions.viewAdmins);

      case 'appointments':
        return hasAnyPermission([
          Permissions.viewAppointments,
          Permissions.viewOwnAppointments,
        ]);

      case 'live-consultations':
        return hasAnyPermission([
          Permissions.viewConsultations,
          Permissions.joinConsultations,
        ]);

      case 'accounting':
        return hasPermission(Permissions.viewAccounting);

      case 'profile':
        return hasPermission(Permissions.viewOwnProfile);

      case 'vital-signs':
        return hasPermission(Permissions.viewVitalSigns);

      default:
        return false;
    }
  }

  /// Check if user can perform action on resource
  bool canPerformAction(String action, {String? resourceOwnerId}) {
    // Check ownership for patient-specific actions
    if (resourceOwnerId != null && currentUserId == resourceOwnerId) {
      // Allow patients to manage their own resources
      if (isPatient) {
        return true;
      }
    }

    return hasPermission(action);
  }

  // Role convenience getters
  bool get isAdmin => currentUserRole == UserRoles.admin;
  bool get isDoctor => currentUserRole == UserRoles.doctor;
  bool get isReceptionist => currentUserRole == UserRoles.receptionist;
  bool get isNurse => isReceptionist; // Alias
  bool get isPatient => currentUserRole == UserRoles.patient;

  /// Get list of accessible pages
  List<String> getAvailablePages() {
    final pages = <String>[];

    if (canAccessPage('overview')) pages.add('overview');
    if (canAccessPage('patients')) pages.add('patients');
    if (canAccessPage('doctors')) pages.add('doctors');
    if (canAccessPage('nurses')) pages.add('nurses');
    if (canAccessPage('admins')) pages.add('admins');
    if (canAccessPage('appointments')) pages.add('appointments');
    if (canAccessPage('live-consultations')) pages.add('live-consultations');
    if (canAccessPage('accounting')) pages.add('accounting');
    if (canAccessPage('profile')) pages.add('profile');

    return pages;
  }
}
```

---

## Access Control Levels

### 1. Route-Level (Middleware)

```dart
// lib/routes.dart
class PermissionMiddleware extends GetMiddleware {
  @override
  int? get priority => 2; // After AuthMiddleware

  @override
  RouteSettings? redirect(String? route) {
    // Skip for public routes
    if (route == Routes.login || route == Routes.initial) {
      return null;
    }

    try {
      final permissionService = Get.find<PermissionService>();

      // Extract page key from route
      // "/home/patients" → "patients"
      final pageKey = _extractPageKey(route);

      if (!permissionService.canAccessPage(pageKey)) {
        Get.log('Access denied to page: $pageKey');
        return RouteSettings(name: Routes.homepage);
      }
    } catch (e) {
      Get.log('Permission check error: $e');
      // Fail open for safety
    }

    return null;
  }

  String _extractPageKey(String? route) {
    if (route == null || route.isEmpty) return '';

    final parts = route.split('/');
    if (parts.length > 2) {
      return parts[2]; // "/home/patients" → "patients"
    }
    return '';
  }
}
```

### 2. Page-Level (Conditional Rendering)

```dart
// lib/pages/page_mappings.dart
final Map<String, Widget> pages = {
  '': const RoleBasedDashboard(),
  'overview': const RoleBasedDashboard(),
  'appointments': const AppointmentsPage(),
  'patients': const PatientsPage(),
  // ... other pages
};

// In page widget
class PatientsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final permService = Get.find<PermissionService>();

    // Additional page-level check
    if (!permService.hasPermission(Permissions.viewPatients)) {
      return AccessDeniedWidget();
    }

    return PatientListContent();
  }
}
```

### 3. Widget-Level (PermissionWrapper)

```dart
// lib/widgets/permission_wrapper.dart
class PermissionWrapper extends StatelessWidget {
  final Widget child;
  final String? permission;
  final List<String>? anyOf;
  final List<String>? allOf;
  final Widget? fallback;

  const PermissionWrapper({
    Key? key,
    required this.child,
    this.permission,
    this.anyOf,
    this.allOf,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final permService = Get.find<PermissionService>();

    bool hasAccess = false;

    if (permission != null) {
      hasAccess = permService.hasPermission(permission!);
    } else if (anyOf != null && anyOf!.isNotEmpty) {
      hasAccess = permService.hasAnyPermission(anyOf!);
    } else if (allOf != null && allOf!.isNotEmpty) {
      hasAccess = permService.hasAllPermissions(allOf!);
    } else {
      // No permission specified, allow access
      hasAccess = true;
    }

    if (hasAccess) {
      return child;
    } else {
      return fallback ?? const SizedBox.shrink();
    }
  }
}
```

### 4. Action-Level (Service Methods)

```dart
// In service or controller
Future<void> deletePatient(String patientId) async {
  final permService = Get.find<PermissionService>();

  if (!permService.hasPermission(Permissions.deletePatients)) {
    throw Exception('Permission denied: Cannot delete patients');
  }

  await _patientService.deletePatient(patientId);
}
```

---

## Usage Examples

### Navigation Drawer

```dart
// lib/drawer.dart
class DrawerCode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          // Dashboard - All authenticated users
          PermissionWrapper(
            permission: Permissions.viewDashboard,
            child: DrawerItem(
              title: 'Dashboard',
              icon: Icons.dashboard,
              pageKey: 'overview',
            ),
          ),

          // Patients - Admin, Doctor, Receptionist
          PermissionWrapper(
            permission: Permissions.viewPatients,
            child: DrawerItem(
              title: 'Patients',
              icon: Icons.people,
              pageKey: 'patients',
            ),
          ),

          // Doctors - Admin only
          PermissionWrapper(
            permission: Permissions.viewDoctors,
            child: DrawerItem(
              title: 'Doctors',
              icon: Icons.medical_services,
              pageKey: 'doctors',
            ),
          ),

          // Appointments - Admin, Doctor, Patient
          PermissionWrapper(
            anyOf: [
              Permissions.viewAppointments,
              Permissions.viewOwnAppointments,
            ],
            child: DrawerItem(
              title: 'Appointments',
              icon: Icons.calendar_today,
              pageKey: 'appointments',
            ),
          ),

          // Consultations - All with consultation permissions
          PermissionWrapper(
            anyOf: [
              Permissions.viewConsultations,
              Permissions.joinConsultations,
            ],
            child: DrawerItem(
              title: 'Live Consultations',
              icon: Icons.video_call,
              pageKey: 'live-consultations',
            ),
          ),

          // Accounting - Admin only
          PermissionWrapper(
            permission: Permissions.viewAccounting,
            child: DrawerItem(
              title: 'Accounting',
              icon: Icons.attach_money,
              pageKey: 'accounting',
            ),
          ),
        ],
      ),
    );
  }
}
```

### Action Buttons

```dart
// Patient card with permission-based actions
class PatientCard extends StatelessWidget {
  final PatientModel patient;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Patient info
          Text(patient.name),

          // Edit button - Only if user can edit
          PermissionWrapper(
            permission: Permissions.editPatients,
            child: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => showEditDialog(patient),
            ),
          ),

          // Delete button - Only if user can delete
          PermissionWrapper(
            permission: Permissions.deletePatients,
            child: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => confirmDelete(patient.id),
            ),
          ),

          // View vital signs - Doctor or Admin
          PermissionWrapper(
            permission: Permissions.viewVitalSigns,
            child: TextButton(
              onPressed: () => navigateToVitalSigns(patient.id),
              child: Text('View Vital Signs'),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Role-Based Dashboard

```dart
// lib/widgets/role_based_dashboard.dart
class RoleBasedDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final permService = Get.find<PermissionService>();

    if (permService.isAdmin) {
      return AdminDashboard();
    } else if (permService.isDoctor) {
      return DoctorDashboard();
    } else if (permService.isReceptionist) {
      return ReceptionistDashboard();
    } else if (permService.isPatient) {
      return PatientDashboard();
    }

    return DefaultDashboard();
  }
}
```

### Conditional Actions in Controller

```dart
class ConsultationController extends GetxController {
  final PermissionService _permService = Get.find();

  bool canStartConsultation(LiveConsultation consultation) {
    // Must have permission
    if (!_permService.hasPermission(Permissions.startConsultations)) {
      return false;
    }

    // Must be the assigned doctor
    if (_permService.isDoctor) {
      return consultation.doctor.id == _permService.currentUserId;
    }

    // Admins can start any
    return _permService.isAdmin;
  }

  Future<void> startConsultation(String id) async {
    if (!_permService.hasPermission(Permissions.startConsultations)) {
      SnackBarUtils.showError('You cannot start consultations');
      return;
    }

    await _consultationService.startConsultation(id);
  }
}
```

---

## Permission Matrix

### Quick Reference

| Feature | Admin | Doctor | Receptionist | Patient |
|---------|-------|--------|--------------|---------|
| **Dashboard** |
| View Dashboard | ✓ | ✓ | ✓ | ✗ |
| View Analytics | ✓ | ✗ | ✗ | ✗ |
| **Patients** |
| View All | ✓ | ✓ | ✓ | ✗ |
| Create | ✓ | ✗ | ✓ | ✗ |
| Edit | ✓ | ✓ | ✓ | ✗ |
| Delete | ✓ | ✗ | ✗ | ✗ |
| **Doctors** |
| View All | ✓ | ✗ | ✗ | ✗ |
| Create/Edit/Delete | ✓ | ✗ | ✗ | ✗ |
| **Appointments** |
| View All | ✓ | ✓ | ✗ | ✗ |
| View Own | ✓ | ✓ | ✗ | ✓ |
| Create | ✓ | ✓ | ✗ | ✓ |
| Edit/Delete | ✓ | ✓ | ✗ | ✗ |
| **Consultations** |
| View All | ✓ | ✓ | ✓ | ✗ |
| Create | ✓ | ✓ | ✗ | ✗ |
| Join | ✓ | ✓ | ✓ | ✓ |
| Start/End | ✓ | ✓ | ✗ | ✗ |
| **Accounting** |
| Full Access | ✓ | ✗ | ✗ | ✗ |
| **Vital Signs** |
| View | ✓ | ✓ | ✗ | ✗ |
| Create/Edit | ✓ | ✓ | ✗ | ✗ |
| **Profile** |
| View Own | ✓ | ✓ | ✓ | ✓ |

---

## Adding New Permissions

### Step-by-Step

1. **Add Permission Constant**
```dart
// lib/constants/permissions.dart
static const String newFeatureView = 'view_new_feature';
static const String newFeatureCreate = 'create_new_feature';
```

2. **Assign to Roles**
```dart
// lib/utils/role_permissions.dart
UserRoles.admin: [
  // ... existing
  Permissions.newFeatureView,
  Permissions.newFeatureCreate,
],
UserRoles.doctor: [
  // ... existing
  Permissions.newFeatureView,
],
```

3. **Add Page Access Check**
```dart
// lib/provider/permission_service.dart
case 'new-feature':
  return hasPermission(Permissions.newFeatureView);
```

4. **Protect UI**
```dart
PermissionWrapper(
  permission: Permissions.newFeatureView,
  child: NewFeatureButton(),
)
```
