import 'package:flutter/material.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:provider/provider.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final double fontSize;
  final bool showDivider;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.fontSize = 18,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: notifier.getIconColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: 5),
          Divider(color: notifier.getBorderColor),
        ],
      ],
    );
  }
}