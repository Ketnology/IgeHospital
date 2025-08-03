import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/auth_service.dart';
import 'package:ige_hospital/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService authService = Get.find<AuthService>();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    Get.log("🎬 SplashScreen - Starting initialization");

    // Wait for minimum splash time
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Check authentication status
      Get.log(
          "🔍 SplashScreen - Checking auth status: ${authService.isAuthenticated.value}");
      Get.log(
          "🔍 SplashScreen - Current user: ${authService.currentUser.value?.userType}");

      if (authService.isAuthenticated.value &&
          authService.currentUser.value != null) {
        Get.log("✅ SplashScreen - User is authenticated, going to homepage");
        Get.offAllNamed(Routes.homepage);
      } else {
        Get.log("❌ SplashScreen - User not authenticated, going to login");
        Get.offAllNamed(Routes.login);
      }
    } catch (e) {
      Get.log("💥 SplashScreen - Error during initialization: $e");
      // On error, go to login
      Get.offAllNamed(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/app-logo.svg",
                height: 50,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
