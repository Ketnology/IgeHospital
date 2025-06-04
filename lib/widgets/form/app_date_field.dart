import 'package:flutter/material.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AppDateField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final void Function(DateTime?) onDateSelected;
  final String? Function(DateTime?)? validator;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String dateFormat;
  final bool enabled;
  final String hintText;

  const AppDateField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.validator,
    this.firstDate,
    this.lastDate,
    this.dateFormat = 'MMM dd, yyyy',
    this.enabled = true,
    this.hintText = 'Select date',
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ColourNotifier>(
      builder: (BuildContext context, notifier, Widget? child) {
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
            InkWell(
              onTap: enabled ? () => _selectDate(context, notifier) : null,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: TextEditingController(
                    text: selectedDate != null
                        ? DateFormat(dateFormat).format(selectedDate!)
                        : '',
                  ),
                  validator: (value) {
                    if (validator != null) {
                      return validator!(selectedDate);
                    }
                    return null;
                  },
                  style: TextStyle(
                    color: notifier.getMainText,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: mediumGreyTextStyle.copyWith(
                      fontSize: 13,
                      color: notifier.getMaingey,
                    ),
                    prefixIcon: Icon(
                      Icons.calendar_today,
                      color: notifier.getIconColor,
                      size: 20,
                    ),
                    suffixIcon: selectedDate != null && enabled
                        ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: notifier.getMaingey,
                        size: 20,
                      ),
                      onPressed: () => onDateSelected(null),
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
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, ColourNotifier notifier) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: notifier.getIconColor,
            ),
            dialogBackgroundColor: notifier.getContainer,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }
}