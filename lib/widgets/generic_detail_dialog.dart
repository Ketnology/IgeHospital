import 'package:flutter/material.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/common_button.dart';
import 'package:intl/intl.dart';

class DetailSection {
  final String title;
  final List<DetailField> fields;

  DetailSection({
    required this.title,
    required this.fields,
  });
}

class DetailField {
  final String label;
  final dynamic value;
  final IconData? icon;
  final bool isImage;
  final bool isDate;
  final bool isHtml;
  final bool isBadge;
  final Color? badgeColor;

  DetailField({
    required this.label,
    required this.value,
    this.icon,
    this.isImage = false,
    this.isDate = false,
    this.isHtml = false,
    this.isBadge = false,
    this.badgeColor,
  });
}

class ActionButton {
  final String text;
  final Color color;
  final VoidCallback onPressed;
  final IconData? icon;

  ActionButton({
    required this.text,
    required this.color,
    required this.onPressed,
    this.icon,
  });
}

class GenericDetailDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final IconData? fallbackIcon;
  final List<DetailSection> sections;
  final List<ActionButton> actions;
  final ColourNotifier notifier;
  final Map<String, dynamic>? additionalData;
  final Widget? header;
  final Widget? footer;

  const GenericDetailDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.fallbackIcon = Icons.account_circle,
    required this.sections,
    required this.actions,
    required this.notifier,
    this.additionalData,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: notifier.getContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content: Container(
        width: 600,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with image and title
            header ?? _buildHeader(),

            const Divider(height: 30),

            // Details content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...sections.map((section) => _buildSection(section)).toList(),

                    if (footer != null) ...[
                      const SizedBox(height: 20),
                      footer!,
                    ],
                  ],
                ),
              ),
            ),

            // Action buttons
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Profile Image
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey.shade200,
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.network(
              imageUrl!,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                fallbackIcon,
                size: 40,
                color: notifier.getIconColor,
              ),
            ),
          )
              : Icon(
            fallbackIcon,
            size: 40,
            color: notifier.getIconColor,
          ),
        ),
        const SizedBox(width: 20),

        // Name and subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: notifier.getMainText,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 5),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: notifier.getMaingey,
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Close button
        IconButton(
          icon: Icon(Icons.close, color: notifier.getIconColor),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildSection(DetailSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: notifier.getMainText,
          ),
        ),
        const SizedBox(height: 10),

        Wrap(
          spacing: 30,
          runSpacing: 15,
          children: section.fields.map((field) => _buildField(field)).toList(),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildField(DetailField field) {
    if (field.isImage) {
      return _buildImageField(field);
    } else if (field.isBadge) {
      return _buildBadgeField(field);
    } else {
      return _buildTextField(field);
    }
  }

  Widget _buildTextField(DetailField field) {
    String displayValue = '';

    if (field.isDate && field.value is String && field.value.toString().isNotEmpty) {
      try {
        final date = DateTime.parse(field.value.toString());
        displayValue = DateFormat('MMM dd, yyyy').format(date);
      } catch (e) {
        displayValue = field.value.toString();
      }
    } else {
      displayValue = field.value?.toString() ?? 'N/A';
    }

    return SizedBox(
      width: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (field.icon != null) ...[
            Icon(
              field.icon,
              size: 18,
              color: notifier.getIconColor,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${field.label}:",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: notifier.getMaingey,
                  ),
                ),
                Text(
                  displayValue,
                  style: TextStyle(color: notifier.getMainText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageField(DetailField field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${field.label}:",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: notifier.getMaingey,
          ),
        ),
        const SizedBox(height: 5),
        if (field.value != null && field.value.toString().isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              field.value.toString(),
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 120,
                height: 120,
                color: Colors.grey.shade300,
                child: Icon(
                  Icons.image_not_supported,
                  color: notifier.getIconColor,
                ),
              ),
            ),
          )
        else
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.image_not_supported,
              color: notifier.getIconColor,
            ),
          ),
      ],
    );
  }

  Widget _buildBadgeField(DetailField field) {
    final Color badgeColor = field.badgeColor ?? _getStatusColor(field.value.toString());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        field.value.toString().toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ...actions.map((action) => Padding(
          padding: const EdgeInsets.only(left: 10),
          child: CommonButton(
            title: action.text,
            color: action.color,
            onTap: action.onPressed,
          ),
        )).toList(),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'blocked':
      case 'inactive':
        return Colors.red;
      case 'pending':
      case 'waiting':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}