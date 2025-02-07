import 'package:get/get.dart';
import 'package:ige_hospital/home_page.dart';
import 'package:ige_hospital/screen/auth/splash_screen.dart';

class Routes {
  static String initial = "/";
  static String homepage = "/home";
}

final getPage = [
  GetPage(
    name: Routes.initial,
    page: () => SplashScreen(),
  ),
  GetPage(
    name: Routes.homepage,
    page: () => MyHomepage(),
  ),
];
