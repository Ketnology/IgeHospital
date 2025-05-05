import 'package:flutter/material.dart';
import 'package:ige_hospital/controllers/nurse_controller.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/ui/status_badge.dart';
import 'package:provider/provider.dart';

class NurseCard extends StatelessWidget {
  final Nurse nurse;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NurseCard({
    super.key,
    required this.nurse,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Card(
      elevation: 3,
      color: notifier.getContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: notifier.getBorderColor),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 300,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and status badge
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: notifier.getIconColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${nurse.fullName}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: notifier.getMainText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    StatusBadge(status: nurse.status),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Specialty and Department
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nurse.specialty.isNotEmpty
                                ? '${nurse.specialty} • ${nurse.department}'
                                : nurse.department,
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
                      nurse.email,
                      notifier,
                    ),
                    const SizedBox(height: 8),
                    _buildContactItem(
                      context,
                      Icons.phone_outlined,
                      nurse.phone,
                      notifier,
                    ),

                    const SizedBox(height: 20),

                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatDisplay(
                          context,
                          'Qualification',
                          nurse.qualification,
                          Icons.school_outlined,
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
        value.length > 20
            ? Tooltip(
          message: value,
          child: Text(
            '${value.substring(0, 17)}...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: notifier.getMainText,
            ),
          ),
        )
            : Text(
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
}