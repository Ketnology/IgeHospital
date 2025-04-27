import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/doctor_controller.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DoctorDetailDialog extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailDialog({
    super.key,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context, notifier),
    );
  }

  Widget contentBox(BuildContext context, ColourNotifier notifier) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: notifier.getContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: notifier.getBorderColor),
      ),
      child: Column(
        children: [
          // Header with image and basic info
          _buildHeader(context, notifier),

          // Detailed information in tabs
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    labelColor: notifier.getIconColor,
                    unselectedLabelColor: notifier.getMaingey,
                    indicatorColor: notifier.getIconColor,
                    tabs: const [
                      Tab(text: 'Personal Info'),
                      Tab(text: 'Professional'),
                      Tab(text: 'Schedule'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildPersonalInfoTab(context, notifier),
                        _buildProfessionalTab(context, notifier),
                        _buildScheduleTab(context, notifier),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer with actions
          _buildFooter(context, notifier),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColourNotifier notifier) {
    final defaultImage =
        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(doctor.fullName)}&background=random';
    final imageUrl =
        doctor.profileImage.isNotEmpty ? doctor.profileImage : defaultImage;

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
            backgroundImage: NetworkImage(imageUrl),
            onBackgroundImageError: (exception, stackTrace) =>
                const Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 20),

          // Doctor information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Dr. ${doctor.fullName}',
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
                  '${doctor.specialty} • ${doctor.department}',
                  style: TextStyle(
                    fontSize: 16,
                    color: notifier.getMaingey,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10, // Horizontal space between items
                  runSpacing: 5, // Vertical space between lines
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _getStatusColor(doctor.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        doctor.status.capitalizeFirst!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: notifier.getIconColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        doctor.qualification,
                        style: TextStyle(
                          color: notifier.getIconColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
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
          _buildSectionHeader(context, 'Contact Information', notifier),
          _buildInfoItem(context, 'Email', doctor.email, Icons.email, notifier),
          _buildInfoItem(context, 'Phone', doctor.phone, Icons.phone, notifier),
          const SizedBox(height: 20),
          _buildSectionHeader(context, 'Personal Details', notifier),
          _buildInfoItem(context, 'Gender', doctor.gender.capitalizeFirst!,
              Icons.person, notifier),
          _buildInfoItem(context, 'Blood Group', doctor.bloodGroup,
              Icons.bloodtype, notifier),
          _buildInfoItem(context, 'Date of Birth',
              doctor.user['dob'] ?? 'Not provided', Icons.cake, notifier),
          const SizedBox(height: 20),
          _buildSectionHeader(context, 'System Information', notifier),
          _buildInfoItem(
              context, 'Doctor ID', doctor.id, Icons.badge, notifier),
          _buildInfoItem(context, 'Created At', _formatDate(doctor.createdAt),
              Icons.event, notifier),
          _buildInfoItem(context, 'Last Updated', _formatDate(doctor.updatedAt),
              Icons.update, notifier),
        ],
      ),
    );
  }

  Widget _buildProfessionalTab(BuildContext context, ColourNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'Professional Summary', notifier),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              doctor.description,
              style: TextStyle(
                color: notifier.getMainText,
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader(context, 'Specialization', notifier),
          _buildInfoItem(context, 'Department', doctor.department,
              Icons.business, notifier),
          _buildInfoItem(context, 'Specialty', doctor.specialty,
              Icons.local_hospital, notifier),
          _buildInfoItem(context, 'Qualification', doctor.qualification,
              Icons.school, notifier),
          const SizedBox(height: 20),
          _buildSectionHeader(context, 'Appointments Statistics', notifier),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                    context,
                    'Total Appointments',
                    doctor.stats['appointments_count']?.toString() ?? '0',
                    Icons.calendar_today,
                    notifier),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                    context,
                    'Active Schedules',
                    doctor.stats['schedules_count']?.toString() ?? '0',
                    Icons.schedule,
                    notifier),
              ),
            ],
          ),
          if (doctor.appointments.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildSectionHeader(context, 'Recent Appointments', notifier),
            ...doctor.appointments
                .take(3)
                .map((app) => _buildAppointmentItem(context, app, notifier))
                .toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleTab(BuildContext context, ColourNotifier notifier) {
    final schedules = doctor.schedules;

    if (schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: notifier.getMaingey,
            ),
            const SizedBox(height: 16),
            Text(
              'No schedules available',
              style: TextStyle(
                fontSize: 18,
                color: notifier.getMainText,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'Weekly Schedule', notifier),

          const SizedBox(height: 10),

          // Schedule table
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: notifier.getBorderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                // Table header
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: notifier.getIconColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Day',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: notifier.getIconColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Hours',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: notifier.getIconColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Per Patient',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: notifier.getIconColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                // Schedule rows
                ...schedules.map((schedule) {
                  // Extract schedule days
                  final scheduleDays =
                      schedule['schedule_days'] as List<dynamic>? ?? [];
                  if (scheduleDays.isEmpty) return const SizedBox.shrink();

                  return Column(
                    children: scheduleDays.map((day) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: notifier.getBorderColor),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                day['available_on'] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: notifier.getMainText,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                '${_formatTime(day['available_from'] ?? '')} - ${_formatTime(day['available_to'] ?? '')}',
                                style: TextStyle(
                                  color: notifier.getMainText,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: notifier.getIconColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _formatTime(
                                      schedule['per_patient_time'] ?? ''),
                                  style: TextStyle(
                                    color: notifier.getIconColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ],
            ),
          ),

          const SizedBox(height: 30),

          _buildSectionHeader(context, 'Upcoming Appointments', notifier),

          // Show recent appointments
          if (doctor.appointments.isNotEmpty) ...[
            ...doctor.appointments
                .where((app) => app['is_completed'] == false)
                .take(5)
                .map((app) => _buildAppointmentItem(context, app, notifier))
                .toList(),
          ] else ...[
            // A message if no upcoming appointments
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: notifier.getBgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: notifier.getBorderColor),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: notifier.getMaingey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No upcoming appointments scheduled',
                      style: TextStyle(color: notifier.getMaingey),
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

  Widget _buildFooter(BuildContext context, ColourNotifier notifier) {
    return Container(
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
            onPressed: () {},
            icon: Icon(Icons.calendar_today, color: notifier.getIconColor),
            label: Text('Manage Schedule',
                style: TextStyle(color: notifier.getIconColor)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              side: BorderSide(color: notifier.getIconColor),
            ),
          ),
          // const SizedBox(width: 12),
          // ElevatedButton.icon(
          //   onPressed: () {
          //     Navigator.pop(context, 'edit');
          //   },
          //   icon: const Icon(Icons.edit, color: Colors.white),
          //   label: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: appMainColor,
          //     foregroundColor: Colors.white,
          //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, ColourNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: notifier.getIconColor,
          ),
        ),
        const SizedBox(height: 5),
        Divider(color: notifier.getBorderColor),
      ],
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value,
      IconData icon, ColourNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: notifier.getMaingey,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              label,
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

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, ColourNotifier notifier) {
    return Container(
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
            children: [
              Icon(icon, color: notifier.getIconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: notifier.getMaingey,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: notifier.getMainText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(BuildContext context,
      Map<String, dynamic> appointment, ColourNotifier notifier) {
    final isCompleted = appointment['is_completed'] == true;
    final patientName = appointment['patient_name'] ?? 'Unknown Patient';
    final date =
        appointment['appointment_date'] ?? appointment['date'] ?? 'No date';
    final time =
        appointment['appointment_time'] ?? appointment['time'] ?? 'No time';
    final problem = appointment['problem'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  patientName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: notifier.getMainText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isCompleted ? 'COMPLETED' : 'PENDING',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today,
                      size: 14, color: notifier.getMaingey),
                  const SizedBox(width: 4),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 14,
                      color: notifier.getMaingey,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time, size: 14, color: notifier.getMaingey),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 14,
                      color: notifier.getMaingey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (problem.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Problem: $problem',
              style: TextStyle(
                fontSize: 14,
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatTime(String timeString) {
    if (timeString.isEmpty) return '';

    try {
      // Check if it's a full datetime or just time
      if (timeString.contains('T')) {
        final date = DateTime.parse(timeString);
        return DateFormat('hh:mm a').format(date);
      } else {
        // Handle time format like "15:30:00"
        final parts = timeString.split(':');
        if (parts.length >= 2) {
          final hour = int.tryParse(parts[0]) ?? 0;
          final minute = int.tryParse(parts[1]) ?? 0;

          return DateFormat('hh:mm a')
              .format(DateTime(2022, 1, 1, hour, minute));
        }
        return timeString;
      }
    } catch (e) {
      return timeString;
    }
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
}
