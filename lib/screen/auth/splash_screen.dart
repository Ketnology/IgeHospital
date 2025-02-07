import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/static_data/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var selected = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      Get.offAllNamed(Routes.homepage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/app-logo.png",
                height: 50,
              ),
            ],
          )
        ],
      ),
    );
  }
}
