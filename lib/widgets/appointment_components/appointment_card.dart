import 'package:flutter/material.dart';
import 'package:ige_hospital/models/appointment_model.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onView,
    this.onEdit,
    this.onDelete,
  });

  Color _getStatusColor() {
    if (appointment.isCompleted) {
      return Colors.green;
    } else {
      // Check if appointment is today or overdue
      try {
        final appointmentDate = DateTime.parse(appointment.appointmentDate);
        final today = DateTime.now();

        if (appointmentDate.isBefore(DateTime(today.year, today.month, today.day))) {
          return Colors.red; // Overdue
        } else if (appointmentDate.isAtSameMomentAs(DateTime(today.year, today.month, today.day))) {
          return Colors.orange; // Today
        } else {
          return Colors.blue; // Future
        }
      } catch (e) {
        return Colors.grey;
      }
    }
  }

  String _getStatusText() {
    if (appointment.isCompleted) {
      return 'Completed';
    } else {
      try {
        final appointmentDate = DateTime.parse(appointment.appointmentDate);
        final today = DateTime.now();

        if (appointmentDate.isBefore(DateTime(today.year, today.month, today.day))) {
          return 'Overdue';
        } else if (appointmentDate.isAtSameMomentAs(DateTime(today.year, today.month, today.day))) {
          return 'Today';
        } else {
          return 'Scheduled';
        }
      } catch (e) {
        return 'Pending';
      }
    }
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
    try {
      // Assuming timeString is in HH:mm format
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final time = DateTime(2023, 1, 1, hour, minute);
        return DateFormat('hh:mm a').format(time);
      }
      return timeString;
    } catch (e) {
      return timeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);
    final statusColor = _getStatusColor();
    final statusText = _getStatusText();

    return Container(
      decoration: BoxDecoration(
        color: notifier.getContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifier.getBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onView,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    // Action buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onEdit != null)
                          IconButton(
                            onPressed: onEdit,
                            icon: Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: Colors.blue,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            tooltip: 'Edit',
                          ),
                        if (onDelete != null)
                          IconButton(
                            onPressed: onDelete,
                            icon: Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            tooltip: 'Delete',
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Doctor information
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: appMainColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.medical_services,
                        color: appMainColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dr. ${appointment.doctorName}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: notifier.getMainText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (appointment.doctorDepartment.isNotEmpty)
                            Text(
                              appointment.doctorDepartment,
                              style: TextStyle(
                                color: notifier.getMaingey,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Patient information
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: notifier.getBgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: notifier.getBorderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: notifier.getMaingey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          appointment.patientName,
                          style: TextStyle(
                            color: notifier.getMainText,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Date and time
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: notifier.getMaingey,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _formatDate(appointment.appointmentDate),
                              style: TextStyle(
                                color: notifier.getMainText,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_outlined,
                            size: 16,
                            color: notifier.getMaingey,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _formatTime(appointment.appointmentTime),
                              style: TextStyle(
                                color: notifier.getMainText,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Problem/Reason
                if (appointment.problem.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: notifier.getIconColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: notifier.getIconColor.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Problem/Reason:',
                          style: TextStyle(
                            color: notifier.getMaingey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.problem,
                          style: TextStyle(
                            color: notifier.getMainText,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Footer with view button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ID: ${appointment.id.length > 8 ? appointment.id.substring(0, 8) : appointment.id}',
                      style: TextStyle(
                        color: notifier.getMaingey,
                        fontSize: 11,
                      ),
                    ),
                    TextButton(
                      onPressed: onView,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'View Details',
                        style: TextStyle(
                          color: appMainColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}