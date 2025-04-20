import 'package:flutter/material.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/provider/nurse_service.dart';
import 'package:ige_hospital/widgets/common_button.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:intl/intl.dart';

class NurseDetailDialog extends StatelessWidget {
  final NurseModel nurse;
  final ColourNotifier notifier;

  const NurseDetailDialog({
    super.key,
    required this.nurse,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    // Format dates if they're available
    String createdAtFormatted = 'N/A';
    String updatedAtFormatted = 'N/A';
    String dobFormatted = 'N/A';

    try {
      if (nurse.createdAt.isNotEmpty) {
        final createdDate = DateTime.parse(nurse.createdAt);
        createdAtFormatted = DateFormat('MMM dd, yyyy').format(createdDate);
      }
      if (nurse.updatedAt.isNotEmpty) {
        final updatedDate = DateTime.parse(nurse.updatedAt);
        updatedAtFormatted = DateFormat('MMM dd, yyyy').format(updatedDate);
      }
      if (nurse.user['dob'] != null && nurse.user['dob'].toString().isNotEmpty) {
        final dobDate = DateTime.parse(nurse.user['dob']);
        dobFormatted = DateFormat('MMM dd, yyyy').format(dobDate);
      }
    } catch (e) {
      print("Error parsing dates: $e");
    }

    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: notifier.getContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content: Container(
        width: 600,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Profile Image
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade200,
                  child: nurse.profileImage.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      nurse.profileImage,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
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

                // Nurse Name and Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nurse ${nurse.fullName}",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: notifier.getMainText,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(nurse.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              nurse.status.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (nurse.specialty != null && nurse.specialty!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                nurse.specialty!,
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Close button
                IconButton(
                  icon: Icon(Icons.close, color: notifier.getIconColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 30),

            // Nurse details
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Information
                    _sectionTitle("Personal Information"),
                    _detailRow("First Name", nurse.user['first_name'] ?? 'N/A'),
                    _detailRow("Last Name", nurse.user['last_name'] ?? 'N/A'),
                    _detailRow("Email", nurse.email),
                    _detailRow("Phone", nurse.phone),
                    _detailRow("Gender", nurse.gender),
                    _detailRow("Date of Birth", dobFormatted),
                    _detailRow("Blood Group", nurse.user['blood_group'] ?? 'N/A'),

                    const SizedBox(height: 20),

                    // Professional Information
                    _sectionTitle("Professional Information"),
                    _detailRow("Department", nurse.departmentName),
                    _detailRow("Specialty", nurse.specialty ?? 'Not Specified'),
                    _detailRow("Qualification", nurse.qualification),
                    _detailRow("ID", nurse.id),
                    _detailRow("User ID", nurse.userId),
                    _detailRow("Registration Date", createdAtFormatted),
                    _detailRow("Last Updated", updatedAtFormatted),
                  ],
                ),
              ),
            ),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CommonButton(
                  title: "Edit Nurse",
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context, 'edit');
                  },
                ),
                const SizedBox(width: 10),
                CommonButton(
                  title: "Close",
                  color: Colors.grey,
                  onTap: () => Navigator.pop(context),
                ),
              ],
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: notifier.getMainText,
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: notifier.getMainText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: notifier.getMainText),
            ),
          ),
        ],
      ),
    );
  }
}