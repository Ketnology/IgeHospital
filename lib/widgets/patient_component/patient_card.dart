import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/models/patient_model.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/ui/status_badge.dart';
import 'package:provider/provider.dart';

class PatientCard extends StatelessWidget {
  final PatientModel patient;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PatientCard({
    super.key,
    required this.patient,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(0),
      color: notifier.getContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: notifier.getBorderColor),
      ),
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with patient info
              _buildHeader(notifier),

              // Patient details - made adaptive for mobile/desktop
              _buildDetails(notifier),

              // Statistics section
              _buildStatistics(notifier),

              // Actions
              _buildActions(notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColourNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: notifier.getIconColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          // Profile image - smaller size
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: patient.user['profile_image'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      patient.user['profile_image'],
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, _) => Icon(
                        Icons.person,
                        size: 20,
                        color: notifier.getIconColor,
                      ),
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 20,
                    color: notifier.getIconColor,
                  ),
          ),
          const SizedBox(width: 12),

          // Name and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.user['full_name'] ?? 'N/A',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: notifier.getMainText,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                StatusBadge(
                  status: patient.user['status'] ?? 'active',
                  fontSize: 10,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(ColourNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.email,
            label: 'Email',
            value: patient.user['email'] ?? 'N/A',
            notifier: notifier,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            icon: Icons.phone,
            label: 'Phone',
            value: patient.user['phone'] ?? 'N/A',
            notifier: notifier,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDetailChip(
                  icon: Icons.person,
                  value: (patient.user['gender'] ?? 'N/A')
                      .toString()
                      .capitalizeFirst!,
                  notifier: notifier,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDetailChip(
                  icon: Icons.bloodtype,
                  value: patient.user['blood_group'] ?? 'N/A',
                  notifier: notifier,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(ColourNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatDisplay(
            'Appointments',
            patient.stats['appointments_count']?.toString() ?? '0',
            Icons.calendar_month_outlined,
            notifier,
          ),
          _buildStatDisplay(
            'Documents',
            patient.stats['documents_count']?.toString() ?? '0',
            Icons.description_outlined,
            notifier,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDisplay(
    String label,
    String value,
    IconData icon,
    ColourNotifier notifier,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: notifier.getIconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(
            icon,
            color: notifier.getIconColor,
            size: 20,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: notifier.getMainText,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: notifier.getMaingey,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required ColourNotifier notifier,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: notifier.getIconColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: notifier.getMainText,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String value,
    required ColourNotifier notifier,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: notifier.getBgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: notifier.getBorderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 14,
            color: notifier.getIconColor,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: notifier.getMainText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(ColourNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: notifier.getBorderColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.visibility,
            label: 'View',
            color: notifier.getIconColor,
            onTap: onView,
          ),
          _buildActionButton(
            icon: Icons.edit,
            label: 'Edit',
            color: Colors.blue,
            onTap: onEdit,
          ),
          _buildActionButton(
            icon: Icons.delete,
            label: 'Delete',
            color: Colors.red,
            onTap: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
