import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/nurse_controller.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class NurseDetailDialog extends StatelessWidget {
  final Nurse nurse;

  const NurseDetailDialog({
    super.key,
    required this.nurse,
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
              length: 2,
              child: Column(
                children: [
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildPersonalInfoTab(context, notifier),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColourNotifier notifier) {
    final defaultImage =
        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(nurse.fullName)}&background=random';
    final imageUrl =
        nurse.profileImage.isNotEmpty ? nurse.profileImage : defaultImage;

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

          // Nurse information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Nurse ${nurse.fullName}',
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
                nurse.specialty.isNotEmpty
                    ? Text(
                        '${nurse.specialty} • ${nurse.department}',
                        style: TextStyle(
                          fontSize: 16,
                          color: notifier.getMaingey,
                        ),
                      )
                    : Text(
                        nurse.department,
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
                        color: _getStatusColor(nurse.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        nurse.status.capitalizeFirst!,
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
                        nurse.qualification,
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
          _buildInfoItem(context, 'Email', nurse.email, Icons.email, notifier),
          _buildInfoItem(context, 'Phone', nurse.phone, Icons.phone, notifier),
          const SizedBox(height: 20),
          _buildSectionHeader(context, 'Personal Details', notifier),
          _buildInfoItem(context, 'Gender', nurse.gender.capitalizeFirst!,
              Icons.person, notifier),
          _buildInfoItem(context, 'Blood Group', nurse.bloodGroup,
              Icons.bloodtype, notifier),
          _buildInfoItem(context, 'Date of Birth',
              nurse.user['dob'] ?? 'Not provided', Icons.cake, notifier),
          const SizedBox(height: 20),
          _buildSectionHeader(context, 'System Information', notifier),
          _buildInfoItem(context, 'Nurse ID', nurse.id, Icons.badge, notifier),
          _buildInfoItem(context, 'Created At', _formatDate(nurse.createdAt),
              Icons.event, notifier),
          _buildInfoItem(context, 'Last Updated', _formatDate(nurse.updatedAt),
              Icons.update, notifier),
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
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
