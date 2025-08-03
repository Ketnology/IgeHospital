import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/accounting_controller.dart';
import 'package:ige_hospital/controllers/auth_controller.dart';
import 'package:ige_hospital/controllers/consultation_controller.dart';
import 'package:ige_hospital/controllers/nurse_controller.dart';
import 'package:ige_hospital/provider/auth_service.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/provider/consultation_service.dart';
import 'package:ige_hospital/provider/dashboard_service.dart';
import 'package:ige_hospital/provider/department_service.dart';
import 'package:ige_hospital/provider/permission_service.dart';
import 'package:ige_hospital/provider/vital_signs_service.dart';
import 'package:ige_hospital/screen/auth/splash_screen.dart';
import 'package:ige_hospital/routes.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    Get.log("🚀 Starting app initialization...");

    // Initialize core services first
    Get.log("📱 Initializing AuthService...");
    await Get.putAsync(() => AuthService().init());

    Get.log("🔐 Initializing AuthController...");
    Get.put(AuthController());

    // Initialize PermissionService after AuthService
    Get.log("🛡️ Initializing PermissionService...");
    Get.put(PermissionService());

    // Initialize other services
    Get.log("💰 Initializing AccountingController...");
    Get.put(AccountingController());

    Get.log("📊 Initializing DashboardService...");
    await Get.putAsync(() => DashboardService().init());

    Get.log("🏥 Initializing DepartmentService...");
    await Get.putAsync(() => DepartmentService().init());

    Get.log("🩺 Initializing ConsultationService...");
    Get.put(ConsultationService());

    // Initialize controllers
    Get.log("👩‍⚕️ Initializing NurseController...");
    Get.put(NurseController());

    Get.log("📞 Initializing ConsultationController...");
    Get.put(ConsultationController());

    Get.log("🫀 Initializing VitalSignsService...");
    Get.put(VitalSignsService());

    Get.log("✅ All services initialized successfully!");

  } catch (e) {
    Get.log("❌ Error during initialization: $e");
    // Continue anyway, but log the error
  }

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
        ),
        home: const MyHomePage(),
        // Add error handling
        unknownRoute: GetPage(
          name: '/notfound',
          page: () => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
        ),
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