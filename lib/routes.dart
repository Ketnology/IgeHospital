import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/home_page.dart';
import 'package:ige_hospital/pages/login_page.dart';
import 'package:ige_hospital/provider/auth_service.dart';
import 'package:ige_hospital/provider/permission_service.dart';
import 'package:ige_hospital/screen/auth/splash_screen.dart';
import 'package:ige_hospital/utils/session_timeout_dialog.dart';

class AuthMiddleware extends GetMiddleware {
  final authService = Get.find<AuthService>();

  @override
  RouteSettings? redirect(String? route) {
    Get.log("AuthMiddleware - Route: $route, Authenticated: ${authService.isAuthenticated.value}");

    // No redirection needed for login route if not authenticated
    if (route == Routes.login && !authService.isAuthenticated.value) {
      Get.log("AuthMiddleware - Allowing access to login page");
      return null;
    }

    // Check if token is valid for protected routes
    if (route != Routes.login && route != Routes.initial) {
      if (!authService.isAuthenticated.value) {
        Get.log("AuthMiddleware - Not authenticated, redirecting to login");
        return RouteSettings(name: Routes.login);
      }

      // Check token expiration
      authService.checkTokenExpiration();

      // Reset session timer when navigating to protected routes
      if (authService.isAuthenticated.value) {
        SessionTimeoutDialog.resetSessionTimer();
        Get.log("AuthMiddleware - User authenticated, allowing access to $route");
        return null;
      } else {
        Get.log("AuthMiddleware - Token expired, redirecting to login");
        return RouteSettings(name: Routes.login);
      }
    }

    // Redirect to home if already authenticated and trying to access login
    if (authService.isAuthenticated.value && route == Routes.login) {
      Get.log("AuthMiddleware - Already authenticated, redirecting to homepage");
      return RouteSettings(name: Routes.homepage);
    }

    return null;
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    Get.log("AuthMiddleware - onPageCalled: ${page?.name}");
    return page;
  }

  @override
  Widget onPageBuilt(Widget page) {
    Get.log("AuthMiddleware - onPageBuilt called");
    return page;
  }

  @override
  void onPageDispose() {
    // Perform cleanup if needed
    Get.log("AuthMiddleware - onPageDispose called");
  }
}

class PermissionMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    Get.log("PermissionMiddleware - Checking route: $route");

    if (route == Routes.login || route == Routes.initial) {
      Get.log("PermissionMiddleware - Allowing access to public route: $route");
      return null; // Allow access to login and initial routes
    }

    try {
      final permissionService = Get.find<PermissionService>();
      final userRole = permissionService.currentUserRole;

      Get.log("PermissionMiddleware - User role: $userRole");

      // Check if user has permission to access the page
      String pageKey = _getPageKeyFromRoute(route);
      bool canAccess = permissionService.canAccessPage(pageKey);

      Get.log("PermissionMiddleware - Page key: '$pageKey', Can access: $canAccess");

      if (!canAccess) {
        Get.log("PermissionMiddleware - No permission for page '$pageKey', redirecting to homepage");
        // Redirect to a default accessible page
        return RouteSettings(name: Routes.homepage);
      }

      Get.log("PermissionMiddleware - Permission granted for page '$pageKey'");
      return null;
    } catch (e) {
      Get.log("PermissionMiddleware - Error: $e, allowing access");
      // If there's an error, allow access (fail-safe)
      return null;
    }
  }

  String _getPageKeyFromRoute(String? route) {
    if (route == null) return '';
    if (route == Routes.homepage) return '';
    // Remove leading slash and return the page key
    return route.replaceFirst('/', '');
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
    middlewares: [AuthMiddleware(), PermissionMiddleware()],
  ),
];