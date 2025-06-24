import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/permission_service.dart';

class ConditionalActionWidget extends StatelessWidget {
  final String permission;
  final Widget Function(bool canPerform) builder;
  final List<String>? anyOf;
  final List<String>? allOf;

  const ConditionalActionWidget({
    super.key,
    this.permission = '',
    required this.builder,
    this.anyOf,
    this.allOf,
  });

  @override
  Widget build(BuildContext context) {
    final permissionService = Get.find<PermissionService>();

    bool hasAccess = false;

    if (permission.isNotEmpty) {
      hasAccess = permissionService.hasPermission(permission);
    } else if (anyOf != null && anyOf!.isNotEmpty) {
      hasAccess = permissionService.hasAnyPermission(anyOf!);
    } else if (allOf != null && allOf!.isNotEmpty) {
      hasAccess = permissionService.hasAllPermissions(allOf!);
    }

    return builder(hasAccess);
  }
}