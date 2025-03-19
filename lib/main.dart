import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/auth_controller.dart';
import 'package:ige_hospital/provider/auth_service.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/provider/dashboard_service.dart';
import 'package:ige_hospital/screen/auth/splash_screen.dart';
import 'package:ige_hospital/routes.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => AuthService().init());
  Get.put(AuthController());
  await Get.putAsync(() => DashboardService().init());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (create) => ColourNotifier(),
        )
      ],
      child: GetMaterialApp(
        title: 'IGE Hospital',
        scrollBehavior: MyCustomScrollBehavior(),
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.initial,
        getPages: getPage,
        theme: ThemeData(
          useMaterial3: false,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          fontFamily: "Gilroy",
          dividerColor: Colors.transparent,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xFF0059E7),
          ),
          // colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF0C3150)),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SplashScreen(),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
