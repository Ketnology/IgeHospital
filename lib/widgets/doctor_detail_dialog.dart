import 'package:flutter/material.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/provider/doctor_service.dart';
import 'package:ige_hospital/widgets/common_button.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:intl/intl.dart';

class DoctorDetailDialog extends StatelessWidget {
  final DoctorModel doctor;
  final ColourNotifier notifier;

  const DoctorDetailDialog({
    super.key,
    required this.doctor,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    // Format dates if they're available
    String createdAtFormatted = 'N/A';
    String updatedAtFormatted = 'N/A';

    try {
      if (doctor.createdAt.isNotEmpty) {
        final createdDate = DateTime.parse(doctor.createdAt);
        createdAtFormatted = DateFormat('MMM dd, yyyy').format(createdDate);
      }
      if (doctor.updatedAt.isNotEmpty) {
        final updatedDate = DateTime.parse(doctor.updatedAt);
        updatedAtFormatted = DateFormat('MMM dd, yyyy').format(updatedDate);
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
                  child: doctor.profileImage.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      doctor.profileImage,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(
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

                // Doctor Name and Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Dr. ${doctor.fullName}",
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
                              color: _getStatusColor(doctor.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              doctor.status.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
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
                              doctor.specialist,
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

            // Doctor details
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Information
                    _sectionTitle("Personal Information"),
                    _detailRow("Department", doctor.departmentName),
                    _detailRow("Specialist", doctor.specialist),
                    _detailRow("Email", doctor.email),
                    _detailRow("Phone", doctor.phone),
                    _detailRow("Gender", doctor.gender),
                    _detailRow("Qualification", doctor.qualification),
                    _detailRow("ID", doctor.id),
                    _detailRow("User ID", doctor.userId),
                    _detailRow("Registration Date", createdAtFormatted),
                    _detailRow("Last Updated", updatedAtFormatted),

                    const SizedBox(height: 20),

                    // Description section
                    _sectionTitle("Description"),
                    Text(
                      doctor.description,
                      style: TextStyle(
                        color: notifier.getMainText,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Department details
                    if (doctor.department.isNotEmpty) ...[
                      _sectionTitle("Department Details"),
                      _detailRow("Department ID", doctor.doctorDepartmentId),
                      _detailRow("Department Name", doctor.departmentName),
                      if (doctor.department['description'] != null)
                        _detailRow("Description", doctor.department['description']),
                      const SizedBox(height: 20),
                    ],

                    // More detailed doctor information from the user object
                    if (doctor.user.isNotEmpty &&
                        (doctor.user['blood_group'] != null || doctor.user['address'] != null)) ...[
                      _sectionTitle("Additional Information"),
                      if (doctor.user['blood_group'] != null)
                        _detailRow("Blood Group", doctor.user['blood_group']),
                      if (doctor.user['dob'] != null)
                        _detailRow("Date of Birth", doctor.user['dob']),
                      if (doctor.user['address'] != null)
                        _detailRow("Address", doctor.user['address']),
                    ],
                  ],
                ),
              ),
            ),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CommonButton(
                  title: "Edit Doctor",
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
            width: 120,
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