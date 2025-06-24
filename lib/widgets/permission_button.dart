import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/permission_service.dart';

class PermissionButton extends StatelessWidget {
  final String permission;
  final Widget child;
  final VoidCallback? onPressed;
  final List<String>? anyOf;
  final List<String>? allOf;

  const PermissionButton({
    super.key,
    this.permission = '',
    required this.child,
    this.onPressed,
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

    if (!hasAccess) {
      return const SizedBox.shrink();
    }

    // Handle different button types with proper null checking
    if (child is ElevatedButton) {
      final elevatedButton = child as ElevatedButton;
      return ElevatedButton(
        onPressed: onPressed,
        style: elevatedButton.style,
        child: elevatedButton.child ?? const SizedBox(), // Handle nullable child
      );
    } else if (child is IconButton) {
      final iconButton = child as IconButton;
      return IconButton(
        onPressed: onPressed,
        icon: iconButton.icon,
        tooltip: iconButton.tooltip,
        color: iconButton.color,
        iconSize: iconButton.iconSize,
        splashRadius: iconButton.splashRadius,
        padding: iconButton.padding,
        alignment: iconButton.alignment,
        constraints: iconButton.constraints,
        visualDensity: iconButton.visualDensity,
        focusNode: iconButton.focusNode,
        autofocus: iconButton.autofocus,
        enableFeedback: iconButton.enableFeedback,
        mouseCursor: iconButton.mouseCursor,
      );
    } else if (child is TextButton) {
      final textButton = child as TextButton;
      return TextButton(
        onPressed: onPressed,
        style: textButton.style,
        child: textButton.child ?? const SizedBox(), // Handle nullable child
      );
    } else if (child is OutlinedButton) {
      final outlinedButton = child as OutlinedButton;
      return OutlinedButton(
        onPressed: onPressed,
        style: outlinedButton.style,
        child: outlinedButton.child ?? const SizedBox(), // Handle nullable child
      );
    } else if (child is FloatingActionButton) {
      final fab = child as FloatingActionButton;
      return FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: fab.backgroundColor,
        foregroundColor: fab.foregroundColor,
        elevation: fab.elevation,
        focusElevation: fab.focusElevation,
        hoverElevation: fab.hoverElevation,
        highlightElevation: fab.highlightElevation,
        disabledElevation: fab.disabledElevation,
        mini: fab.mini,
        shape: fab.shape,
        tooltip: fab.tooltip,
        heroTag: fab.heroTag,
        focusNode: fab.focusNode,
        autofocus: fab.autofocus,
        materialTapTargetSize: fab.materialTapTargetSize,
        isExtended: fab.isExtended,
        enableFeedback: fab.enableFeedback,
        mouseCursor: fab.mouseCursor,
        child: fab.child,
      );
    }

    // For any other widget type, wrap in GestureDetector
    return GestureDetector(
      onTap: onPressed,
      child: child,
    );
  }
}