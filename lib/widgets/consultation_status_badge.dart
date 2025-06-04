import 'package:flutter/material.dart';
import 'package:ige_hospital/models/consultation_model.dart';

class ConsultationStatusBadge extends StatelessWidget {
  final ConsultationStatusInfo statusInfo;
  final double? fontSize;
  final EdgeInsets? padding;

  const ConsultationStatusBadge({
    super.key,
    required this.statusInfo,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _parseColor(statusInfo.color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _parseColor(statusInfo.color).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _parseColor(statusInfo.color),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusInfo.label,
            style: TextStyle(
              color: _parseColor(statusInfo.color),
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      // Remove the # if present
      String hexColor = colorString.replaceAll('#', '');

      // Add FF at the beginning if it's a 6-digit hex
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }

      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      // Fallback to gray if parsing fails
      return const Color(0xFF6B7280);
    }
  }
}