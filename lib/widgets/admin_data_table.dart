import 'package:flutter/material.dart';
import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/provider/admin_service.dart';
import 'package:intl/intl.dart';

class AdminDataTable extends StatefulWidget {
  final List<AdminModel> admins;
  final ColourNotifier notifier;
  final AdminsService adminsService;
  final int visibleCount;
  final int pageSize;
  final int currentPage;
  final Function(int) onPageChanged;
  final Widget Function(int, int, Function(int)) paginationBuilder;
  final Function(AdminModel) onDeleteAdmin;

  const AdminDataTable({
    Key? key,
    required this.admins,
    required this.notifier,
    required this.adminsService,
    required this.visibleCount,
    required this.pageSize,
    required this.currentPage,
    required this.onPageChanged,
    required this.paginationBuilder,
    required this.onDeleteAdmin,
  }) : super(key: key);

  @override
  State<AdminDataTable> createState() => _AdminDataTableState();
}

class _AdminDataTableState extends State<AdminDataTable> {
  late List<ExpandableColumn<dynamic>> headers;
  late List<ExpandableRow> rows;

  @override
  void initState() {
    super.initState();
    createDataSource();
  }

  @override
  void didUpdateWidget(AdminDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recreate data source if admins list changed
    if (widget.admins != oldWidget.admins) {
      createDataSource();
    }
  }

  void createDataSource() {
    headers = [
      ExpandableColumn<String>(columnTitle: "Full Name", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Email", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Phone", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Gender", columnFlex: 1),
      ExpandableColumn<String>(columnTitle: "Status", columnFlex: 1),
      ExpandableColumn<String>(columnTitle: "Default Admin", columnFlex: 1),
      ExpandableColumn<Widget>(columnTitle: "Actions", columnFlex: 2),
    ];

    rows = widget.admins.map<ExpandableRow>((admin) {
      return ExpandableRow(cells: [
        ExpandableCell<String>(columnTitle: "Full Name", value: admin.fullName),
        ExpandableCell<String>(columnTitle: "Email", value: admin.email),
        ExpandableCell<String>(columnTitle: "Phone", value: admin.phone),
        ExpandableCell<String>(columnTitle: "Gender", value: admin.gender),
        ExpandableCell<String>(columnTitle: "Status", value: admin.status),
        ExpandableCell<String>(
            columnTitle: "Default Admin", value: admin.isDefault ? "Yes" : "No"),
        ExpandableCell<Widget>(
          columnTitle: "Actions",
          value: Row(
            children: [
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => widget.onDeleteAdmin(admin),
                tooltip: "Delete",
              ),
            ],
          ),
        ),
      ]);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure data source is up-to-date with current admins
    createDataSource();

    return ExpandableTheme(
      data: ExpandableThemeData(
        context,
        contentPadding: const EdgeInsets.all(15),
        expandedBorderColor: widget.notifier.getBorderColor,
        paginationSize: 48,
        headerHeight: 76,
        headerColor: widget.notifier.getPrimaryColor,
        headerBorder: BorderSide(
          color: widget.notifier.getBgColor,
          width: 8,
        ),
        evenRowColor: widget.notifier.getContainer,
        oddRowColor: widget.notifier.getBgColor,
        rowBorder: BorderSide(
          color: widget.notifier.getBorderColor,
          width: 0.3,
        ),
        headerTextMaxLines: 4,
        headerSortIconColor: widget.notifier.getMainText,
        headerTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: widget.notifier.getMainText,
        ),
        rowTextStyle: TextStyle(
          color: widget.notifier.getMainText,
        ),
        expansionIcon: Icon(
          Icons.keyboard_arrow_down,
          color: widget.notifier.getIconColor,
        ),
        editIcon: Icon(
          Icons.edit,
          color: widget.notifier.getMainText,
        ),
      ),
      child: ExpandableDataTable(
        headers: headers,
        rows: rows,
        multipleExpansion: true,
        isEditable: false,
        visibleColumnCount: widget.visibleCount,
        pageSize: widget.pageSize,
        onPageChanged: widget.onPageChanged,
        renderExpansionContent: (row) => _buildExpandedContent(row),
        renderCustomPagination: widget.paginationBuilder,
      ),
    );
  }

  Widget _buildExpandedContent(ExpandableRow row) {
    // Find the corresponding admin
    int index = rows.indexOf(row);
    if (index == -1 || index >= widget.admins.length) {
      return const SizedBox(); // Fallback
    }

    // Get the admin data
    final admin = widget.admins[index];

    // Format dates for display
    String createdAtFormatted = 'N/A';
    String updatedAtFormatted = 'N/A';

    try {
      if (admin.createdAt.isNotEmpty) {
        final createdDate = DateTime.parse(admin.createdAt);
        createdAtFormatted = DateFormat('MMM dd, yyyy').format(createdDate);
      }
      if (admin.updatedAt.isNotEmpty) {
        final updatedDate = DateTime.parse(admin.updatedAt);
        updatedAtFormatted = DateFormat('MMM dd, yyyy').format(updatedDate);
      }
    } catch (e) {
      print("Error parsing dates: $e");
    }

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Admin header with profile image and status
          Row(
            children: [
              // Profile image
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey.shade200,
                child: admin.profileImage.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                    admin.profileImage,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.person,
                      size: 30,
                      color: widget.notifier.getIconColor,
                    ),
                  ),
                )
                    : Icon(
                  Icons.person,
                  size: 30,
                  color: widget.notifier.getIconColor,
                ),
              ),
              const SizedBox(width: 15),

              // Admin name and ID
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      admin.fullName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.notifier.getMainText,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        if (admin.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Default Admin",
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

              // Status indicator
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(admin.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  admin.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 30),

          // Admin details in a grid layout
          Wrap(
            spacing: 30,
            runSpacing: 15,
            children: [
              _detailItem("Email", admin.email, Icons.email),
              _detailItem("Phone", admin.phone, Icons.phone),
              _detailItem("Gender", admin.gender, Icons.person),
              _detailItem(
                  "User ID", admin.userId, Icons.perm_identity),
              _detailItem("Created At", createdAtFormatted, Icons.calendar_today),
              _detailItem("Updated At", updatedAtFormatted, Icons.update),
            ],
          ),

          const SizedBox(height: 20),

          // Action buttons at the bottom
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () => widget.onDeleteAdmin(admin),
                icon: const Icon(Icons.delete, size: 16),
                label: const Text("Delete"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailItem(String label, String value, IconData icon) {
    return SizedBox(
      width: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: widget.notifier.getIconColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: widget.notifier.getMaingey,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(color: widget.notifier.getMainText),
                ),
              ],
            ),
          ),
        ],
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