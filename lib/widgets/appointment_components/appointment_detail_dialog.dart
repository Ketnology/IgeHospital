import 'package:flutter/material.dart';
import 'package:ige_hospital/models/appointment_model.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/common_button.dart';
import 'package:intl/intl.dart';

class AppointmentDetailDialog extends StatelessWidget {
  final AppointmentModel appointment;
  final ColourNotifier notifier;

  const AppointmentDetailDialog({
    super.key,
    required this.appointment,
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
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Appointment Details",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: notifier.getMainText,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: notifier.getIconColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 20),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Appointment Status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: appointment.isCompleted ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        appointment.isCompleted ? "COMPLETED" : "PENDING",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Doctor & Patient Information
                    _buildSectionTitle("Appointment Participants"),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            title: "Doctor",
                            name: appointment.doctorName,
                            department: appointment.doctorDepartment,
                            imageUrl: appointment.doctorImage,
                            icon: Icons.medical_services,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildInfoCard(
                            title: "Patient",
                            name: appointment.patientName,
                            department: "",
                            imageUrl: appointment.patientImage,
                            icon: Icons.person,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Appointment Details
                    _buildSectionTitle("Appointment Details"),
                    _buildDetailRow("Date", appointment.appointmentDate, Icons.calendar_today),
                    _buildDetailRow("Time", appointment.appointmentTime, Icons.access_time),
                    _buildDetailRow("Problem", appointment.problem, Icons.warning_amber),
                    // _buildDetailRow("Priority", appointment.customField ?? "Medium", Icons.flag),
                    _buildDetailRow("Created", _formatDate(appointment.createdAt), Icons.create),
                    _buildDetailRow("Updated", _formatDate(appointment.updatedAt), Icons.update),
                    const SizedBox(height: 20),

                    // // System Information
                    // _buildSectionTitle("System Information"),
                    // _buildDetailRow("Appointment ID", appointment.id, Icons.tag),
                    // _buildDetailRow("Doctor ID", appointment.doctorId, Icons.person_pin),
                    // _buildDetailRow("Patient ID", appointment.patientId, Icons.assignment_ind),
                    // _buildDetailRow("Department ID", appointment.departmentId, Icons.business),
                  ],
                ),
              ),
            ),

            // Action buttons
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CommonButton(
                  title: "Edit",
                  color: Colors.blue,
                  onTap: () => Navigator.pop(context, 'edit'),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: notifier.getMainText,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: notifier.getIconColor,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
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

  String _formatDate(String dateString) {
    try {
      if (dateString.isNotEmpty) {
        final DateTime parsedDate = DateTime.parse(dateString);
        return DateFormat('MMM dd, yyyy hh:mm a').format(parsedDate);
      }
    } catch (e) {
      print("Error parsing date: $e");
    }
    return dateString;
  }

  Widget _buildInfoCard({
    required String title,
    required String name,
    required String department,
    required String? imageUrl,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: notifier.getPrimaryColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: notifier.getBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: notifier.getMainText,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: notifier.getIconColor.withOpacity(0.1),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    imageUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      icon,
                      color: notifier.getIconColor,
                    ),
                  ),
                )
                    : Icon(
                  icon,
                  color: notifier.getIconColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: notifier.getMainText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (department.isNotEmpty)
                      Text(
                        department,
                        style: TextStyle(
                          fontSize: 12,
                          color: notifier.getMaingey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}