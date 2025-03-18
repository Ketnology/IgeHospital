import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackBarUtils {
  // Shorter default duration for quicker feedback
  static const Duration _defaultDuration = Duration(seconds: 2);

  // Add animation duration for smoother transitions
  static const Duration _animationDuration = Duration(milliseconds: 250);

  static void showSuccessSnackBar(
    String message, {
    String? title,
    Duration? duration,
    SnackPosition? position,
  }) {
    Get.snackbar(
      title ?? "Success",
      message,
      snackPosition: position ?? SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      borderRadius: 10,
      duration: duration ?? _defaultDuration,
      animationDuration: _animationDuration,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutQuart,
      reverseAnimationCurve: Curves.easeInQuart,
      snackStyle: SnackStyle.FLOATING,
    );
  }

  static void showErrorSnackBar(
    String message, {
    String? title,
    Duration? duration,
    SnackPosition? position,
  }) {
    Get.snackbar(
      title ?? "Error",
      message,
      snackPosition: position ?? SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      borderRadius: 10,
      duration: duration ?? _defaultDuration,
      animationDuration: _animationDuration,
      icon: const Icon(Icons.error, color: Colors.white),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutQuart,
      reverseAnimationCurve: Curves.easeInQuart,
      snackStyle: SnackStyle.FLOATING,
    );
  }

  static void showWarningSnackBar(
    String message, {
    String? title,
    Duration? duration,
    SnackPosition? position,
  }) {
    Get.snackbar(
      title ?? "Warning",
      message,
      snackPosition: position ?? SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.shade700,
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      borderRadius: 10,
      duration: duration ?? _defaultDuration,
      animationDuration: _animationDuration,
      icon: const Icon(Icons.warning, color: Colors.white),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutQuart,
      reverseAnimationCurve: Curves.easeInQuart,
      snackStyle: SnackStyle.FLOATING,
    );
  }

  static void showInfoSnackBar(
    String message, {
    String? title,
    Duration? duration,
    SnackPosition? position,
  }) {
    Get.snackbar(
      title ?? "Info",
      message,
      snackPosition: position ?? SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade600,
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      borderRadius: 10,
      duration: duration ?? _defaultDuration,
      animationDuration: _animationDuration,
      icon: const Icon(Icons.info, color: Colors.white),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutQuart,
      reverseAnimationCurve: Curves.easeInQuart,
      snackStyle: SnackStyle.FLOATING,
    );
  }
}
