import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/auth_service.dart';
import 'package:ige_hospital/utils/snack_bar_utils.dart';

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

    // Debug: Listen to authentication changes
    ever(authService.isAuthenticated, (isAuth) {
      Get.log("AuthController - Authentication changed: $isAuth");
      if (isAuth) {
        updateUserInfo();
      }
    });
  }

  void updateUserInfo() {
    if (authService.currentUser.value != null) {
      userName.value = authService.getUserName();
      userEmail.value = authService.getUserEmail();
      userRole.value = authService.getUserType(); // This returns the friendly name

      Get.log("AuthController - Updated user info:");
      Get.log("  Name: ${userName.value}");
      Get.log("  Email: ${userEmail.value}");
      Get.log("  Role: ${userRole.value}");
      Get.log("  Raw Role: ${authService.getRawUserType()}");
    } else {
      userName.value = "Guest User";
      userEmail.value = "";
      userRole.value = "";
      Get.log("AuthController - Cleared user info (no current user)");
    }
  }

  void login() async {
    if (_validateInputs()) {
      isLoading.value = true;
      Get.log("AuthController - Starting login process");

      try {
        Get.log("AuthController - Attempting login with email: $emailController.text");

        // await authService.login(emailController.text, passwordController.text);
        // await authService.login('igehospital@gmail.com', 'password');
        // await authService.login('nurse@gmail.com', 'password'); // nurse
        // await authService.login('doctor@gmail.com', 'password'); // doctor
        await authService.login('patient@gmail.com', 'password');

        // Wait a bit for the auth state to settle
        await Future.delayed(const Duration(milliseconds: 100));

        Get.log("AuthController - Login completed, auth status: ${authService.isAuthenticated.value}");
        Get.log("AuthController - Current user: ${authService.currentUser.value?.userType}");

      } catch (e) {
        Get.log("AuthController - Login error: $e");
        SnackBarUtils.showErrorSnackBar("Login failed: $e");
      } finally {
        isLoading.value = false;
      }
    }
  }

  bool _validateInputs() {
    // For testing, we'll allow empty inputs and use defaults
    if (emailController.text.isEmpty && passwordController.text.isEmpty) {
      Get.log("AuthController - Using default test credentials");
      return true;
    }

    if (emailController.text.isNotEmpty && passwordController.text.isEmpty) {
      SnackBarUtils.showErrorSnackBar("Password is required");
      return false;
    }

    if (emailController.text.isEmpty && passwordController.text.isNotEmpty) {
      SnackBarUtils.showErrorSnackBar("Email is required");
      return false;
    }

    return true;
  }

  void logout() {
    Get.log("AuthController - Logging out user");
    authService.logout();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}