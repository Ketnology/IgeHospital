import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/auth_controller.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/static_data/static_data.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _SingUpPageState();
}

class _SingUpPageState extends State<LoginPage> {
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColourNotifier>(context, listen: false);

    return SafeArea(
      child: Scaffold(
        body: Consumer<ColourNotifier>(
          builder: (context, value, child) => Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: notifier!.getPrimaryColor,
            child: DefaultTabController(
              length: 2,
              initialIndex: 0,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  if (constraints.maxWidth < 600) {
                    // Mobile layout
                    return Container(
                      color: notifier!.getBgColor,
                      height: 900,
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [_buildLogin(width: constraints.maxWidth)],
                        ),
                      ),
                    );
                  } else if (constraints.maxWidth < 1200) {
                    return Container(
                      color: constraints.maxWidth < 860
                          ? notifier!.getBgColor
                          : notifier!.getPrimaryColor,
                      height: 1000,
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            constraints.maxWidth < 860
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 80),
                                    child: _buildLogin(
                                        width: constraints.maxWidth),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 19, vertical: 80),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              height: 782,
                                              decoration: BoxDecoration(
                                                color: notifier!.getBgColor,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(37)),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: _buildLogin(
                                                        width: constraints
                                                            .maxWidth),
                                                  ),
                                                  Expanded(
                                                    child: buildQrCode(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                          ],
                        ),
                      ),
                    );
                  } else {
                    // Website layout
                    return SizedBox(
                      height: 1000,
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 80, vertical: 80),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height: 782,
                                        decoration: BoxDecoration(
                                          color: notifier!.getBgColor,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(37)),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: _buildLogin(
                                                  width: constraints.maxWidth),
                                            ),
                                            Expanded(
                                              child: buildQrCode(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogin({required double width}) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Container(
          height: 734,
          decoration: BoxDecoration(
            color: notifier!.getPrimaryColor,
            borderRadius: const BorderRadius.all(Radius.circular(37)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: width < 600 ? 20 : 50.0,
                vertical: width < 600 ? 40 : 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    height: 110,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Welcome back",
                            style: mainTextStyle.copyWith(
                                overflow: TextOverflow.ellipsis,
                                color: notifier!.getMainText),
                            maxLines: 2),
                        const SizedBox(
                          height: 3,
                        ),
                        Text('Please Enter your email and password',
                            style: mediumGreyTextStyle.copyWith(fontSize: 16),
                            maxLines: 2),
                      ],
                    )),
                const SizedBox(
                  height: 21,
                ),
                Container(
                    height: 50,
                    width: 180,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: appMainColor,
                        borderRadius: BorderRadius.circular(20)),
                    child: Container(
                      height: 50,
                      width: 180,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: appMainColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: notifier!.getPrimaryColor,
                          ),
                        ),
                      ),
                    )),
                const SizedBox(
                  height: 26.8,
                ),
                Flexible(
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: authController.emailController,
                        hintText: "Email Address",
                        prefixIcon: "assets/at.svg",
                        suffixIsTrue: true,
                        suffix: 'assets/octagon-check.svg',
                      ),
                      const SizedBox(
                        height: 19.8,
                      ),
                      _buildTextField(
                        controller: authController.passwordController,
                        hintText: "Password",
                        prefixIcon: "assets/lock.svg",
                        suffixIsTrue: false,
                        obscureText: true,
                      ),
                      const SizedBox(
                        height: 27.3,
                      ),
                      Obx(() => ElevatedButton(
                          onPressed: authController.isLoading.value
                              ? null
                              : authController.login,
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24)),
                              backgroundColor: appMainColor,
                              elevation: 0,
                              fixedSize: const Size.fromHeight(60)),
                          child: Row(
                            children: [
                              const Expanded(
                                  child: SizedBox(
                                width: 10,
                              )),
                              Text("Continue",
                                  style: mediumBlackTextStyle.copyWith(
                                      color: Colors.white)),
                              const Expanded(
                                  child: SizedBox(
                                width: 10,
                              )),
                              Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12)),
                                child: Center(
                                  child:
                                      Obx(() => authController.isLoading.value
                                          ? SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: Colors.white,
                                              ),
                                            )
                                          : SvgPicture.asset(
                                              "assets/arrow-right-small.svg",
                                              width: 12,
                                              height: 12,
                                              color: Colors.white,
                                            )),
                                ),
                              ),
                            ],
                          ))),
                      const SizedBox(
                        height: 46,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

Widget buildQrCode() {
  return Consumer<ColourNotifier>(
    builder: (context, value, child) => Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 600,
        color: notifier!.getBgColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 191,
              width: 191,
              child: SvgPicture.asset('assets/Group 1000000834.svg'),
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                "IGE Legacy Specialist Hospital staff portal",
                style: mediumGreyTextStyle.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    ),
  );
}

Widget _buildTextField({
  required TextEditingController controller,
  required String hintText,
  required String prefixIcon,
  String? suffix,
  required bool suffixIsTrue,
  bool obscureText = false,
}) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
    style: TextStyle(color: notifier!.getMainText),
    decoration: InputDecoration(
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(
              color: notifier!.isDark
                  ? notifier!.getIconColor
                  : Colors.grey.shade200)),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(
              color: notifier!.isDark
                  ? notifier!.getIconColor
                  : Colors.grey.shade200)),
      hintText: hintText,
      hintStyle: mediumGreyTextStyle,
      prefixIcon: SizedBox(
        height: 20,
        width: 50,
        child: Center(
            child: SvgPicture.asset(
          prefixIcon,
          height: 18,
          width: 18,
          color: notifier!.getIconColor,
        )),
      ),
      suffixIcon: suffixIsTrue
          ? SizedBox(
              height: 20,
              width: 50,
              child: Center(
                  child: SvgPicture.asset(
                suffix!,
                height: 18,
                width: 18,
                color: notifier!.getIconColor,
              )),
            )
          : const SizedBox(),
    ),
  );
}
