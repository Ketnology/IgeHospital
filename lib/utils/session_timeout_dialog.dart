import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/auth_service.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:provider/provider.dart';

class SessionTimeoutDialog {
  static Timer? _sessionTimer;
  static bool _isDialogShowing = false;

  static void startSessionTimer() {
    // Cancel any existing timer
    _sessionTimer?.cancel();

    final AuthService authService = Get.find<AuthService>();

    try {
      if (authService.tokenExpiration.value.isEmpty) return;

      // Convert Unix timestamp (seconds since epoch) to DateTime
      final int timestamp = int.parse(authService.tokenExpiration.value);
      final expiryTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      final now = DateTime.now();

      // If token has already expired, don't show dialog, let middleware handle it
      if (now.isAfter(expiryTime)) return;

      // Calculate remaining time until 2 minutes before expiry
      final timeUntilWarning = expiryTime.subtract(const Duration(minutes: 2)).difference(now);

      // If less than 2 minutes remaining, show warning immediately
      if (timeUntilWarning.isNegative) {
        _showSessionTimeoutWarning();
        return;
      }

      // Set timer to show warning 2 minutes before expiry
      _sessionTimer = Timer(timeUntilWarning, () {
        _showSessionTimeoutWarning();
      });

    } catch (e) {
      Get.log("Error starting session timer: $e");
    }
  }

  static void resetSessionTimer() {
    _sessionTimer?.cancel();
    startSessionTimer();
  }

  static void _showSessionTimeoutWarning() {
    if (_isDialogShowing) return;

    final AuthService authService = Get.find<AuthService>();

    // Calculate remaining seconds until token expires
    DateTime expiryTime;
    try {
      // Convert Unix timestamp (seconds since epoch) to DateTime
      final int timestamp = int.parse(authService.tokenExpiration.value);
      expiryTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    } catch (e) {
      Get.log("Error parsing token expiration: $e");
      return;
    }

    final int remainingSeconds = expiryTime.difference(DateTime.now()).inSeconds;
    if (remainingSeconds <= 0) return; // Don't show if already expired

    _isDialogShowing = true;

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Prevent closing with back button
        child: Builder(
            builder: (context) {
              final notifier = Provider.of<ColourNotifier>(context, listen: true);

              return AlertDialog(
                backgroundColor: notifier.getContainer,
                title: Text(
                  "Session About to Expire",
                  style: TextStyle(
                    color: notifier.getMainText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Your session will expire in $remainingSeconds seconds. Would you like to continue?",
                      style: TextStyle(
                        color: notifier.getMainText,
                      ),
                    ),
                    const SizedBox(height: 15),
                    LinearProgressIndicator(
                      value: remainingSeconds / 120, // Assuming 2 minute warning
                      color: notifier.getIconColor,
                      backgroundColor: Colors.grey.withOpacity(0.3),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      _isDialogShowing = false;
                      Get.back();
                      authService.logout();
                    },
                    child: Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final bool success = await authService.validateToken();
                      _isDialogShowing = false;
                      Get.back();

                      if (success) {
                        resetSessionTimer();
                      } else {
                        authService.logout();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appMainColor,
                    ),
                    child: const Text(
                      "Continue Session",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            }
        ),
      ),
      barrierDismissible: false,
    );

    // Start a countdown timer to auto logout when token expires
    Timer(Duration(seconds: remainingSeconds), () {
      if (_isDialogShowing) {
        _isDialogShowing = false;
        Get.back();
        authService.logout();
      }
    });
  }

  static void stopSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }
}