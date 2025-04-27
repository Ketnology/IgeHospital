import 'package:flutter/material.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/dashboard_card.dart';
import 'package:provider/provider.dart';

class DashboardDataCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const DashboardDataCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);
    final effectiveIconColor = iconColor ?? notifier.getIconColor;

    return DashboardCard(
      onTap: onTap,
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: notifier.getMainText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4), // Reduced spacing
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 20, // Slightly smaller font
                    fontWeight: FontWeight.bold,
                    color: notifier.getMainText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: effectiveIconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 22,
              color: effectiveIconColor,
            ),
          ),
        ],
      ),
    );
  }
}