import 'package:flutter/material.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:provider/provider.dart';

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String percentage;
  final double? width;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.percentage,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: notifier.getContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: boxShadow,
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: mediumGreyTextStyle.copyWith(
                        color: notifier.getMaingey,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      style: mainTextStyle.copyWith(
                        color: notifier.getMainText,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Percentage change indicator
          _buildPercentageIndicator(notifier),
        ],
      ),
    );
  }

  Widget _buildPercentageIndicator(ColourNotifier notifier) {
    try {
      final double percentValue = double.parse(percentage.replaceAll('%', ''));
      final bool isPositive = percentValue >= 0;

      return Row(
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: isPositive ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${percentValue.abs().toStringAsFixed(1)}%',
            style: mediumBlackTextStyle.copyWith(
              color: isPositive ? Colors.green : Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'vs last month',
            style: mediumGreyTextStyle.copyWith(
              color: notifier.getMaingey,
              fontSize: 12,
            ),
          ),
        ],
      );
    } catch (e) {
      return Row(
        children: [
          Icon(
            Icons.remove,
            color: notifier.getMaingey,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'No change',
            style: mediumGreyTextStyle.copyWith(
              color: notifier.getMaingey,
              fontSize: 12,
            ),
          ),
        ],
      );
    }
  }
}
