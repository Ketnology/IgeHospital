import 'package:flutter/material.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:provider/provider.dart';

class AppDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;
  final bool enabled;
  final String? hint;

  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ColourNotifier>(
      builder: (BuildContext context, notifier, Widget? child) {
        // Validate that the current value exists in the items list
        T? validatedValue = value;
        if (value != null) {
          final bool valueExists = items.any((item) => item.value == value);
          if (!valueExists) {
            validatedValue = null; // Reset to null if value doesn't exist in items
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label.isNotEmpty) ...[
              Text(
                label,
                style: mediumBlackTextStyle.copyWith(
                  color: notifier.getMainText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
            ],
            DropdownButtonFormField<T>(
              value: validatedValue,
              items: items,
              onChanged: enabled ? onChanged : null,
              validator: validator,
              style: TextStyle(
                color: notifier.getMainText,
                fontSize: 14,
              ),
              dropdownColor: notifier.getContainer,
              isExpanded: true, // Add this to prevent overflow
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: mediumGreyTextStyle.copyWith(
                  fontSize: 13,
                  color: notifier.getMaingey,
                ),
                prefixIcon: prefixIcon != null
                    ? Icon(
                  prefixIcon,
                  color: notifier.getIconColor,
                  size: 20,
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
              ),
            ),
          ],
        );
      },
    );
  }
}