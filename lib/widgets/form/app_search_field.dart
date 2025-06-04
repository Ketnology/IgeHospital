import 'package:flutter/material.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:provider/provider.dart';

class AppSearchField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final void Function()? onClear;
  final bool enabled;
  final FocusNode? focusNode;

  const AppSearchField({
    super.key,
    required this.hintText,
    required this.controller,
    this.onChanged,
    this.onClear,
    this.enabled = true,
    this.focusNode,
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ColourNotifier>(
      builder: (BuildContext context, notifier, Widget? child) {
        return TextField(
          controller: widget.controller,
          enabled: widget.enabled,
          focusNode: widget.focusNode,
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
            prefixIcon: Icon(
              Icons.search,
              color: notifier.getIconColor,
              size: 20,
            ),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
              icon: Icon(
                Icons.clear,
                color: notifier.getMaingey,
                size: 20,
              ),
              onPressed: () {
                widget.controller.clear();
                if (widget.onClear != null) {
                  widget.onClear!();
                }
                if (widget.onChanged != null) {
                  widget.onChanged!('');
                }
              },
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
            filled: true,
            fillColor: notifier.getPrimaryColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
        );
      },
    );
  }
}