import 'package:flutter/material.dart';
import 'package:ige_hospital/models/patient_model.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/common_button.dart';
import 'dart:math';

class PatientDetailDialog extends StatelessWidget {
  final PatientModel patient;
  final ColourNotifier notifier;

  const PatientDetailDialog({
    super.key,
    required this.patient,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
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
                  child: patient.user['profile_image'] != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      patient.user['profile_image'],
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

                // Patient Name and Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.user['full_name'] ?? 'N/A',
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
                              color: _getStatusColor(
                                  patient.user['status'] ?? 'active'),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              patient.user['status']?.toUpperCase() ?? 'N/A',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "ID: ${patient.patientUniqueId}",
                            style: TextStyle(
                              color: notifier.getMainText,
                              fontSize: 14,
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

            // Patient details
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Information
                    _sectionTitle("Personal Information", notifier),
                    _detailRow("First Name", patient.user['first_name'], notifier),
                    _detailRow("Middle Name", patient.user['middle_name'] ?? 'N/A', notifier),
                    _detailRow("Last Name", patient.user['last_name'], notifier),
                    _detailRow("Email", patient.user['email'] ?? 'N/A', notifier),
                    _detailRow("Phone", patient.user['phone'] ?? 'N/A', notifier),
                    _detailRow("Gender", patient.user['gender'] ?? 'N/A', notifier),
                    _detailRow("Date of Birth", patient.user['dob'] ?? 'N/A', notifier),
                    _detailRow(
                        "Blood Group", patient.user['blood_group'] ?? 'N/A', notifier),

                    const SizedBox(height: 20),

                    // Medical Information
                    _sectionTitle("Medical Information", notifier),
                    _detailRow("Appointments",
                        "${patient.stats['appointments_count'] ?? '0'} total", notifier),
                    _detailRow("Documents",
                        "${patient.stats['documents_count'] ?? '0'} total", notifier),

                    const SizedBox(height: 20),

                    // Address (if available)
                    if (patient.address != null) ...[
                      // _sectionTitle("Address", notifier),
                      _detailRow(
                          "Address", patient.address!['address1'] ?? 'N/A', notifier),
                      // _detailRow("City", patient.address!['city'] ?? 'N/A', notifier),
                      // _detailRow("State", patient.address!['state'] ?? 'N/A', notifier),
                      // _detailRow("Zip Code", patient.address!['zip'] ?? 'N/A', notifier),
                      // _detailRow("Country", patient.address!['country'] ?? 'N/A', notifier),
                      const SizedBox(height: 20),
                    ],

                    // Documents
                    if (patient.documents.isNotEmpty) ...[
                      _sectionTitle("Recent Documents", notifier),
                      ...patient.documents
                          .take(3)
                          .map((doc) => _documentItem(doc, notifier)),
                      if (patient.documents.length > 3)
                        TextButton(
                          onPressed: () {
                            // View all documents
                          },
                          child: Text(
                            "View all ${patient.documents.length} documents",
                            style: TextStyle(color: notifier.getIconColor),
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],

                    // Appointments
                    if (patient.appointments.isNotEmpty) ...[
                      _sectionTitle("Recent Appointments", notifier),
                      ...patient.appointments.take(3).map(
                              (appointment) => _appointmentItem(appointment, notifier)),
                      if (patient.appointments.length > 3)
                        TextButton(
                          onPressed: () {
                            // View all appointments
                          },
                          child: Text(
                            "View all ${patient.appointments.length} appointments",
                            style: TextStyle(color: notifier.getIconColor),
                          ),
                        ),
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
                  title: "Edit Patient",
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

  Widget _sectionTitle(String title, ColourNotifier notifier) {
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

  Widget _detailRow(String label, String value, ColourNotifier notifier) {
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

  Widget _documentItem(Map<String, dynamic> document, ColourNotifier notifier) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: notifier.getBgColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: notifier.getBorderColor),
      ),
      child: ListTile(
        title: Text(
          document['title'] ?? 'Untitled Document',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: notifier.getMainText,
          ),
        ),
        subtitle: Text(
          document['notes'] != null
              ? '${document['notes'].toString().substring(
              0, min(50, document['notes'].toString().length))}...'
              : 'No notes',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: notifier.getMaingey),
        ),
        trailing: document['file_info']?['file_url'] != null
            ? IconButton(
          icon: Icon(Icons.download, color: notifier.getIconColor),
          onPressed: () {
            // Download document
          },
        )
            : null,
      ),
    );
  }

  Widget _appointmentItem(Map<String, dynamic> appointment, ColourNotifier notifier) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: notifier.getBgColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: notifier.getBorderColor),
      ),
      child: ListTile(
        dense: true,
        title: Text(
          appointment['doctor_name'] ?? 'Doctor',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: notifier.getMainText,
          ),
        ),
        subtitle: Text(
          "${appointment['date'] ?? 'N/A'} at ${appointment['time'] ?? 'N/A'}",
          style: TextStyle(color: notifier.getMaingey),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: appointment['is_completed'] == true
                ? Colors.green
                : Colors.orange,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            appointment['is_completed'] == true ? 'COMPLETED' : 'PENDING',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}