import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/home_page.dart';
import 'package:ige_hospital/pages/login_page.dart';
import 'package:ige_hospital/provider/auth_service.dart';
import 'package:ige_hospital/screen/auth/splash_screen.dart';
import 'package:ige_hospital/utils/session_timeout_dialog.dart';

class AuthMiddleware extends GetMiddleware {
  final authService = Get.find<AuthService>();

  @override
  RouteSettings? redirect(String? route) {
    // No redirection needed for login route if not authenticated
    if (route == Routes.login && !authService.isAuthenticated.value) {
      return null;
    }

    // Check if token is valid for protected routes
    if (route != Routes.login && route != Routes.initial) {
      if (!authService.isAuthenticated.value) {
        return RouteSettings(name: Routes.login);
      }

      // Check token expiration
      authService.checkTokenExpiration();

      // Reset session timer when navigating to protected routes
      if (authService.isAuthenticated.value) {
        SessionTimeoutDialog.resetSessionTimer();
        return null;
      } else {
        return RouteSettings(name: Routes.login);
      }
    }

    // Redirect to home if already authenticated and trying to access login
    if (authService.isAuthenticated.value && route == Routes.login) {
      return RouteSettings(name: Routes.homepage);
    }

    return null;
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    return page;
  }

  @override
  Widget onPageBuilt(Widget page) {
    return page;
  }

  @override
  void onPageDispose() {
    // Perform cleanup if needed
  }
}

class Routes {
  static String initial = "/";
  static const String login = "/login";
  static String homepage = "/home";
}

final getPage = [
  GetPage(
    name: Routes.initial,
    page: () => SplashScreen(),
  ),
  GetPage(
    name: Routes.login,
    page: () => LoginPage(),
    middlewares: [AuthMiddleware()],
  ),
  GetPage(
    name: Routes.homepage,
    page: () => MyHomepage(),
    middlewares: [AuthMiddleware()],
  ),
];
