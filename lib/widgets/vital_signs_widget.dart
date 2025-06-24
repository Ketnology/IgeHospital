import 'package:flutter/material.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:provider/provider.dart';

class VitalSignsWidget extends StatelessWidget {
  final Map<String, dynamic>? vitalSignsSummary;
  final List<dynamic> vitalSigns;
  final bool showHistory;

  const VitalSignsWidget({
    super.key,
    this.vitalSignsSummary,
    required this.vitalSigns,
    this.showHistory = false,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    if (vitalSigns.isEmpty) {
      return _buildEmptyState(notifier);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (vitalSignsSummary != null) ...[
          _buildSummaryCard(notifier),
          if (showHistory) const SizedBox(height: 16),
        ],
        if (showHistory) _buildHistoryList(notifier),
      ],
    );
  }

  Widget _buildEmptyState(ColourNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: notifier.getBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifier.getBorderColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.favorite_outline,
            size: 48,
            color: notifier.getMaingey,
          ),
          const SizedBox(height: 12),
          Text(
            'No Vital Signs Recorded',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: notifier.getMainText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Vital signs will appear here once recorded',
            style: TextStyle(
              fontSize: 14,
              color: notifier.getMaingey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ColourNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            notifier.getIconColor.withOpacity(0.1),
            notifier.getIconColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifier.getIconColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: notifier.getIconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.favorite,
                  color: notifier.getIconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest Vital Signs',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: notifier.getMainText,
                      ),
                    ),
                    Text(
                      vitalSignsSummary!['last_recorded'] ?? 'Unknown time',
                      style: TextStyle(
                        fontSize: 12,
                        color: notifier.getMaingey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: notifier.getIconColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${vitalSignsSummary!['total_records'] ?? vitalSigns.length} Records',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Vital signs grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (vitalSignsSummary!['blood_pressure'] != null)
                _buildVitalCard(
                  'Blood Pressure',
                  vitalSignsSummary!['blood_pressure'],
                  Icons.monitor_heart,
                  Colors.red,
                  notifier,
                ),
              if (vitalSignsSummary!['heart_rate'] != null)
                _buildVitalCard(
                  'Heart Rate',
                  vitalSignsSummary!['heart_rate'],
                  Icons.favorite,
                  Colors.pink,
                  notifier,
                ),
              if (vitalSignsSummary!['temperature'] != null)
                _buildVitalCard(
                  'Temperature',
                  vitalSignsSummary!['temperature'],
                  Icons.thermostat,
                  Colors.orange,
                  notifier,
                ),
              if (vitalSignsSummary!['oxygen_saturation'] != null)
                _buildVitalCard(
                  'O2 Saturation',
                  vitalSignsSummary!['oxygen_saturation'],
                  Icons.air,
                  Colors.blue,
                  notifier,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalCard(
      String label,
      String value,
      IconData icon,
      Color color,
      ColourNotifier notifier,
      ) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: notifier.getContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: notifier.getBorderColor),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: notifier.getMainText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: notifier.getMaingey,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(ColourNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vital Signs History',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: notifier.getMainText,
          ),
        ),
        const SizedBox(height: 12),
        ...vitalSigns.take(5).map((vitalSign) => _buildHistoryItem(vitalSign, notifier)),
        if (vitalSigns.length > 5) ...[
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {
                // Show all vital signs
              },
              child: Text(
                'View All ${vitalSigns.length} Records',
                style: TextStyle(
                  color: notifier.getIconColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> vitalSign, ColourNotifier notifier) {
    final recordedBy = vitalSign['recorded_by'] ?? {};
    final recordedByName = recordedBy['name'] ?? 'Unknown';
    final recordedByType = recordedBy['type'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: notifier.getBgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: notifier.getBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                vitalSign['recorded_date'] ?? 'Unknown Date',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: notifier.getMainText,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    vitalSign['recorded_time'] ?? '',
                    style: TextStyle(
                      fontSize: 11,
                      color: notifier.getMaingey,
                    ),
                  ),
                  if (recordedByName.isNotEmpty)
                    Text(
                      'by $recordedByName${recordedByType.isNotEmpty ? ' ($recordedByType)' : ''}',
                      style: TextStyle(
                        fontSize: 9,
                        color: notifier.getMaingey,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Vital signs in compact format
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              if (vitalSign['blood_pressure'] != null)
                _buildCompactVital(
                  'BP',
                  vitalSign['blood_pressure'],
                  Icons.monitor_heart,
                  notifier,
                ),
              if (vitalSign['heart_rate'] != null)
                _buildCompactVital(
                  'HR',
                  vitalSign['heart_rate'],
                  Icons.favorite,
                  notifier,
                ),
              if (vitalSign['temperature'] != null)
                _buildCompactVital(
                  'Temp',
                  vitalSign['temperature'],
                  Icons.thermostat,
                  notifier,
                ),
              if (vitalSign['oxygen_saturation'] != null)
                _buildCompactVital(
                  'O2',
                  vitalSign['oxygen_saturation'],
                  Icons.air,
                  notifier,
                ),
            ],
          ),

          // Notes if available
          if (vitalSign['notes'] != null && vitalSign['notes'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: notifier.getIconColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.note,
                    size: 14,
                    color: notifier.getIconColor,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      vitalSign['notes'],
                      style: TextStyle(
                        fontSize: 11,
                        color: notifier.getMainText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactVital(
      String label,
      String value,
      IconData icon,
      ColourNotifier notifier,
      ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: notifier.getIconColor,
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: TextStyle(
            fontSize: 11,
            color: notifier.getMainText,
          ),
        ),
      ],
    );
  }
}