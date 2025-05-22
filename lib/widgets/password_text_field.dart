import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/password_toggle_controller.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:provider/provider.dart';

/// Reusable password text field widget with toggle visibility functionality
/// Follows Open/Closed Principle - open for extension, closed for modification
class PasswordTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String prefixIcon;
  final VoidCallback? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final EdgeInsets? contentPadding;
  final double borderRadius;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final String? controllerTag; // Unique tag for controller instance

  const PasswordTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.contentPadding,
    this.borderRadius = 25,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.hintStyle,
    this.textStyle,
    this.controllerTag,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    // Get or create password toggle controller with unique tag
    final passwordController = Get.put(
      PasswordToggleController(),
      tag: controllerTag ?? 'password_${controller.hashCode}',
    );

    return Obx(() => TextField(
      controller: controller,
      obscureText: !passwordController.isPasswordVisible,
      enabled: enabled,
      style: textStyle ?? TextStyle(color: notifier.getMainText),
      onChanged: onChanged != null ? (value) => onChanged!() : null,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: borderColor ??
                (notifier.isDark ? notifier.getIconColor : Colors.grey.shade200),
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: borderColor ??
                (notifier.isDark ? notifier.getIconColor : Colors.grey.shade200),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: focusedBorderColor ?? notifier.getIconColor,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: borderColor ??
                (notifier.isDark ? notifier.getIconColor : Colors.grey.shade200),
          ),
        ),
        hintText: hintText,
        hintStyle: hintStyle ?? mediumGreyTextStyle,
        contentPadding: contentPadding,
        filled: true,
        fillColor: fillColor ?? notifier.getPrimaryColor,

        // Prefix icon
        prefixIcon: SizedBox(
          height: 20,
          width: 50,
          child: Center(
            child: SvgPicture.asset(
              prefixIcon,
              height: 18,
              width: 18,
              color: notifier.getIconColor,
            ),
          ),
        ),

        // Suffix icon for password visibility toggle
        suffixIcon: SizedBox(
          height: 20,
          width: 50,
          child: Center(
            child: GestureDetector(
              onTap: passwordController.togglePasswordVisibility,
              child: SvgPicture.asset(
                passwordController.isPasswordVisible
                    ? "assets/eye.svg"
                    : "assets/eye-off.svg",
                height: 18,
                width: 18,
                color: notifier.getIconColor,
              ),
            ),
          ),
        ),
      ),
    ));
  }
}