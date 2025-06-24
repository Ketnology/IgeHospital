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

    UserRoles.receptionist: [ // Updated from nurse
      Permissions.viewDashboard,
      Permissions.viewPatients,
      Permissions.createPatients,
      Permissions.editPatients,
      Permissions.viewAppointments,
      Permissions.createAppointments,
      Permissions.editAppointments,
      Permissions.viewOwnAppointments,
      Permissions.viewConsultations,
      Permissions.joinConsultations,
      Permissions.viewOwnProfile,
    ],

    UserRoles.patient: [
      Permissions.viewOwnProfile,
      Permissions.viewOwnAppointments,
      Permissions.createAppointments, // Patients can book appointments
      Permissions.joinConsultations, // Patients can join their consultations
    ],
  };

  static List<String> getPermissionsForRole(String role) {
    final normalizedRole = UserRoles.normalizeRole(role);
    return _rolePermissions[normalizedRole] ?? [];
  }

  static bool hasPermission(String role, String permission) {
    final permissions = getPermissionsForRole(role);
    return permissions.contains(permission);
  }

  static bool hasAnyPermission(String role, List<String> permissions) {
    final userPermissions = getPermissionsForRole(role);
    return permissions.any((permission) => userPermissions.contains(permission));
  }

  static bool hasAllPermissions(String role, List<String> permissions) {
    final userPermissions = getPermissionsForRole(role);
    return permissions.every((permission) => userPermissions.contains(permission));
  }
}