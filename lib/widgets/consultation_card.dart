import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/consultation_controller.dart';
import 'package:ige_hospital/models/consultation_model.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/consultation_status_badge.dart';
import 'package:provider/provider.dart';

class ConsultationCard extends StatelessWidget {
  final LiveConsultation consultation;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onJoin;
  final VoidCallback? onStart;
  final VoidCallback? onEnd;
  final bool isCompact;

  const ConsultationCard({
    super.key,
    required this.consultation,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onJoin,
    this.onStart,
    this.onEnd,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);
    final consultationController = Get.find<ConsultationController>();

    return Card(
      elevation: 2,
      color: notifier.getContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: notifier.getBorderColor, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      consultation.consultationTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isCompact ? 16 : 18,
                        color: notifier.getMainText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ConsultationStatusBadge(statusInfo: consultation.statusInfo),
                ],
              ),

              const SizedBox(height: 16),

              // Type and meeting info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: consultationController.getTypeColor(consultation.type).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: consultationController.getTypeColor(consultation.type).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getTypeIcon(consultation.type),
                          size: 14,
                          color: consultationController.getTypeColor(consultation.type),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          consultation.type.capitalizeFirst ?? consultation.type,
                          style: TextStyle(
                            color: consultationController.getTypeColor(consultation.type),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: notifier.getIconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: notifier.getIconColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${consultation.consultationDurationMinutes} min',
                          style: TextStyle(
                            fontSize: 11,
                            color: notifier.getIconColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Date and time card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: notifier.getBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: notifier.getBorderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: notifier.getIconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: notifier.getIconColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            consultation.dateHuman,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: notifier.getMainText,
                            ),
                          ),
                          if (consultation.timeUntilConsultation != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              consultation.timeUntilConsultation!,
                              style: TextStyle(
                                fontSize: 12,
                                color: notifier.getIconColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (consultation.statusInfo.isUpcoming)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Upcoming',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              if (!isCompact) ...[
                const SizedBox(height: 16),

                // Participants info
                _buildParticipantInfo(notifier),

                const SizedBox(height: 20),

                // Action buttons
                _buildActionButtons(context, notifier),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantInfo(ColourNotifier notifier) {
    return Row(
      children: [
        Expanded(
          child: _buildPersonCard(
            'Doctor',
            'Dr. ${consultation.doctor.name}',
            consultation.doctor.specialist,
            Icons.medical_services,
            Colors.blue,
            notifier,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPersonCard(
            'Patient',
            consultation.patient.name,
            consultation.patient.patientUniqueId,
            Icons.person,
            Colors.green,
            notifier,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonCard(
      String role,
      String name,
      String subtitle,
      IconData icon,
      Color accentColor,
      ColourNotifier notifier,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: accentColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  role,
                  style: TextStyle(
                    fontSize: 11,
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: notifier.getMainText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: notifier.getMaingey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ColourNotifier notifier) {
    List<Widget> buttons = [];

    // Join button - highest priority
    if (consultation.permissions.canJoin && consultation.statusInfo.isActive) {
      buttons.add(
        _buildPrimaryActionButton(
          label: 'Join Meeting',
          icon: Icons.video_call,
          color: Colors.green,
          onPressed: onJoin,
        ),
      );
    }

    // Start button (for doctors)
    else if (consultation.permissions.canStart) {
      buttons.add(
        _buildPrimaryActionButton(
          label: 'Start Meeting',
          icon: Icons.play_arrow,
          color: Colors.blue,
          onPressed: onStart,
        ),
      );
    }

    // End button (for doctors)
    else if (consultation.permissions.canEnd) {
      buttons.add(
        _buildPrimaryActionButton(
          label: 'End Meeting',
          icon: Icons.stop,
          color: Colors.red,
          onPressed: onEnd,
        ),
      );
    }

    // Secondary actions row
    List<Widget> secondaryActions = [];

    if (consultation.permissions.canEdit) {
      secondaryActions.add(
        _buildSecondaryActionButton(
          label: 'Edit',
          icon: Icons.edit_outlined,
          color: notifier.getIconColor,
          onPressed: onEdit,
        ),
      );
    }

    if (consultation.permissions.canDelete) {
      secondaryActions.add(
        _buildSecondaryActionButton(
          label: 'Delete',
          icon: Icons.delete_outline,
          color: Colors.red,
          onPressed: onDelete,
        ),
      );
    }

    // View details button (always available)
    secondaryActions.add(
      _buildSecondaryActionButton(
        label: 'Details',
        icon: Icons.info_outline,
        color: notifier.getIconColor,
        onPressed: onTap,
      ),
    );

    return Column(
      children: [
        // Primary action (if any)
        if (buttons.isNotEmpty) ...[
          SizedBox(
            width: double.infinity,
            child: buttons.first,
          ),
          if (secondaryActions.isNotEmpty) const SizedBox(height: 12),
        ],

        // Secondary actions
        if (secondaryActions.isNotEmpty)
          Row(
            children: secondaryActions
                .map((button) => Expanded(child: button))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildPrimaryActionButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildSecondaryActionButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: color),
        label: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withOpacity(0.3)),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'scheduled':
        return Icons.schedule;
      case 'follow-up':
        return Icons.repeat;
      case 'emergency':
        return Icons.emergency;
      case 'comprehensive':
        return Icons.medical_services;
      default:
        return Icons.video_call;
    }
  }
}