import 'package:flutter/material.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:provider/provider.dart';

class DashboardChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Map<String, dynamic>> chartData;
  final bool isDonutChart;

  const DashboardChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.chartData,
    this.isDonutChart = false,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: notifier.getContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: boxShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: mainTextStyle.copyWith(
                      color: notifier.getMainText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: mediumGreyTextStyle.copyWith(
                      color: notifier.getMaingey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: appMainColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  isDonutChart ? Icons.donut_small : Icons.bar_chart,
                  color: appMainColor,
                  size: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Chart Area
          Expanded(
            child: chartData.isEmpty
                ? _buildEmptyState(notifier)
                : isDonutChart
                    ? _buildDonutChart(notifier)
                    : _buildBarChart(notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColourNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 48,
            color: notifier.getMaingey,
          ),
          const SizedBox(height: 8),
          Text(
            'No data available',
            style: mediumGreyTextStyle.copyWith(
              color: notifier.getMaingey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(ColourNotifier notifier) {
    // Simple bar chart representation using containers
    if (chartData.isEmpty) return _buildEmptyState(notifier);

    final maxValue = chartData.fold<double>(
      0,
      (max, item) =>
          (double.tryParse(item['value']?.toString() ?? '0') ?? 0) > max
              ? (double.tryParse(item['value']?.toString() ?? '0') ?? 0)
              : max,
    );

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: chartData.take(6).map((item) {
              final value =
                  double.tryParse(item['value']?.toString() ?? '0') ?? 0;
              final percentage = maxValue > 0 ? (value / maxValue) : 0;
              final label = item['label']?.toString() ?? '';

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Value label
                      Text(
                        value.toStringAsFixed(0),
                        style: mediumBlackTextStyle.copyWith(
                          color: notifier.getMainText,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Bar
                      Container(
                        width: double.infinity,
                        height: (percentage * 150).clamp(4.0, 150.0).toDouble(),
                        decoration: BoxDecoration(
                          color: _getBarColor(chartData.indexOf(item)),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Label
                      Text(
                        label.length > 8
                            ? '${label.substring(0, 8)}...'
                            : label,
                        style: mediumGreyTextStyle.copyWith(
                          color: notifier.getMaingey,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDonutChart(ColourNotifier notifier) {
    if (chartData.isEmpty) return _buildEmptyState(notifier);

    final total = chartData.fold<double>(
      0,
      (sum, item) =>
          sum + (double.tryParse(item['value']?.toString() ?? '0') ?? 0),
    );

    return Row(
      children: [
        // Chart (simplified representation using containers)
        Expanded(
          flex: 2,
          child: Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: notifier.getBorderColor,
                  width: 2,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Total',
                      style: mediumGreyTextStyle.copyWith(
                        color: notifier.getMaingey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      total.toStringAsFixed(0),
                      style: mainTextStyle.copyWith(
                        color: notifier.getMainText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Legend
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: chartData.take(4).map((item) {
              final value =
                  double.tryParse(item['value']?.toString() ?? '0') ?? 0;
              final percentage = total > 0 ? (value / total * 100) : 0;
              final label = item['label']?.toString() ?? '';

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getBarColor(chartData.indexOf(item)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: mediumBlackTextStyle.copyWith(
                              color: notifier.getMainText,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: mediumGreyTextStyle.copyWith(
                              color: notifier.getMaingey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _getBarColor(int index) {
    final colors = [
      appMainColor,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }
}
