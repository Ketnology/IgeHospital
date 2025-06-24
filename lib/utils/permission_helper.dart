import 'package:get/get.dart';
import 'package:ige_hospital/provider/permission_service.dart';
import 'package:ige_hospital/constants/user_roles.dart';

class PermissionHelper {
  static final PermissionService _permissionService = Get.find<PermissionService>();

  static bool canViewPage(String page) {
    return _permissionService.canAccessPage(page);
  }

  static bool canPerformAction(String action) {
    return _permissionService.hasPermission(action);
  }

  static bool canEditOwnResource(String resourceType, String resourceId) {
    return _permissionService.canPerformAction('edit_${resourceType}',
        resourceId: resourceId, resourceType: resourceType);
  }

  static List<String> getAvailableMenuItems() {
    return _permissionService.getAvailablePages();
  }

  static String getCurrentUserRole() {
    return _permissionService.currentUserRole;
  }

  static String getCurrentUserId() {
    return _permissionService.currentUserId;
  }

  static bool isAdmin() {
    return _permissionService.currentUserRole == UserRoles.admin;
  }

  static bool isDoctor() {
    return _permissionService.currentUserRole == UserRoles.doctor;
  }

  static bool isReceptionist() {
    return _permissionService.currentUserRole == UserRoles.receptionist;
  }

  static bool isNurse() {
    return isReceptionist(); // Alias for backward compatibility
  }

  static bool isPatient() {
    return _permissionService.currentUserRole == UserRoles.patient;
  }

  // Helper method to get user-friendly role name
  static String getUserFriendlyRoleName() {
    switch (_permissionService.currentUserRole) {
      case UserRoles.admin:
        return 'Administrator';
      case UserRoles.doctor:
        return 'Doctor';
      case UserRoles.receptionist:
        return 'Receptionist';
      case UserRoles.patient:
        return 'Patient';
      default:
        return 'User';
    }
  }
}
