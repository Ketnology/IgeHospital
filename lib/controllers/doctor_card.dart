import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'doctor_controller.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor Image and Status
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: doctor.profileImage,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: (context, url) => Container(
                  height: 140,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    color: Colors.grey[200], // Background color while loading
                  ),
                  child: CircularProgressIndicator(), // Loading indicator centered
                ),
                errorWidget: (context, url, error) => Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    color: Colors.grey[200], // Fallback background color
                  ),
                  child: Icon(
                    Icons.error,
                    size: 50, // Larger error icon
                    color: Colors.red,
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getStatusColor(doctor.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    doctor.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Doctor Information
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Department
                Text(
                  'Dr. ${doctor.fullName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${doctor.specialty} • ${doctor.department}',
                        style: TextStyle(
                          color: Colors.grey[600],
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
                  doctor.email,
                ),
                const SizedBox(height: 8),
                _buildContactItem(
                  context,
                  Icons.phone_outlined,
                  doctor.phone,
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
                      color: Theme.of(context).primaryColor,
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
                      color: Colors.red,
                      onPressed: onDelete,
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

  Widget _buildContactItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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