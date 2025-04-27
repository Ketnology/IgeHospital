import 'package:flutter/material.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:provider/provider.dart';

class InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final double spacing;
  final double labelWidth;

  const InfoItem({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.spacing = 12,
    this.labelWidth = 120,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: notifier.getMaingey,
            ),
            SizedBox(width: spacing),
          ],
          SizedBox(
            width: labelWidth,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: notifier.getMainText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: notifier.getMainText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}