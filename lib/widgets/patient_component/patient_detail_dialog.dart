import 'package:flutter/material.dart';
import 'package:ige_hospital/models/patient_model.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/ui/info_item.dart';
import 'package:ige_hospital/widgets/ui/section_header.dart';
import 'package:ige_hospital/widgets/ui/status_badge.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PatientDetailDialog extends StatelessWidget {
  final PatientModel patient;

  const PatientDetailDialog({
    super.key,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 900,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: notifier.getContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(context, notifier),

            // Content
            Expanded(
              child: DefaultTabController(
                length: 4, // Added vital signs tab
                child: Column(
                  children: [
                    TabBar(
                      labelColor: notifier.getIconColor,
                      unselectedLabelColor: notifier.getMaingey,
                      indicatorColor: notifier.getIconColor,
                      tabs: const [
                        Tab(text: 'Personal Info'),
                        Tab(text: 'Vital Signs'),
                        Tab(text: 'Medical Records'),
                        Tab(text: 'Appointments'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildPersonalInfoTab(context, notifier),
                          _buildVitalSignsTab(context, notifier),
                          _buildMedicalRecordsTab(context, notifier),
                          _buildAppointmentsTab(context, notifier),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: notifier.getBorderColor),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context, 'edit');
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Patient'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: notifier.getIconColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColourNotifier notifier) {
    // Default image if none provided
    String profileImage = '';
    if (patient.user['profile_image'] != null) {
      profileImage = patient.user['profile_image'];
    }

    final String fullName = patient.user['full_name'] ?? 'Unknown Patient';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: notifier.getIconColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile image
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey.shade200,
            child: profileImage.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.network(
                profileImage,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, _) => Icon(
                  Icons.person,
                  size: 40,
                  color: notifier.getIconColor,
                ),
              ),
            )
                : Icon(
              Icons.person,
              size: 40,
              color: notifier.getIconColor,
            ),
          ),
          const SizedBox(width: 20),

          // Patient information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        fullName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: notifier.getMainText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: notifier.getMainText),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Text(
                  'ID: ${patient.patientUniqueId}',
                  style: TextStyle(
                    fontSize: 14,
                    color: notifier.getMaingey,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    StatusBadge(
                      status: patient.user['status'] ?? 'active',
                    ),
                    const SizedBox(width: 10),
                    if (patient.user['blood_group'] != null) ...[
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            patient.user['blood_group'],
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    if (patient.hasVitalSigns) ...[
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.favorite,
                                size: 12,
                                color: Colors.green.shade700,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '${patient.vitalSignsCount} Records',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoTab(BuildContext context, ColourNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Contact Information',
            fontSize: 18,
          ),
          const SizedBox(height: 16),
          InfoItem(
            label: 'Email',
            value: patient.user['email'] ?? 'N/A',
            icon: Icons.email,
          ),
          InfoItem(
            label: 'Phone',
            value: patient.user['phone'] ?? 'N/A',
            icon: Icons.phone,
          ),
          if (patient.address != null && patient.address!['address1'] != null)
            InfoItem(
              label: 'Address',
              value: patient.address!['address1'],
              icon: Icons.location_on,
            ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Personal Details',
            fontSize: 18,
          ),
          const SizedBox(height: 16),
          InfoItem(
            label: 'First Name',
            value: patient.user['first_name'] ?? 'N/A',
          ),
          InfoItem(
            label: 'Last Name',
            value: patient.user['last_name'] ?? 'N/A',
          ),
          InfoItem(
            label: 'Gender',
            value: (patient.user['gender'] ?? 'N/A').toString(),
            icon: Icons.person,
          ),
          InfoItem(
            label: 'Date of Birth',
            value: patient.user['dob'] ?? 'N/A',
            icon: Icons.cake,
          ),
          InfoItem(
            label: 'Blood Group',
            value: patient.user['blood_group'] ?? 'N/A',
            icon: Icons.bloodtype,
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Account Information',
            fontSize: 18,
          ),
          const SizedBox(height: 16),
          InfoItem(
            label: 'Patient ID',
            value: patient.patientUniqueId,
            icon: Icons.badge,
          ),
          InfoItem(
            label: 'Status',
            value: (patient.user['status'] ?? 'active').toString(),
            icon: Icons.verified_user,
          ),
          InfoItem(
            label: 'Created At',
            value: _formatDate(patient.createdAt),
            icon: Icons.calendar_today,
          ),
          InfoItem(
            label: 'Updated At',
            value: _formatDate(patient.updatedAt),
            icon: Icons.update,
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSignsTab(BuildContext context, ColourNotifier notifier) {
    if (!patient.hasVitalSigns) {
      return _buildEmptyState(
        context: context,
        icon: Icons.favorite_outline,
        message: 'No vital signs recorded',
        notifier: notifier,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vital Signs Summary
          if (patient.vitalSignsSummary != null) ...[
            SectionHeader(
              title: 'Latest Vital Signs',
              fontSize: 18,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: notifier.getIconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: notifier.getIconColor.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: notifier.getIconColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Last recorded: ${patient.vitalSignsSummary!['last_recorded_date'] ?? patient.lastVitalSignsDate}',
                        style: TextStyle(
                          fontSize: 14,
                          color: notifier.getMainText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      _buildVitalSignSummaryCard(
                        'Blood Pressure',
                        patient.latestBloodPressure,
                        Icons.monitor_heart,
                        notifier,
                      ),
                      _buildVitalSignSummaryCard(
                        'Heart Rate',
                        patient.latestHeartRate,
                        Icons.favorite,
                        notifier,
                      ),
                      _buildVitalSignSummaryCard(
                        'Temperature',
                        patient.latestTemperature,
                        Icons.thermostat,
                        notifier,
                      ),
                      if (patient.vitalSignsSummary!['oxygen_saturation'] != null)
                        _buildVitalSignSummaryCard(
                          'Oxygen Saturation',
                          patient.vitalSignsSummary!['oxygen_saturation'],
                          Icons.air,
                          notifier,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Vital Signs History
          SectionHeader(
            title: 'Vital Signs History (${patient.vitalSignsCount} records)',
            fontSize: 18,
          ),
          const SizedBox(height: 16),

          ...patient.vitalSigns.map((vitalSign) =>
              _buildVitalSignItem(context, vitalSign, notifier)),
        ],
      ),
    );
  }

  Widget _buildVitalSignSummaryCard(
      String title,
      String value,
      IconData icon,
      ColourNotifier notifier,
      ) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: notifier.getContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: notifier.getBorderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: notifier.getIconColor,
            size: 20,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
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

  Widget _buildVitalSignItem(
      BuildContext context,
      Map<String, dynamic> vitalSign,
      ColourNotifier notifier,
      ) {
    final recordedBy = vitalSign['recorded_by'] ?? {};
    final recordedByName = recordedBy['name'] ?? 'Unknown';
    final recordedByType = recordedBy['type'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifier.getBgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: notifier.getBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date and recorded by
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                vitalSign['recorded_date'] ?? 'Unknown Date',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: notifier.getMainText,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    vitalSign['recorded_time'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: notifier.getMaingey,
                    ),
                  ),
                  Text(
                    'by $recordedByName${recordedByType.isNotEmpty ? ' ($recordedByType)' : ''}',
                    style: TextStyle(
                      fontSize: 10,
                      color: notifier.getMaingey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Vital signs in grid
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              _buildVitalSignDetail(
                'Blood Pressure',
                vitalSign['blood_pressure'] ?? 'N/A',
                Icons.monitor_heart,
                notifier,
              ),
              _buildVitalSignDetail(
                'Heart Rate',
                vitalSign['heart_rate'] ?? 'N/A',
                Icons.favorite,
                notifier,
              ),
              _buildVitalSignDetail(
                'Temperature',
                vitalSign['temperature'] ?? 'N/A',
                Icons.thermostat,
                notifier,
              ),
              _buildVitalSignDetail(
                'Respiratory Rate',
                vitalSign['respiratory_rate'] ?? 'N/A',
                Icons.air,
                notifier,
              ),
              _buildVitalSignDetail(
                'Oxygen Saturation',
                vitalSign['oxygen_saturation'] ?? 'N/A',
                Icons.opacity,
                notifier,
              ),
              _buildVitalSignDetail(
                'Weight',
                vitalSign['weight'] ?? 'N/A',
                Icons.monitor_weight,
                notifier,
              ),
              _buildVitalSignDetail(
                'Height',
                vitalSign['height'] ?? 'N/A',
                Icons.height,
                notifier,
              ),
              _buildVitalSignDetail(
                'BMI',
                vitalSign['bmi'] ?? 'N/A',
                Icons.calculate,
                notifier,
              ),
            ],
          ),

          // Notes if available
          if (vitalSign['notes'] != null && vitalSign['notes'].toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: notifier.getIconColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: notifier.getIconColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vitalSign['notes'],
                    style: TextStyle(
                      fontSize: 12,
                      color: notifier.getMainText,
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

  Widget _buildVitalSignDetail(
      String label,
      String value,
      IconData icon,
      ColourNotifier notifier,
      ) {
    return Container(
      width: 100,
      child: Row(
        children: [
          Icon(
            icon,
            size: 12,
            color: notifier.getIconColor,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    color: notifier.getMaingey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: notifier.getMainText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalRecordsTab(
      BuildContext context, ColourNotifier notifier) {
    // Sort documents by date if available
    final documents = [...patient.documents];
    documents.sort((a, b) {
      final aDate = a['created_at']?.toString() ?? '';
      final bDate = b['created_at']?.toString() ?? '';
      return bDate.compareTo(aDate); // Newest first
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Medical statistics summary
          SectionHeader(
            title: 'Medical Summary',
            fontSize: 18,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              _buildStatCard(
                context: context,
                title: 'Appointments',
                value: (patient.stats['appointments_count'] ?? 0).toString(),
                icon: Icons.calendar_today,
                notifier: notifier,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                context: context,
                title: 'Documents',
                value: (patient.stats['documents_count'] ?? 0).toString(),
                icon: Icons.description,
                notifier: notifier,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                context: context,
                title: 'Vital Signs',
                value: patient.vitalSignsCount.toString(),
                icon: Icons.favorite,
                notifier: notifier,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Medical documents
          SectionHeader(
            title: 'Medical Documents',
            fontSize: 18,
          ),
          const SizedBox(height: 16),

          if (documents.isEmpty)
            _buildEmptyState(
              context: context,
              icon: Icons.description_outlined,
              message: 'No medical documents available',
              notifier: notifier,
            )
          else
            ...documents
                .map((doc) => _buildDocumentItem(context, doc, notifier)),

          const SizedBox(height: 24),

          // Medical template info if present
          if (patient.template != null && patient.template!.isNotEmpty) ...[
            SectionHeader(
              title: 'Medical Information',
              fontSize: 18,
            ),
            const SizedBox(height: 16),
            ...patient.template!.entries.map((entry) {
              if (entry.value != null) {
                return InfoItem(
                  label: entry.key.toString().replaceAll('_', ' '),
                  value: entry.value.toString(),
                );
              } else {
                return const SizedBox.shrink();
              }
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab(BuildContext context, ColourNotifier notifier) {
    // Sort appointments by date if available
    final appointments = [...patient.appointments];
    appointments.sort((a, b) {
      final aDate = a['date']?.toString() ?? '';
      final bDate = b['date']?.toString() ?? '';
      return bDate.compareTo(aDate); // Newest first
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Appointments',
            fontSize: 18,
          ),
          const SizedBox(height: 16),
          if (appointments.isEmpty)
            _buildEmptyState(
              context: context,
              icon: Icons.calendar_today_outlined,
              message: 'No appointments available',
              notifier: notifier,
            )
          else
            ...appointments.map((appointment) =>
                _buildAppointmentItem(context, appointment, notifier)),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required ColourNotifier notifier,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notifier.getIconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: notifier.getIconColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: notifier.getIconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: notifier.getMainText,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: notifier.getMaingey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem(BuildContext context, Map<String, dynamic> document,
      ColourNotifier notifier) {
    final String title = document['title'] ?? 'Untitled Document';
    final String notes = document['notes'] ?? '';
    final String date = _formatDate(document['created_at'] ?? '');
    final bool hasFile = document['file_info'] != null &&
        document['file_info']['file_url'] != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifier.getBgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: notifier.getBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: notifier.getMainText,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasFile)
                IconButton(
                  icon: Icon(Icons.download, color: notifier.getIconColor),
                  onPressed: () {
                    // Download functionality would go here
                  },
                  tooltip: 'Download Document',
                ),
            ],
          ),
          if (date.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              date,
              style: TextStyle(
                color: notifier.getMaingey,
                fontSize: 12,
              ),
            ),
          ],
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              notes,
              style: TextStyle(
                color: notifier.getMainText,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(BuildContext context,
      Map<String, dynamic> appointment, ColourNotifier notifier) {
    final String doctorName = appointment['doctor_name'] ?? 'Unknown Doctor';
    final String date =
        appointment['date'] ?? appointment['opd_date'] ?? 'No date';
    final String time =
        appointment['time'] ?? appointment['appointment_time'] ?? 'No time';
    final bool isCompleted = appointment['is_completed'] == true;
    final String problem = appointment['problem'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifier.getBgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: notifier.getBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  doctorName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: notifier.getMainText,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusBadge(
                status: isCompleted ? 'completed' : 'pending',
                fontSize: 10,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: notifier.getMaingey),
              const SizedBox(width: 4),
              Text(
                date,
                style: TextStyle(
                  color: notifier.getMaingey,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 14, color: notifier.getMaingey),
              const SizedBox(width: 4),
              Text(
                time,
                style: TextStyle(
                  color: notifier.getMaingey,
                ),
              ),
            ],
          ),
          if (problem.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Problem: $problem',
              style: TextStyle(
                color: notifier.getMainText,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required BuildContext context,
    required IconData icon,
    required String message,
    required ColourNotifier notifier,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: notifier.getMaingey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: notifier.getMainText,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';

    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
}