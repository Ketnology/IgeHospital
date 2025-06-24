import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/auth_service.dart';

class RoleBasedWidget extends StatelessWidget {
  final Map<String, Widget> roleWidgets;
  final Widget? defaultWidget;

  const RoleBasedWidget({
    super.key,
    required this.roleWidgets,
    this.defaultWidget,
  });

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final userRole = authService.currentUser.value?.userType.toLowerCase() ?? '';

    return roleWidgets[userRole] ?? defaultWidget ?? const SizedBox.shrink();
  }
}