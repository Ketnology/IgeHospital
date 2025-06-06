import 'package:flutter/material.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:provider/provider.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool enabled;
  final bool readOnly;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int? maxLines;
  final int? maxLength;
  final bool obscureText;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextCapitalization textCapitalization;

  const AppTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
    this.obscureText = false,
    this.onChanged,
    this.onTap,
    this.focusNode,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ColourNotifier>(
      builder: (BuildContext context, notifier, Widget? child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label.isNotEmpty) ...[
              Text(
                widget.label,
                style: mediumBlackTextStyle.copyWith(
                  color: notifier.getMainText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
            ],
            TextFormField(
              controller: widget.controller,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              keyboardType: widget.keyboardType,
              validator: widget.validator,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              obscureText: widget.obscureText,
              onChanged: widget.onChanged,
              onTap: widget.onTap,
              focusNode: widget.focusNode,
              autofocus: widget.autofocus,
              textCapitalization: widget.textCapitalization,
              style: TextStyle(
                color: notifier.getMainText,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: mediumGreyTextStyle.copyWith(
                  fontSize: 13,
                  color: notifier.getMaingey,
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                  widget.prefixIcon,
                  color: notifier.getIconColor,
                  size: 20,
                )
                    : null,
                suffixIcon: widget.suffixIcon != null
                    ? IconButton(
                  icon: Icon(
                    widget.suffixIcon,
                    color: notifier.getMaingey,
                    size: 20,
                  ),
                  onPressed: widget.onSuffixIconPressed,
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: notifier.getBorderColor,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: notifier.getBorderColor,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: notifier.getIconColor,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFEF4444),
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFEF4444),
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: notifier.getPrimaryColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                counterStyle: TextStyle(color: notifier.getMaingey),
              ),
            ),
          ],
        );
      },
    );
  }
}