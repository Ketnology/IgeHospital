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
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: notifier.getBorderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                        fontSize: isCompact ? 14 : 16,
                        color: notifier.getMainText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ConsultationStatusBadge(statusInfo: consultation.statusInfo),
                ],
              ),

              const SizedBox(height: 12),

              // Type and meeting info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: consultationController.getTypeColor(consultation.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        consultationController.getTypeIcon(consultation.type),
                        const SizedBox(width: 4),
                        Text(
                          consultation.type.capitalizeFirst ?? consultation.type,
                          style: TextStyle(
                            color: consultationController.getTypeColor(consultation.type),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: notifier.getMaingey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${consultation.consultationDurationMinutes} min',
                    style: TextStyle(
                      fontSize: 12,
                      color: notifier.getMaingey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Date and time
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: notifier.getBgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: notifier.getBorderColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: notifier.getIconColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            consultation.dateHuman,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: notifier.getMainText,
                            ),
                          ),
                          if (consultation.timeUntilConsultation != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              consultation.timeUntilConsultation!,
                              style: TextStyle(
                                fontSize: 11,
                                color: notifier.getMaingey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (!isCompact) ...[
                const SizedBox(height: 12),

                // Doctor and Patient info
                Row(
                  children: [
                    Expanded(
                      child: _buildPersonInfo(
                        context,
                        'Doctor',
                        consultation.doctor.name,
                        consultation.doctor.specialist,
                        Icons.medical_services,
                        notifier,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPersonInfo(
                        context,
                        'Patient',
                        consultation.patient.name,
                        consultation.patient.patientUniqueId,
                        Icons.person,
                        notifier,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Action buttons
                _buildActionButtons(context, notifier),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonInfo(
      BuildContext context,
      String label,
      String name,
      String subtitle,
      IconData icon,
      ColourNotifier notifier,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: notifier.getMaingey,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: notifier.getMaingey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
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
    );
  }

  Widget _buildActionButtons(BuildContext context, ColourNotifier notifier) {
    List<Widget> buttons = [];

    // Join button
    if (consultation.permissions.canJoin && consultation.statusInfo.isActive) {
      buttons.add(
        _buildActionButton(
          label: 'Join',
          icon: Icons.video_call,
          color: Colors.green,
          onPressed: onJoin,
        ),
      );
    }

    // Start button (for doctors)
    if (consultation.permissions.canStart) {
      buttons.add(
        _buildActionButton(
          label: 'Start',
          icon: Icons.play_arrow,
          color: Colors.blue,
          onPressed: onStart,
        ),
      );
    }

    // End button (for doctors)
    if (consultation.permissions.canEnd) {
      buttons.add(
        _buildActionButton(
          label: 'End',
          icon: Icons.stop,
          color: Colors.red,
          onPressed: onEnd,
        ),
      );
    }

    // Edit button
    if (consultation.permissions.canEdit) {
      buttons.add(
        _buildActionButton(
          label: 'Edit',
          icon: Icons.edit,
          color: notifier.getIconColor,
          onPressed: onEdit,
        ),
      );
    }

    // Delete button
    if (consultation.permissions.canDelete) {
      buttons.add(
        _buildActionButton(
          label: 'Delete',
          icon: Icons.delete,
          color: Colors.red,
          onPressed: onDelete,
        ),
      );
    }

    if (buttons.isEmpty) {
      return const SizedBox();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: buttons,
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}