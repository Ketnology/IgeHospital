import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/home_page.dart';
import 'package:ige_hospital/pages/login_page.dart';
import 'package:ige_hospital/provider/auth_service.dart';
import 'package:ige_hospital/screen/auth/splash_screen.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    if (authService.isAuthenticated.value && route == Routes.login) {
      return RouteSettings(name: Routes.homepage);
    }

    if (!authService.isAuthenticated.value && route != Routes.login) {
      return RouteSettings(name: Routes.login);
    }

    return null;
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
