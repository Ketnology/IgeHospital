import 'package:flutter/material.dart';
import 'package:ige_hospital/models/vital_signs_model.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/permission_wrapper.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:provider/provider.dart';

class VitalSignsCard extends StatelessWidget {
  final VitalSignModel vitalSign;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const VitalSignsCard({
    super.key,
    required this.vitalSign,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifier.getContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifier.getBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date and status
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vitalSign.recordedDate,
                      style: TextStyle(
                        color: notifier.getMainText,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      vitalSign.recordedTime,
                      style: TextStyle(
                        color: notifier.getMaingey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(vitalSign.overallStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusColor(vitalSign.overallStatus),
                  ),
                ),
                child: Text(
                  _getStatusText(vitalSign.overallStatus),
                  style: TextStyle(
                    color: _getStatusColor(vitalSign.overallStatus),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: notifier.getMainText,
                ),
                color: notifier.getContainer,
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit?.call();
                      break;
                    case 'delete':
                      onDelete?.call();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: PermissionWrapper(
                      anyOf: ['edit_patients'],
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16, color: notifier.getMainText),
                          const SizedBox(width: 8),
                          Text(
                            'Edit',
                            style: TextStyle(color: notifier.getMainText),
                          ),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: PermissionWrapper(
                      anyOf: ['edit_patients', 'delete_patients'],
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 16, color: Colors.red),
                          const SizedBox(width: 8),
                          const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Vital signs grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildVitalItem(
                'Blood Pressure',
                vitalSign.bloodPressure,
                Icons.favorite,
                vitalSign.isBloodPressureNormal ? Colors.green : Colors.red,
                notifier,
              ),
              _buildVitalItem(
                'Heart Rate',
                vitalSign.heartRate,
                Icons.monitor_heart,
                vitalSign.isHeartRateNormal ? Colors.green : Colors.red,
                notifier,
              ),
              _buildVitalItem(
                'Temperature',
                vitalSign.temperature,
                Icons.thermostat,
                vitalSign.isTemperatureNormal ? Colors.green : Colors.red,
                notifier,
              ),
              _buildVitalItem(
                'Oxygen Sat.',
                vitalSign.oxygenSaturation,
                Icons.air,
                Colors.blue,
                notifier,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Additional details
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Respiratory Rate',
                  vitalSign.respiratoryRate,
                  Icons.air,
                  notifier,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Weight',
                  vitalSign.weight,
                  Icons.monitor_weight,
                  notifier,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Height',
                  vitalSign.height,
                  Icons.height,
                  notifier,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'BMI',
                  vitalSign.bmi,
                  Icons.calculate,
                  notifier,
                ),
              ),
            ],
          ),

          // Notes section
          if (vitalSign.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: notifier.getBgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: notifier.getBorderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.note_alt_outlined,
                        size: 16,
                        color: notifier.getMaingey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Notes',
                        style: TextStyle(
                          color: notifier.getMaingey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    vitalSign.notes,
                    style: TextStyle(
                      color: notifier.getMainText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Footer with recorded by info
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 14,
                color: notifier.getMaingey,
              ),
              const SizedBox(width: 4),
              Text(
                'Recorded by ${vitalSign.recordedBy.name}',
                style: TextStyle(
                  color: notifier.getMaingey,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                vitalSign.recordedAtHuman,
                style: TextStyle(
                  color: notifier.getMaingey,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalItem(
      String label,
      String value,
      IconData icon,
      Color color,
      ColourNotifier notifier,
      ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: notifier.getMainText,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(
              color: notifier.getMaingey,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
      String label,
      String value,
      IconData icon,
      ColourNotifier notifier,
      ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: notifier.getBgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: notifier.getBorderColor),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: notifier.getMaingey,
            size: 14,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: notifier.getMainText,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(
              color: notifier.getMaingey,
              fontSize: 8,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Normal':
        return Colors.green;
      case 'Attention':
        return Colors.orange;
      case 'Critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'Normal':
        return 'Normal';
      case 'Attention':
        return 'Attention';
      case 'Critical':
        return 'Critical';
      default:
        return 'Unknown';
    }
  }
}