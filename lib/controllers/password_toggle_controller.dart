import 'package:get/get.dart';

/// Controller for managing password visibility state
/// Follows Single Responsibility Principle - only handles password visibility
class PasswordToggleController extends GetxController {
  // Private reactive variable for password visibility
  final RxBool _isPasswordVisible = false.obs;

  // Public getter for password visibility state
  bool get isPasswordVisible => _isPasswordVisible.value;

  // Public getter for reactive password visibility (for Obx widgets)
  RxBool get isPasswordVisibleRx => _isPasswordVisible;

  /// Toggle password visibility state
  void togglePasswordVisibility() {
    _isPasswordVisible.value = !_isPasswordVisible.value;
  }

  /// Set password visibility to a specific state
  void setPasswordVisibility(bool isVisible) {
    _isPasswordVisible.value = isVisible;
  }

  /// Hide password (set to false)
  void hidePassword() {
    _isPasswordVisible.value = false;
  }

  /// Show password (set to true)
  void showPassword() {
    _isPasswordVisible.value = true;
  }

  @override
  void onClose() {
    // Clean up if needed
    super.onClose();
  }
}