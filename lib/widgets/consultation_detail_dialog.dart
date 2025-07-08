import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/consultation_controller.dart';
import 'package:ige_hospital/models/consultation_model.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/widgets/consultation_status_badge.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ConsultationDetailDialog extends StatelessWidget {
  final LiveConsultation consultation;

  const ConsultationDetailDialog({
    super.key,
    required this.consultation,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);
    final consultationController = Get.find<ConsultationController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: notifier.getContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: notifier.getBorderColor),
        ),
        child: Column(
          children: [
            _buildHeader(context, notifier, consultationController),
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
                        Tab(text: 'Details', icon: Icon(Icons.info_outline, size: 16)),
                        Tab(text: 'Participants', icon: Icon(Icons.people_outline, size: 16)),
                        Tab(text: 'Meeting Info', icon: Icon(Icons.video_call_outlined, size: 16)),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildDetailsTab(context, notifier, consultationController),
                          _buildParticipantsTab(context, notifier),
                          _buildMeetingInfoTab(context, notifier),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildFooter(context, notifier, consultationController),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColourNotifier notifier, ConsultationController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: notifier.getIconColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  consultation.consultationTitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: notifier.getMainText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: notifier.getMainText),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ConsultationStatusBadge(statusInfo: consultation.statusInfo),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: controller.getTypeColor(consultation.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    controller.getTypeIcon(consultation.type),
                    const SizedBox(width: 4),
                    Text(
                      consultation.type.capitalizeFirst ?? consultation.type,
                      style: TextStyle(
                        color: controller.getTypeColor(consultation.type),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            consultation.dateHuman,
            style: TextStyle(
              fontSize: 16,
              color: notifier.getMaingey,
            ),
          ),
          if (consultation.timeUntilConsultation != null) ...[
            const SizedBox(height: 4),
            Text(
              consultation.timeUntilConsultation!,
              style: TextStyle(
                fontSize: 14,
                color: notifier.getIconColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsTab(BuildContext context, ColourNotifier notifier, ConsultationController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'Consultation Details', notifier),
          _buildInfoItem(
            context,
            'Date & Time',
            consultation.consultationDateFormatted,
            Icons.calendar_today,
            notifier,
          ),
          _buildInfoItem(
            context,
            'Duration',
            '${consultation.consultationDurationMinutes} minutes',
            Icons.timer,
            notifier,
          ),
          _buildInfoItem(
            context,
            'Time Zone',
            consultation.timeZone,
            Icons.public,
            notifier,
          ),
          _buildInfoItem(
            context,
            'Meeting ID',
            consultation.meetingId,
            Icons.meeting_room,
            notifier,
            copyable: true,
          ),
          if (consultation.description != null && consultation.description!.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildSectionHeader(context, 'Description', notifier),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                consultation.description!,
                style: TextStyle(
                  color: notifier.getMainText,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          _buildSectionHeader(context, 'Video Settings', notifier),
          Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  context,
                  'Host Video',
                  consultation.hostVideo ? 'Enabled' : 'Disabled',
                  consultation.hostVideo ? Icons.videocam : Icons.videocam_off,
                  consultation.hostVideo ? Colors.green : Colors.red,
                  notifier,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFeatureCard(
                  context,
                  'Participant Video',
                  consultation.participantVideo ? 'Enabled' : 'Disabled',
                  consultation.participantVideo ? Icons.videocam : Icons.videocam_off,
                  consultation.participantVideo ? Colors.green : Colors.red,
                  notifier,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionHeader(context, 'System Information', notifier),
          _buildInfoItem(
            context,
            'Consultation ID',
            consultation.id,
            Icons.badge,
            notifier,
            copyable: true,
          ),
          _buildInfoItem(
            context,
            'Created By',
            consultation.createdBy,
            Icons.person,
            notifier,
          ),
          _buildInfoItem(
            context,
            'Created At',
            _formatDate(consultation.createdAt),
            Icons.event,
            notifier,
          ),
          _buildInfoItem(
            context,
            'Last Updated',
            _formatDate(consultation.updatedAt),
            Icons.update,
            notifier,
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsTab(BuildContext context, ColourNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'Doctor Information', notifier),
          _buildParticipantCard(
            context,
            'Dr. ${consultation.doctor.name}',
            consultation.doctor.email,
            consultation.doctor.phone,
            consultation.doctor.specialist,
            consultation.doctor.department,
            consultation.doctor.avatar,
            Icons.medical_services,
            notifier,
          ),
          const SizedBox(height: 20),
          _buildSectionHeader(context, 'Patient Information', notifier),
          _buildParticipantCard(
            context,
            consultation.patient.name,
            consultation.patient.email,
            consultation.patient.phone,
            'Patient ID: ${consultation.patient.patientUniqueId}',
            'Patient',
            consultation.patient.avatar,
            Icons.person,
            notifier,
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingInfoTab(BuildContext context, ColourNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (consultation.joinInfo != null) ...[
            _buildSectionHeader(context, 'Meeting Access Information', notifier),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: notifier.getBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: notifier.getBorderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule, color: notifier.getIconColor),
                      const SizedBox(width: 8),
                      Text(
                        'Join Window',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: notifier.getMainText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Available from ${_formatDateTime(consultation.joinInfo!.joinWindowStart)} to ${_formatDateTime(consultation.joinInfo!.joinWindowEnd)}',
                    style: TextStyle(
                      color: notifier.getMainText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: consultation.joinInfo!.canJoinNow
                              ? Colors.green
                              : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        consultation.joinInfo!.canJoinNow
                            ? 'You can join now'
                            : 'Not yet available to join',
                        style: TextStyle(
                          color: consultation.joinInfo!.canJoinNow
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Meeting ID and Password Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: notifier.getBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: notifier.getBorderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.meeting_room, color: notifier.getIconColor),
                      const SizedBox(width: 8),
                      Text(
                        'Meeting Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: notifier.getMainText,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Meeting ID',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: notifier.getMaingey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              consultation.meetingId,
                              style: TextStyle(
                                color: notifier.getMainText,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy, size: 16, color: notifier.getIconColor),
                        onPressed: () => _copyToClipboard(
                          context,
                          consultation.meetingId,
                          'Meeting ID copied to clipboard',
                        ),
                        tooltip: 'Copy Meeting ID',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: notifier.getMaingey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              consultation.password,
                              style: TextStyle(
                                color: notifier.getMainText,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy, size: 16, color: notifier.getIconColor),
                        onPressed: () => _copyToClipboard(
                          context,
                          consultation.password,
                          'Password copied to clipboard',
                        ),
                        tooltip: 'Copy Password',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionHeader(context, 'Meeting Instructions', notifier),
            _buildInstructionsSection(
              'Before the Meeting',
              consultation.joinInfo!.meetingInstructions.beforeMeeting,
              Icons.schedule,
              notifier,
            ),
            const SizedBox(height: 16),
            _buildInstructionsSection(
              'Joining the Meeting',
              consultation.joinInfo!.meetingInstructions.joiningMeeting,
              Icons.meeting_room,
              notifier,
            ),
            const SizedBox(height: 16),
            _buildInstructionsSection(
              'During the Meeting',
              consultation.joinInfo!.meetingInstructions.duringMeeting,
              Icons.video_call,
              notifier,
            ),
            const SizedBox(height: 16),
            _buildInstructionsSection(
              'Troubleshooting',
              consultation.joinInfo!.meetingInstructions.troubleshooting,
              Icons.help_outline,
              notifier,
            ),
            const SizedBox(height: 20),
            _buildSectionHeader(context, 'Technical Requirements', notifier),
            _buildTechnicalRequirements(consultation.joinInfo!.technicalRequirements, notifier),
          ] else ...[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 64,
                    color: notifier.getMaingey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Meeting information not available',
                    style: TextStyle(
                      fontSize: 18,
                      color: notifier.getMainText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Meeting details will be available closer to the consultation time',
                    style: TextStyle(
                      color: notifier.getMaingey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Helper method for formatting date time
  String _formatDateTime(DateTime dateTime) {
    try {
      return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
    } catch (e) {
      return dateTime.toString();
    }
  }

  Widget _buildFooter(BuildContext context, ColourNotifier notifier, ConsultationController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: notifier.getBorderColor)),
      ),
      child: Row(
        children: [
          // Join button
          if (consultation.permissions.canJoin && consultation.statusInfo.isActive) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.joinConsultation(consultation.id);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.video_call, color: Colors.white),
                label: const Text('Join Consultation', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Start button
          if (consultation.permissions.canStart) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.startConsultation(consultation.id);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: const Text('Start Consultation', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // End button
          if (consultation.permissions.canEnd) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.endConsultation(consultation.id);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.stop, color: Colors.white),
                label: const Text('End Consultation', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Edit button
          if (consultation.permissions.canEdit) ...[
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context, 'edit');
              },
              icon: Icon(Icons.edit, color: notifier.getIconColor),
              label: Text('Edit', style: TextStyle(color: notifier.getIconColor)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: notifier.getIconColor),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
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
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildInfoItem(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      ColourNotifier notifier, {
        bool copyable = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: notifier.getMaingey),
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
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(color: notifier.getMainText),
                  ),
                ),
                if (copyable) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.copy, size: 16, color: notifier.getIconColor),
                    onPressed: () => _copyToClipboard(
                      context,
                      value,
                      '$label copied to clipboard',
                    ),
                    tooltip: 'Copy $label',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context,
      String title,
      String status,
      IconData icon,
      Color color,
      ColourNotifier notifier,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifier.getBgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: notifier.getBorderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: notifier.getMainText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantCard(
      BuildContext context,
      String name,
      String email,
      String phone,
      String subtitle,
      String role,
      String? avatar,
      IconData defaultIcon,
      ColourNotifier notifier,
      ) {
    final defaultImage = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random';
    final imageUrl = avatar?.isNotEmpty == true ? avatar! : defaultImage;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifier.getBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifier.getBorderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(imageUrl),
            onBackgroundImageError: (exception, stackTrace) {},
            child: avatar?.isNotEmpty != true
                ? null
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: notifier.getMainText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: notifier.getIconColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.email, size: 14, color: notifier.getMaingey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        email,
                        style: TextStyle(
                          color: notifier.getMaingey,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone, size: 14, color: notifier.getMaingey),
                    const SizedBox(width: 4),
                    Text(
                      phone,
                      style: TextStyle(
                        color: notifier.getMaingey,
                        fontSize: 12,
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

  Widget _buildInstructionsSection(
      String title,
      List<String> instructions,
      IconData icon,
      ColourNotifier notifier,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifier.getBgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: notifier.getBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: notifier.getIconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: notifier.getMainText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...instructions.map((instruction) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: notifier.getIconColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    instruction,
                    style: TextStyle(
                      color: notifier.getMainText,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTechnicalRequirements(
      ConsultationTechnicalRequirements requirements,
      ColourNotifier notifier,
      ) {
    return Column(
      children: [
        _buildRequirementCard(
          'Supported Browsers',
          requirements.browsers,
          Icons.web,
          notifier,
        ),
        const SizedBox(height: 12),
        _buildRequirementCard(
          'Supported Devices',
          requirements.devices,
          Icons.devices,
          notifier,
        ),
        const SizedBox(height: 12),
        _buildRequirementCard(
          'Required Permissions',
          requirements.permissions,
          Icons.security,
          notifier,
        ),
        const SizedBox(height: 12),
        // Add Zoom-specific requirements if available
        if (requirements.zoomSpecific.isNotEmpty) ...[
          _buildRequirementCard(
            'Zoom-Specific Requirements',
            requirements.zoomSpecific,
            Icons.video_call,
            notifier,
          ),
          const SizedBox(height: 12),
        ],
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notifier.getBgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: notifier.getBorderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.speed, color: notifier.getIconColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Bandwidth Requirements',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: notifier.getMainText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...requirements.bandwidth.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${entry.key}:',
                        style: TextStyle(
                          color: notifier.getMainText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      entry.value,
                      style: TextStyle(color: notifier.getMaingey),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementCard(
      String title,
      List<String> items,
      IconData icon,
      ColourNotifier notifier,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifier.getBgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: notifier.getBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: notifier.getIconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: notifier.getMainText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: notifier.getIconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item,
                style: TextStyle(
                  color: notifier.getIconColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    try {
      return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
    } catch (e) {
      return dateTime.toString();
    }
  }

  void _copyToClipboard(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}