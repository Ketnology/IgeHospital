import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/auth_service.dart';

class AuthController extends GetxController {
  final AuthService authService = Get.find<AuthService>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final RxBool isLoading = false.obs;

  void login() async {
    isLoading.value = true;
    await authService.login(emailController.text, passwordController.text);
    isLoading.value = false;
  }

  void logout() {
    authService.logout();
  }
}
