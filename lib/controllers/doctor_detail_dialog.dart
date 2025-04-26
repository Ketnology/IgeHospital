import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/controllers/doctor_controller.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:provider/provider.dart';

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
            backgroundImage: NetworkImage(doctor.profileImage),
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

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _getStatusColor(doctor.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        doctor.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
          _buildInfoItem(context, 'Gender', doctor.gender, Icons.person, notifier),
          _buildInfoItem(context, 'Blood Group', doctor.bloodGroup, Icons.bloodtype, notifier),

          const SizedBox(height: 20),

          _buildSectionHeader(context, 'System Information', notifier),
          _buildInfoItem(context, 'Doctor ID', doctor.id, Icons.badge, notifier),
          _buildInfoItem(context, 'Created At', doctor.createdAt, Icons.event, notifier),
          _buildInfoItem(context, 'Last Updated', doctor.updatedAt, Icons.update, notifier),
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
          _buildInfoItem(context, 'Department', doctor.department, Icons.business, notifier),
          _buildInfoItem(context, 'Specialty', doctor.specialty, Icons.local_hospital, notifier),
          _buildInfoItem(context, 'Qualification', doctor.qualification, Icons.school, notifier),

          const SizedBox(height: 20),

          _buildSectionHeader(context, 'Achievements & Awards', notifier),
          _buildAchievement(
            context,
            title: 'Best Doctor Award',
            organization: 'IGE Hospital',
            year: '2023',
            notifier: notifier,
          ),
          _buildAchievement(
            context,
            title: 'Research Publication',
            organization: 'Medical Journal of Research',
            year: '2022',
            notifier: notifier,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab(BuildContext context, ColourNotifier notifier) {
    // Dummy schedule data
    List<Map<String, dynamic>> schedule = [
      {
        'day': 'Monday',
        'start': '09:00 AM',
        'end': '04:00 PM',
        'patients': 12,
      },
      {
        'day': 'Tuesday',
        'start': '10:00 AM',
        'end': '06:00 PM',
        'patients': 15,
      },
      {
        'day': 'Wednesday',
        'start': '09:00 AM',
        'end': '05:00 PM',
        'patients': 10,
      },
      {
        'day': 'Thursday',
        'start': '09:00 AM',
        'end': '04:00 PM',
        'patients': 14,
      },
      {
        'day': 'Friday',
        'start': '10:00 AM',
        'end': '03:00 PM',
        'patients': 8,
      },
    ];

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
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                          'Patients',
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

                // Table rows
                ...schedule.map((item) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                          item['day'],
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: notifier.getMainText,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          '${item['start']} - ${item['end']}',
                          style: TextStyle(
                            color: notifier.getMainText,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: notifier.getIconColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${item['patients']} patients',
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
                )).toList(),
              ],
            ),
          ),

          const SizedBox(height: 30),

          _buildSectionHeader(context, 'Upcoming Appointments', notifier),

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
                    'No upcoming appointments scheduled for today',
                    style: TextStyle(color: notifier.getMaingey),
                  ),
                ),
              ],
            ),
          ),
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
            onPressed: () {
              Navigator.pop(context);
              Get.snackbar(
                'Feature Coming Soon',
                'Schedule management will be available in the next update',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            icon: Icon(Icons.calendar_today, color: notifier.getIconColor),
            label: Text('Manage Schedule', style: TextStyle(color: notifier.getIconColor)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              side: BorderSide(color: notifier.getIconColor),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // This would typically navigate to the edit screen
              Get.snackbar(
                'Edit Doctor',
                'Editing Dr. ${doctor.fullName}',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: appMainColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, ColourNotifier notifier) {
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

  Widget _buildInfoItem(BuildContext context, String label, String value, IconData icon, ColourNotifier notifier) {
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

  Widget _buildAchievement(
      BuildContext context, {
        required String title,
        required String organization,
        required String year,
        required ColourNotifier notifier,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: notifier.getBgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: notifier.getBorderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: notifier.getIconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.emoji_events,
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
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: notifier.getMainText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  organization,
                  style: TextStyle(
                    color: notifier.getMainText,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  year,
                  style: TextStyle(
                    color: notifier.getMaingey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
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
}