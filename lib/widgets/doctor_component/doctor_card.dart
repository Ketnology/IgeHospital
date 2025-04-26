import 'package:flutter/material.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:provider/provider.dart';
import 'package:ige_hospital/controllers/doctor_controller.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    // Generate a default image URL if none provided
    final defaultImage = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(doctor.fullName)}&background=random';
    final imageUrl = doctor.profileImage.isNotEmpty ? doctor.profileImage : defaultImage;

    return Card(
      elevation: 3,
      color: notifier.getContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: notifier.getBorderColor),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 400, // Set a minimum height that works for your layout
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Image and Status
              Stack(
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) => const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
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
                  ),
                ],
              ),

              // Doctor Information
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Department
                    Text(
                      'Dr. ${doctor.fullName}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: notifier.getMainText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${doctor.specialty} • ${doctor.department}',
                            style: TextStyle(
                              color: notifier.getMaingey,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // Contact Information
                    _buildContactItem(
                      context,
                      Icons.email_outlined,
                      doctor.email,
                      notifier,
                    ),
                    const SizedBox(height: 8),
                    _buildContactItem(
                      context,
                      Icons.phone_outlined,
                      doctor.phone,
                      notifier,
                    ),

                    const SizedBox(height: 20),

                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatDisplay(
                          context,
                          'Appointments',
                          doctor.stats['appointments_count']?.toString() ?? '0',
                          Icons.calendar_month_outlined,
                          notifier,
                        ),
                        _buildStatDisplay(
                          context,
                          'Schedules',
                          doctor.stats['schedules_count']?.toString() ?? '0',
                          Icons.schedule_outlined,
                          notifier,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          context,
                          label: 'View',
                          icon: Icons.visibility_outlined,
                          color: notifier.getIconColor,
                          onPressed: onView,
                        ),
                        _buildActionButton(
                          context,
                          label: 'Edit',
                          icon: Icons.edit_outlined,
                          color: Colors.blue,
                          onPressed: onEdit,
                        ),
                        _buildActionButton(
                          context,
                          label: 'Delete',
                          icon: Icons.delete_outline,
                          color: const Color(0xfff73164), // Error color
                          onPressed: onDelete,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, IconData icon, String text,
      ColourNotifier notifier) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: notifier.getMaingey,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: notifier.getMainText,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDisplay(
      BuildContext context,
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

  Widget _buildActionButton(
      BuildContext context, {
        required String label,
        required IconData icon,
        required Color color,
        required VoidCallback onPressed,
      }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 22,
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'blocked':
        return const Color(0xfff73164); // Using existing error color
      case 'pending':
        return Colors.orange;
      default:
        return appMainColor; // Using main app color
    }
  }
}