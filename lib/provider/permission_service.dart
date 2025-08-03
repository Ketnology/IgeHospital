import 'package:get/get.dart';
import 'package:ige_hospital/provider/auth_service.dart';
import 'package:ige_hospital/utils/role_permissions.dart';
import 'package:ige_hospital/constants/user_roles.dart';

class PermissionService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();

  String get currentUserRole {
    final rawType = _authService.currentUser.value?.userType ?? '';
    final normalizedRole = UserRoles.normalizeRole(rawType);
    Get.log("PermissionService - Current user role: $normalizedRole (raw: $rawType)"); // Debug log
    return normalizedRole;
  }

  String get currentUserId {
    return _authService.currentUser.value?.id ?? '';
  }

  bool hasPermission(String permission) {
    final role = currentUserRole;
    final hasAccess = RolePermissions.hasPermission(role, permission);
    Get.log("Checking permission '$permission' for role '$role': $hasAccess"); // Debug log
    return hasAccess;
  }

  bool hasAnyPermission(List<String> permissions) {
    return RolePermissions.hasAnyPermission(currentUserRole, permissions);
  }

  bool hasAllPermissions(List<String> permissions) {
    return RolePermissions.hasAllPermissions(currentUserRole, permissions);
  }

  bool canAccessPage(String pageKey) {
    final role = currentUserRole;
    Get.log("Checking page access for '$pageKey' with role '$role'"); // Debug log

    switch (pageKey) {
      case '':
      case 'overview':
      // Dashboard should be accessible to all logged-in users
        return _authService.isAuthenticated.value;
      case 'patients':
        return hasAnyPermission(['view_patients', 'view_own_profile']);
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
        return hasAnyPermission(['view_consultations', 'join_consultations']);
      case 'accounting':
        return hasPermission('view_accounting');
      case 'profile':
        return hasPermission('view_own_profile');
      default:
      // For unknown pages, allow access for all authenticated users
        Get.log("Unknown page '$pageKey', allowing access for authenticated users");
        return _authService.isAuthenticated.value;
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

    // Dashboard should always be available for authenticated users
    if (_authService.isAuthenticated.value) {
      availablePages.add('overview');
    }

    if (canAccessPage('appointments')) availablePages.add('appointments');
    if (canAccessPage('patients')) availablePages.add('patients');
    if (canAccessPage('doctors')) availablePages.add('doctors');
    if (canAccessPage('nurses')) availablePages.add('nurses');
    if (canAccessPage('admins')) availablePages.add('admins');
    if (canAccessPage('live-consultations')) availablePages.add('live-consultations');
    if (canAccessPage('accounting')) availablePages.add('accounting');
    if (canAccessPage('profile')) availablePages.add('profile');

    Get.log("Available pages for role '$currentUserRole': $availablePages"); // Debug log
    return availablePages;
  }

  // Helper methods for role checking
  bool get isAdmin => currentUserRole == UserRoles.admin;
  bool get isDoctor => currentUserRole == UserRoles.doctor;
  bool get isReceptionist => currentUserRole == UserRoles.receptionist;
  bool get isNurse => isReceptionist; // Alias for backward compatibility
  bool get isPatient => currentUserRole == UserRoles.patient;
}