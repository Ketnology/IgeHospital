import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter/material.dart';
import 'package:ige_hospital/models/patient_model.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/provider/patient_service.dart';
import 'package:ige_hospital/widgets/patient_detail_dialog.dart';
import 'package:ige_hospital/widgets/edit_patient_dialog.dart';

class PatientDataTable extends StatefulWidget {
  final List<PatientModel> patients;
  final ColourNotifier notifier;
  final PatientsService patientsService;
  final int visibleCount;
  final int pageSize;
  final int currentPage;
  final Function(int) onPageChanged;
  final Widget Function(int, int, Function(int)) paginationBuilder;

  const PatientDataTable({
    super.key,
    required this.patients,
    required this.notifier,
    required this.patientsService,
    required this.visibleCount,
    required this.pageSize,
    required this.currentPage,
    required this.onPageChanged,
    required this.paginationBuilder,
  });

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
    if (oldWidget.patients != widget.patients) {
      createDataSource();
    }
  }

  void createDataSource() {
    headers = [
      ExpandableColumn<String>(columnTitle: "Patient Name", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Email", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Phone", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Gender", columnFlex: 1),
      ExpandableColumn<String>(columnTitle: "Blood Group", columnFlex: 1),
      ExpandableColumn<String>(columnTitle: "Date of Birth", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Status", columnFlex: 1),
      ExpandableColumn<String>(columnTitle: "ID", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Unique ID", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Appointments", columnFlex: 1),
      ExpandableColumn<String>(columnTitle: "Documents", columnFlex: 1),
      ExpandableColumn<Widget>(columnTitle: "Profile Image", columnFlex: 2),
      ExpandableColumn<Widget>(columnTitle: "Actions", columnFlex: 2),
    ];

    // Check if we have patients to display
    if (widget.patients.isEmpty) {
      rows = [];
      return;
    }

    // Map the patients to expandable rows
    rows = widget.patients.map<ExpandableRow>((patient) {
      return ExpandableRow(cells: [
        ExpandableCell<String>(
            columnTitle: "Patient Name",
            value: patient.user['full_name'] ?? 'N/A'),
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
            columnTitle: "Date of Birth", value: patient.user['dob'] ?? 'N/A'),
        ExpandableCell<String>(
            columnTitle: "Status", value: patient.user['status'] ?? 'N/A'),
        ExpandableCell<String>(columnTitle: "ID", value: patient.id),
        ExpandableCell<String>(
            columnTitle: "Unique ID", value: patient.patientUniqueId),
        ExpandableCell<String>(
            columnTitle: "Appointments",
            value: patient.stats['appointments_count']?.toString() ?? '0'),
        ExpandableCell<String>(
            columnTitle: "Documents",
            value: patient.stats['documents_count']?.toString() ?? '0'),
        ExpandableCell<Widget>(
          columnTitle: "Profile Image",
          value: patient.user['profile_image'] != null
              ? Image.network(
            patient.user['profile_image'].toString(),
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.person,
              size: 40,
            ),
          )
              : const Icon(Icons.person, size: 40),
        ),
        ExpandableCell<Widget>(
          columnTitle: "Actions",
          value: Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: widget.notifier.getIconColor),
                onPressed: () {
                  // Open edit dialog
                  _showEditDialog(patient);
                },
              ),
              IconButton(
                icon: Icon(Icons.visibility, color: Colors.blue),
                onPressed: () {
                  // Show view patient detail
                  _showPatientDetail(patient);
                },
              ),
            ],
          ),
        ),
      ]);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
        renderExpansionContent: (row) {
          int index = rows.indexOf(row);
          if (index == -1 || index >= widget.patients.length) {
            return const SizedBox();
          }

          final patient = widget.patients[index];
          return _buildExpandedContent(patient);
        },
        renderCustomPagination: widget.paginationBuilder,
      ),
    );
  }

  void _showPatientDetail(PatientModel patient) {
    showDialog(
      context: context,
      builder: (context) => PatientDetailDialog(
        patient: patient,
        notifier: widget.notifier,
      ),
    ).then((result) {
      // If the user clicked "Edit Patient" from the detail dialog
      if (result == 'edit') {
        _showEditDialog(patient);
      }
    });
  }

  void _showEditDialog(PatientModel patient) {
    showDialog(
      context: context,
      builder: (context) => EditPatientDialog(
        patient: patient,
        notifier: widget.notifier,
        patientsService: widget.patientsService,
      ),
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Widget _buildExpandedContent(PatientModel patient) {
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
                radius: 30,
                backgroundColor: Colors.grey.shade200,
                child: patient.user['profile_image'] != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                    patient.user['profile_image'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(
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

              // Patient name and ID
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.user['full_name'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.notifier.getMainText,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Patient ID: ${patient.patientUniqueId}",
                      style: TextStyle(
                        color: widget.notifier.getMaingey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                      patient.user['status'] ?? 'active'),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (patient.user['status'] ?? 'active')
                      .toUpperCase(),
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

          // Patient details in a grid layout
          Wrap(
            spacing: 30,
            runSpacing: 15,
            children: [
              _detailItem(
                  "Email",
                  patient.user['email'] ?? 'N/A',
                  Icons.email),
              _detailItem(
                  "Phone",
                  patient.user['phone'] ?? 'N/A',
                  Icons.phone),
              _detailItem(
                  "Gender",
                  patient.user['gender'] ?? 'N/A',
                  Icons.person),
              _detailItem(
                  "Date of Birth",
                  patient.user['dob'] ?? 'N/A',
                  Icons.calendar_today),
              _detailItem(
                  "Blood Group",
                  patient.user['blood_group'] ?? 'N/A',
                  Icons.bloodtype),
              _detailItem(
                  "Qualification",
                  patient.user['qualification'] ?? 'N/A',
                  Icons.school),
              _detailItem(
                  "Appointments",
                  "${patient.stats['appointments_count'] ?? '0'}",
                  Icons.calendar_month),
              _detailItem(
                  "Documents",
                  "${patient.stats['documents_count'] ?? '0'}",
                  Icons.file_copy),
            ],
          ),

          const SizedBox(height: 20),

          // Action buttons at the bottom
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  // Navigate to detailed patient view or open in a new tab
                  _showPatientDetail(patient);
                },
                icon: const Icon(Icons.visibility, size: 16),
                label: const Text("View Details"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: widget.notifier.getIconColor,
                  side: BorderSide(color: widget.notifier.getIconColor),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () {
                  // Show edit dialog
                  _showEditDialog(patient);
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text("Edit"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
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