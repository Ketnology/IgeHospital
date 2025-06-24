import 'package:get/get.dart';
import 'package:ige_hospital/provider/auth_service.dart';
import 'package:ige_hospital/utils/role_permissions.dart';
import 'package:ige_hospital/constants/user_roles.dart';

class PermissionService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();

  String get currentUserRole {
    final rawType = _authService.currentUser.value?.userType ?? '';
    return UserRoles.normalizeRole(rawType);
  }

  String get currentUserId {
    return _authService.currentUser.value?.id ?? '';
  }

  bool hasPermission(String permission) {
    final role = currentUserRole;
    Get.log("Checking permission '$permission' for role '$role'"); // Debug log
    return RolePermissions.hasPermission(role, permission);
  }

  bool hasAnyPermission(List<String> permissions) {
    return RolePermissions.hasAnyPermission(currentUserRole, permissions);
  }

  bool hasAllPermissions(List<String> permissions) {
    return RolePermissions.hasAllPermissions(currentUserRole, permissions);
  }

  bool canAccessPage(String pageKey) {
    switch (pageKey) {
      case '':
      case 'overview':
        return hasPermission('view_dashboard');
      case 'patients':
        return hasPermission('view_patients');
      case 'doctors':
        return hasPermission('view_doctors');
      case 'nurses':
      case 'receptionists': // Handle both terms
        return hasPermission('view_nurses');
      case 'admins':
        return hasPermission('view_admins');
      case 'appointments':
        return hasAnyPermission(['view_appointments', 'view_own_appointments']);
      case 'live-consultations':
        return hasPermission('view_consultations');
      case 'accounting':
        return hasPermission('view_accounting');
      case 'profile':
        return hasPermission('view_own_profile');
      default:
        return false;
    }
  }

  bool canPerformAction(String action, {String? resourceId, String? resourceType}) {
    // For actions on own resources (like own appointments)
    if (resourceType == 'appointment' && action == 'view') {
      return hasAnyPermission(['view_appointments', 'view_own_appointments']);
    }

    if (resourceType == 'patient' && resourceId == currentUserId) {
      return hasPermission('view_own_profile');
    }

    return hasPermission(action);
  }

  List<String> getAvailablePages() {
    final List<String> availablePages = [];

    if (canAccessPage('')) availablePages.add('overview');
    if (canAccessPage('appointments')) availablePages.add('appointments');
    if (canAccessPage('patients')) availablePages.add('patients');
    if (canAccessPage('doctors')) availablePages.add('doctors');
    if (canAccessPage('nurses')) availablePages.add('nurses');
    if (canAccessPage('admins')) availablePages.add('admins');
    if (canAccessPage('live-consultations')) availablePages.add('live-consultations');
    if (canAccessPage('accounting')) availablePages.add('accounting');
    if (canAccessPage('profile')) availablePages.add('profile');

    return availablePages;
  }

  // Helper methods for role checking
  bool get isAdmin => currentUserRole == UserRoles.admin;
  bool get isDoctor => currentUserRole == UserRoles.doctor;
  bool get isReceptionist => currentUserRole == UserRoles.receptionist;
  bool get isNurse => isReceptionist; // Alias for backward compatibility
  bool get isPatient => currentUserRole == UserRoles.patient;
}