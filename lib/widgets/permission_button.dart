import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/permission_service.dart';

class PermissionButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final String? permission;
  final List<String>? anyOf;
  final List<String>? allOf;

  const PermissionButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.permission,
    this.anyOf,
    this.allOf,
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

      if (!hasAccess) {
        return const SizedBox.shrink();
      }

      // Clone the child widget and set the onPressed callback
      if (child is ElevatedButton) {
        final button = child as ElevatedButton;
        return ElevatedButton(
          onPressed: onPressed,
          style: button.style,
          child: button.child ?? const SizedBox.shrink(),
        );
      } else if (child is TextButton) {
        final button = child as TextButton;
        return TextButton(
          onPressed: onPressed,
          style: button.style,
          child: button.child ?? const SizedBox.shrink(),
        );
      } else if (child is OutlinedButton) {
        final button = child as OutlinedButton;
        return OutlinedButton(
          onPressed: onPressed,
          style: button.style,
          child: button.child ?? const SizedBox.shrink(),
        );
      } else if (child is IconButton) {
        final button = child as IconButton;
        return IconButton(
          onPressed: onPressed,
          icon: button.icon,
          tooltip: button.tooltip,
          style: button.style,
        );
      } else {
        // For other widget types, wrap in GestureDetector
        return GestureDetector(
          onTap: onPressed,
          child: child,
        );
      }
    } catch (e) {
      Get.log("PermissionButton error: $e");
      return const SizedBox.shrink();
    }
  }
}