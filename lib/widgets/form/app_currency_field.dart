import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AppCurrencyField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final String hintText;
  final String currencySymbol;
  final void Function(String)? onChanged;

  const AppCurrencyField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.enabled = true,
    this.hintText = '0.00',
    this.currencySymbol = '₦',
    this.onChanged,
  });

  @override
  State<AppCurrencyField> createState() => _AppCurrencyFieldState();
}

class _AppCurrencyFieldState extends State<AppCurrencyField> {
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: widget.validator,
              onChanged: widget.onChanged,
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
                prefixIcon: Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    widget.currencySymbol,
                    style: TextStyle(
                      color: notifier.getIconColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
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
              ),
            ),
          ],
        );
      },
    );
  }
}