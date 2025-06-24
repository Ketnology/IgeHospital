import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/models/patient_model.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/ui/status_badge.dart';
import 'package:provider/provider.dart';

class PatientCard extends StatelessWidget {
  final PatientModel patient;
  final VoidCallback onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PatientCard({
    super.key,
    required this.patient,
    required this.onView,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            notifier.getContainer,
            notifier.getContainer.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: notifier.getBorderColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onView,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildCardLayout(notifier),
          ),
        ),
      ),
    );
  }

  Widget _buildCardLayout(ColourNotifier notifier) {
    return Column(
      children: [
        // Scrollable content area
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with profile and status
                _buildHeader(notifier),
                const SizedBox(height: 12),

                // Patient info section
                _buildPatientInfo(notifier),
                const SizedBox(height: 12),

                // Vital signs section (if available)
                if (patient.hasVitalSigns) ...[
                  _buildVitalSignsSection(notifier),
                  const SizedBox(height: 12),
                ],

                // Statistics section
                _buildStatsSection(notifier),
              ],
            ),
          ),
        ),

        // Fixed action buttons at bottom
        const SizedBox(height: 12),
        _buildActionButtons(notifier),
      ],
    );
  }

  Widget _buildHeader(ColourNotifier notifier) {
    return Row(
      children: [
        // Profile Avatar with status indicator
        Stack(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    notifier.getIconColor.withOpacity(0.2),
                    notifier.getIconColor.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: notifier.getIconColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: patient.user['profile_image'] != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  patient.user['profile_image'],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, _) => Icon(
                    Icons.person,
                    size: 30,
                    color: notifier.getIconColor,
                  ),
                ),
              )
                  : Icon(
                Icons.person,
                size: 30,
                color: notifier.getIconColor,
              ),
            ),

            // Status indicator dot
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: _getStatusColor(patient.user['status'] ?? 'active'),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: notifier.getContainer,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _getStatusIcon(patient.user['status'] ?? 'active'),
                  size: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(width: 16),

        // Name and ID
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                patient.user['full_name'] ?? 'Unknown Patient',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: notifier.getMainText,
                  letterSpacing: -0.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: notifier.getIconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ID: ${patient.patientUniqueId}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: notifier.getIconColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        // More options button
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: notifier.getBgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: notifier.getBorderColor),
          ),
          child: PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: notifier.getMainText,
              size: 18,
            ),
            color: notifier.getContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              switch (value) {
                case 'view':
                  onView();
                  break;
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
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility, size: 16, color: notifier.getIconColor),
                    const SizedBox(width: 8),
                    Text('View Details', style: TextStyle(color: notifier.getMainText)),
                  ],
                ),
              ),
              if (onEdit != null)
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text('Edit Patient', style: TextStyle(color: notifier.getMainText)),
                    ],
                  ),
                ),
              if (onDelete != null)
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
                      const SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: notifier.getMainText)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPatientInfo(ColourNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: notifier.getBgColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: notifier.getBorderColor.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.email_outlined,
            text: patient.user['email'] ?? 'N/A',
            notifier: notifier,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            text: patient.user['phone'] ?? 'N/A',
            notifier: notifier,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  icon: Icons.person_outline,
                  text: (patient.user['gender'] ?? 'N/A').toString().capitalizeFirst!,
                  color: Colors.blue,
                  notifier: notifier,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildInfoChip(
                  icon: Icons.bloodtype_outlined,
                  text: patient.user['blood_group'] ?? 'N/A',
                  color: Colors.red,
                  notifier: notifier,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSignsSection(ColourNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withOpacity(0.05),
            Colors.pink.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 12,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Latest Vitals',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: notifier.getMainText,
                  ),
                ),
              ),
              Text(
                'Recent',
                style: TextStyle(
                  fontSize: 8,
                  color: notifier.getMaingey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildVitalChip(
                'BP',
                _shortenVitalValue(patient.latestBloodPressure),
                Icons.monitor_heart,
                Colors.red,
                notifier,
              ),
              const SizedBox(width: 2),
              _buildVitalChip(
                'HR',
                _shortenVitalValue(patient.latestHeartRate),
                Icons.favorite,
                Colors.pink,
                notifier,
              ),
              const SizedBox(width: 2),
              _buildVitalChip(
                'Temp',
                _shortenVitalValue(patient.latestTemperature),
                Icons.thermostat,
                Colors.orange,
                notifier,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(ColourNotifier notifier) {
    return Row(
      children: [
        _buildStatCard(
          'Appts',
          patient.stats['appointments_count']?.toString() ?? '0',
          Icons.calendar_today_outlined,
          Colors.blue,
          notifier,
        ),
        const SizedBox(width: 4),
        _buildStatCard(
          'Docs',
          patient.stats['documents_count']?.toString() ?? '0',
          Icons.description_outlined,
          Colors.green,
          notifier,
        ),
        const SizedBox(width: 4),
        _buildStatCard(
          'Vitals',
          patient.vitalSignsCount.toString(),
          Icons.favorite_outline,
          Colors.red,
          notifier,
        ),
      ],
    );
  }

  Widget _buildActionButtons(ColourNotifier notifier) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onView,
            icon: Icon(Icons.visibility, size: 14),
            label: Text('View', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: notifier.getIconColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        if (onEdit != null) ...[
          const SizedBox(width: 6),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: IconButton(
              onPressed: onEdit,
              icon: Icon(Icons.edit, color: Colors.blue, size: 16),
              tooltip: 'Edit',
              padding: EdgeInsets.all(8),
              constraints: BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ),
        ],
        if (onDelete != null) ...[
          const SizedBox(width: 6),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete, color: Colors.red, size: 16),
              tooltip: 'Delete',
              padding: EdgeInsets.all(8),
              constraints: BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required ColourNotifier notifier,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: notifier.getIconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 14,
            color: notifier.getIconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: notifier.getMainText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
    required ColourNotifier notifier,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalChip(
      String label,
      String value,
      IconData icon,
      Color color,
      ColourNotifier notifier,
      ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 10,
              color: color,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: notifier.getMainText,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 7,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label,
      String value,
      IconData icon,
      Color color,
      ColourNotifier notifier,
      ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 14,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: notifier.getMainText,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: notifier.getMaingey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'blocked':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.check;
      case 'blocked':
        return Icons.block;
      case 'pending':
        return Icons.schedule;
      default:
        return Icons.info;
    }
  }

  String _shortenVitalValue(String value) {
    if (value == 'N/A' || value.isEmpty) return 'N/A';

    // For blood pressure, show abbreviated form
    if (value.contains('/')) {
      final parts = value.split('/');
      if (parts.length == 2) {
        final systolic = parts[0].replaceAll(RegExp(r'[^\d]'), '');
        final diastolic = parts[1].replaceAll(RegExp(r'[^\d]'), '');
        return '$systolic/$diastolic';
      }
      return value;
    }

    // For temperature, remove everything except numbers and degree
    if (value.contains('°')) {
      final temp = value.replaceAll(RegExp(r'[^\d.]'), '');
      return '${temp}°';
    }

    // For heart rate, extract just the number
    if (value.contains('bpm')) {
      final hr = value.replaceAll(RegExp(r'[^\d.]'), '');
      return hr;
    }

    // For percentage values
    if (value.contains('%')) {
      final percent = value.replaceAll(RegExp(r'[^\d.]'), '');
      return '${percent}%';
    }

    // General cleanup - remove units and keep only numbers
    final cleaned = value.replaceAll(RegExp(r'[^\d./]'), '');

    // Truncate if still too long
    return cleaned.length > 6 ? '${cleaned.substring(0, 4)}...' : cleaned;
  }
}