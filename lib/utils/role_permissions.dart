import 'package:ige_hospital/constants/user_roles.dart';
import 'package:ige_hospital/constants/permissions.dart';

class RolePermissions {
  static final Map<String, List<String>> _rolePermissions = {
    UserRoles.admin: [
      // Admin has all permissions
      Permissions.viewDashboard,
      Permissions.viewAnalytics,
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
      Permissions.viewAppointments,
      Permissions.createAppointments,
      Permissions.editAppointments,
      Permissions.deleteAppointments,
      Permissions.viewConsultations,
      Permissions.createConsultations,
      Permissions.editConsultations,
      Permissions.deleteConsultations,
      Permissions.joinConsultations,
      Permissions.startConsultations,
      Permissions.endConsultations,
      Permissions.viewAccounting,
      Permissions.createAccounting,
      Permissions.editAccounting,
      Permissions.deleteAccounting,
      Permissions.viewSystemSettings,
      Permissions.editSystemSettings,
      Permissions.viewOwnProfile,
      Permissions.viewOwnAppointments,
    ],

    UserRoles.doctor: [
      Permissions.viewDashboard,
      Permissions.viewPatients,
      Permissions.editPatients, // Doctors can update patient records
      Permissions.viewAppointments,
      Permissions.createAppointments,
      Permissions.editAppointments,
      Permissions.viewOwnAppointments,
      Permissions.viewConsultations,
      Permissions.createConsultations,
      Permissions.editConsultations,
      Permissions.joinConsultations,
      Permissions.startConsultations,
      Permissions.endConsultations,
      Permissions.viewOwnProfile,
    ],

    UserRoles.receptionist: [
      Permissions.viewDashboard,
      Permissions.viewPatients,
      Permissions.createPatients,
      Permissions.editPatients,
      // Removed appointment permissions for receptionists
      Permissions.viewConsultations,
      Permissions.joinConsultations,
      Permissions.viewOwnProfile,
    ],

    UserRoles.patient: [
      // Patients have limited permissions
      Permissions.viewDashboard, // Allow dashboard access
      Permissions.viewOwnProfile,
      Permissions.viewOwnAppointments,
      Permissions.createAppointments, // Patients can book appointments
      Permissions.joinConsultations, // Patients can join their consultations
    ],
  };

  static List<String> getPermissionsForRole(String role) {
    final normalizedRole = UserRoles.normalizeRole(role);
    final permissions = _rolePermissions[normalizedRole] ?? [];

    // Debug logging
    if (permissions.isEmpty) {
      print(
          "⚠️ No permissions found for role: $normalizedRole (original: $role)");
      print("Available roles: ${_rolePermissions.keys}");
    } else {
      print("✅ Found ${permissions
          .length} permissions for role: $normalizedRole");
    }

    return permissions;
  }

  static bool hasPermission(String role, String permission) {
    final permissions = getPermissionsForRole(role);
    final hasAccess = permissions.contains(permission);

    // Debug logging for specific permission checks
    if (!hasAccess && role == UserRoles.patient) {
      print("🔒 Patient denied permission: $permission");
      print("Patient permissions: $permissions");
    }

    return hasAccess;
  }

  static bool hasAnyPermission(String role, List<String> permissions) {
    final userPermissions = getPermissionsForRole(role);
    return permissions.any((permission) =>
        userPermissions.contains(permission));
  }

  static bool hasAllPermissions(String role, List<String> permissions) {
    final userPermissions = getPermissionsForRole(role);
    return permissions.every((permission) =>
        userPermissions.contains(permission));
  }
}