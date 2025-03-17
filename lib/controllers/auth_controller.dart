import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/auth_service.dart';

class AuthController extends GetxController {
  final AuthService authService = Get.find<AuthService>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxString userName = "".obs;
  final RxString userEmail = "".obs;
  final RxString userRole = "".obs;

  @override
  void onInit() {
    super.onInit();
    updateUserInfo();

    ever(authService.currentUser, (_) {
      updateUserInfo();
    });
  }

  void updateUserInfo() {
    if (authService.currentUser.value != null) {
      userName.value = authService.getUserName();
      userEmail.value = authService.getUserEmail();
      userRole.value = authService.getUserType();
    } else {
      userName.value = "Guest User";
      userEmail.value = "";
      userRole.value = "";
    }
  }

  void login() async {
    if (_validateInputs()) {
      isLoading.value = true;
      await authService.login(emailController.text, passwordController.text);
      isLoading.value = false;
    }
  }

  bool _validateInputs() {
    if (emailController.text.isEmpty) {
      Get.snackbar("Error", "Email is required", snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    if (passwordController.text.isEmpty) {
      Get.snackbar("Error", "Password is required", snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    return true;
  }

  void logout() {
    authService.logout();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
