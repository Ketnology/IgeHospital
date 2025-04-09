import 'package:flutter/material.dart';
import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:ige_hospital/models/patient_model.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/provider/patient_service.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class PatientDataTable extends StatefulWidget {
  final List<PatientModel> patients;
  final ColourNotifier notifier;
  final PatientsService patientsService;
  final int visibleCount;
  final int pageSize;
  final int currentPage;
  final Function(int) onPageChanged;
  final Widget Function(int, int, Function(int)) paginationBuilder;
  final Function(PatientModel)? onViewPatient;
  final Function(PatientModel)? onEditPatient;
  final Function(PatientModel)? onDeletePatient;

  const PatientDataTable({
    Key? key,
    required this.patients,
    required this.notifier,
    required this.patientsService,
    required this.visibleCount,
    required this.pageSize,
    required this.currentPage,
    required this.onPageChanged,
    required this.paginationBuilder,
    this.onViewPatient,
    this.onEditPatient,
    this.onDeletePatient,
  }) : super(key: key);

  @override
  State<PatientDataTable> createState() => _PatientDataTableState();
}

class _PatientDataTableState extends State<PatientDataTable> {
  late List<ExpandableColumn<dynamic>> headers;
  late List<ExpandableRow> rows;

  @override
  void initState() {
    super.initState();
    createDataSource();
  }

  @override
  void didUpdateWidget(PatientDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recreate data source if patients list changed
    if (widget.patients != oldWidget.patients) {
      createDataSource();
    }
  }

  void createDataSource() {
    headers = [
      ExpandableColumn<String>(columnTitle: "Name", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Email", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Phone", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Gender", columnFlex: 1),
      ExpandableColumn<String>(columnTitle: "Blood Group", columnFlex: 1),
      ExpandableColumn<String>(columnTitle: "Registration Date", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Status", columnFlex: 1),
      ExpandableColumn<Widget>(columnTitle: "Actions", columnFlex: 2),
    ];

    rows = widget.patients.map<ExpandableRow>((patient) {
      // Format the created_at date
      String formattedDate = 'N/A';
      try {
        if (patient.createdAt.isNotEmpty) {
          final date = DateTime.parse(patient.createdAt);
          formattedDate = DateFormat('MMM dd, yyyy').format(date);
        }
      } catch (e) {
        print("Error parsing date: $e");
      }

      return ExpandableRow(cells: [
        ExpandableCell<String>(
            columnTitle: "Name", value: patient.user['full_name'] ?? 'N/A'),
        ExpandableCell<String>(
            columnTitle: "Email", value: patient.user['email'] ?? 'N/A'),
        ExpandableCell<String>(
            columnTitle: "Phone", value: patient.user['phone'] ?? 'N/A'),
        ExpandableCell<String>(
            columnTitle: "Gender", value: patient.user['gender'] ?? 'N/A'),
        ExpandableCell<String>(
            columnTitle: "Blood Group",
            value: patient.user['blood_group'] ?? 'N/A'),
        ExpandableCell<String>(
            columnTitle: "Registration Date", value: formattedDate),
        ExpandableCell<String>(
            columnTitle: "Status", value: patient.user['status'] ?? 'N/A'),
        ExpandableCell<Widget>(
          columnTitle: "Actions",
          value: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.visibility, color: widget.notifier.getIconColor),
                onPressed: widget.onViewPatient != null
                    ? () => widget.onViewPatient!(patient)
                    : null,
                tooltip: "View Details",
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: widget.onEditPatient != null
                    ? () => widget.onEditPatient!(patient)
                    : null,
                tooltip: "Edit",
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: widget.onDeletePatient != null
                    ? () => widget.onDeletePatient!(patient)
                    : null,
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
    // Ensure data source is up-to-date with current patients
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
    // Find the corresponding patient
    int index = rows.indexOf(row);
    if (index == -1 || index >= widget.patients.length) {
      return const SizedBox(); // Fallback
    }

    // Get the patient data
    final patient = widget.patients[index];

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient header with profile image and status
          Row(
            children: [
              // Profile image
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
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.person,
                      size: 40,
                      color: widget.notifier.getIconColor,
                    ),
                  ),
                )
                    : Icon(
                  Icons.person,
                  size: 40,
                  color: widget.notifier.getIconColor,
                ),
              ),
              const SizedBox(width: 20),

              // Patient name and status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.user['full_name'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: widget.notifier.getMainText,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 10,
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
                        Text(
                          "ID: ${patient.patientUniqueId}",
                          style: TextStyle(
                            color: widget.notifier.getMainText,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.visibility, color: widget.notifier.getIconColor),
                    onPressed: widget.onViewPatient != null
                        ? () => widget.onViewPatient!(patient)
                        : null,
                    tooltip: "View Details",
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: widget.onEditPatient != null
                        ? () => widget.onEditPatient!(patient)
                        : null,
                    tooltip: "Edit",
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: widget.onDeletePatient != null
                        ? () => widget.onDeletePatient!(patient)
                        : null,
                    tooltip: "Delete",
                  ),
                ],
              ),
            ],
          ),

          const Divider(height: 30),

          // Patient details - Use SingleChildScrollView to prevent overflow
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 30,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column - Personal details
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _detailRow("Email", patient.user['email'] ?? 'N/A'),
                        _detailRow("Phone", patient.user['phone'] ?? 'N/A'),
                        _detailRow("Gender", patient.user['gender'] ?? 'N/A'),
                        _detailRow("Date of Birth", patient.user['dob'] ?? 'N/A'),
                        _detailRow("Blood Group", patient.user['blood_group'] ?? 'N/A'),
                      ],
                    ),
                  ),

                  SizedBox(width: 20),

                  // Right column - Additional details
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle("Statistics"),
                        _detailRow("Appointments", "${patient.stats['appointments_count'] ?? '0'} total"),
                        _detailRow("Documents", "${patient.stats['documents_count'] ?? '0'} total"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: widget.notifier.getMainText,
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: widget.notifier.getMainText,
            ),
          ),
          Text(
            value,
            style: TextStyle(color: widget.notifier.getMainText),
            overflow: TextOverflow.ellipsis,
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