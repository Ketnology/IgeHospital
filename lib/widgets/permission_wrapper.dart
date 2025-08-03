import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/permission_service.dart';

class PermissionWrapper extends StatelessWidget {
  final Widget child;
  final String? permission;
  final List<String>? anyOf;
  final List<String>? allOf;
  final Widget? fallback;

  const PermissionWrapper({
    super.key,
    required this.child,
    this.permission,
    this.anyOf,
    this.allOf,
    this.fallback,
  }) : assert(
  permission != null || anyOf != null || allOf != null,
  'At least one permission check must be provided',
  );

  @override
  Widget build(BuildContext context) {
    try {
      final permissionService = Get.find<PermissionService>();

      bool hasAccess = false;

      if (permission != null) {
        hasAccess = permissionService.hasPermission(permission!);
      } else if (anyOf != null) {
        hasAccess = permissionService.hasAnyPermission(anyOf!);
      } else if (allOf != null) {
        hasAccess = permissionService.hasAllPermissions(allOf!);
      }

      if (hasAccess) {
        return child;
      } else {
        return fallback ?? const SizedBox.shrink();
      }
    } catch (e) {
      Get.log("PermissionWrapper error: $e");
      // If there's an error (like service not found), show the fallback or hide the widget
      return fallback ?? const SizedBox.shrink();
    }
  }
}