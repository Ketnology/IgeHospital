import 'package:flutter/material.dart';
import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/patients_service.dart';
import 'package:ige_hospital/static_data.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/widgets/common_button.dart';
import 'package:ige_hospital/widgets/text_field.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/common_title.dart';
import 'dart:math';
import 'package:ige_hospital/models/patient_model.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  AppConst obj = AppConst();
  final AppConst controller = Get.put(AppConst());
  ColourNotifier notifier = ColourNotifier();

  // Initialize the PatientsService
  final PatientsService patientsService = Get.put(PatientsService());

  late List<ExpandableColumn<dynamic>> headers;
  late List<ExpandableRow> rows;

  int currentPage = 0;
  final int pageSize = 10;

  final TextEditingController searchController = TextEditingController();
  final DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    createDataSource();
    patientsService.fetchPatients();

    // Add listener to update data source when patients change
    ever(patientsService.patients, (_) {
      createDataSource();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
    if (patientsService.patients.isEmpty) {
      rows = [];
      return;
    }

    // Map the patients to expandable rows
    rows = patientsService.patients.map<ExpandableRow>((patient) {
      return ExpandableRow(cells: [
        ExpandableCell<String>(
            columnTitle: "Patient Name", value: patient.user['full_name'] ?? 'N/A'),
        ExpandableCell<String>(
            columnTitle: "Email", value: patient.user['email'] ?? 'N/A'),
        ExpandableCell<String>(
            columnTitle: "Phone", value: patient.user['phone'] ?? 'N/A'),
        ExpandableCell<String>(
            columnTitle: "Gender", value: patient.user['gender'] ?? 'N/A'),
        ExpandableCell<String>(
            columnTitle: "Blood Group", value: patient.user['blood_group'] ?? 'N/A'),
        ExpandableCell<String>(
            columnTitle: "Date of Birth", value: patient.user['dob'] ?? 'N/A'),
        ExpandableCell<String>(
            columnTitle: "Status", value: patient.user['status'] ?? 'N/A'),
        ExpandableCell<String>(
            columnTitle: "ID", value: patient.id),
        ExpandableCell<String>(
            columnTitle: "Unique ID", value: patient.patientUniqueId),
        ExpandableCell<String>(
            columnTitle: "Appointments", value: patient.stats['appointments_count']?.toString() ?? '0'),
        ExpandableCell<String>(
            columnTitle: "Documents", value: patient.stats['documents_count']?.toString() ?? '0'),
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
                icon: Icon(Icons.edit, color: notifier.getIconColor),
                onPressed: () {
                  // Open edit dialog
                  // _showEditDialog(patient);
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

    // Force UI update
    if (mounted) setState(() {});
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

  Widget _buildPageTopBar() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;
          bool isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
          bool isDesktop = constraints.maxWidth >= 1024;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: isMobile
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: isDesktop ? 3 : 2, // More space for desktop
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        controller: searchController,
                        style: mediumBlackTextStyle.copyWith(
                          color: notifier.getMainText,
                        ),
                        onSubmitted: (value) {
                          patientsService.searchQuery.value = value;
                          patientsService.fetchPatients();
                        },
                        decoration: InputDecoration(
                          hintText: "Search by name, email, phone...",
                          isDense: true,
                          suffixIcon: IconButton(
                            icon: SvgPicture.asset(
                              "assets/search.svg",
                              height: 20,
                              width: 20,
                              color: appGreyColor,
                            ),
                            onPressed: () {
                              patientsService.searchQuery.value =
                                  searchController.text;
                              patientsService.fetchPatients();
                            },
                          ),
                          hintStyle: mediumGreyTextStyle,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  if (!isMobile) const SizedBox(width: 20),
                  Expanded(
                    flex: isDesktop ? 1 : (isTablet ? 2 : 3),
                    child: ElevatedButton(
                      onPressed: () {
                        // _showAddPatientDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appMainColor,
                        fixedSize: const Size.fromHeight(40),
                        elevation: 0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            "assets/plus-circle.svg",
                            color: Colors.white,
                            width: 18,
                            height: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Add Patient",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w200,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return Obx(
          () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Card(
          color: notifier.getContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: notifier.getBorderColor),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Filters",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: notifier.getMainText,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        patientsService.resetFilters();
                      },
                      icon: Icon(Icons.refresh,
                          size: 16, color: notifier.getIconColor),
                      label: Text(
                        "Reset Filters",
                        style: TextStyle(color: notifier.getIconColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                GestureDetector(
                  onTap: () async {
                    final DateTimeRange? picked = await showDateRangePicker(
                      context: context,
                      initialDateRange: DateTimeRange(
                        start: DateTime.now().subtract(const Duration(days: 30)),
                        end: DateTime.now(),
                      ),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: notifier.getIconColor,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (picked != null) {
                      patientsService.dateFrom.value =
                          DateFormat('yyyy-MM-dd').format(picked.start);
                      patientsService.dateTo.value =
                          DateFormat('yyyy-MM-dd').format(picked.end);
                      patientsService.fetchPatients();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: notifier.getBorderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16, color: notifier.getIconColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            patientsService.dateFrom.value.isNotEmpty &&
                                patientsService.dateTo.value.isNotEmpty
                                ? "${patientsService.dateFrom.value} to ${patientsService.dateTo.value}"
                                : "Select Date Range",
                            style: TextStyle(color: notifier.getMainText),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8
                          ),
                          isDense: true,
                          labelText: "Gender",
                          labelStyle: TextStyle(color: notifier.getMainText),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: notifier.getBorderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: notifier.getBorderColor),
                          ),
                        ),
                        value: patientsService.selectedGender.value.isEmpty ? null : patientsService.selectedGender.value,
                        dropdownColor: notifier.getContainer,
                        style: TextStyle(color: notifier.getMainText),
                        items: [
                          DropdownMenuItem(
                            value: '',
                            child: Text('All Genders',
                                style: TextStyle(color: notifier.getMainText)),
                          ),
                          DropdownMenuItem(
                            value: 'male',
                            child: Text('Male',
                                style: TextStyle(color: notifier.getMainText)),
                          ),
                          DropdownMenuItem(
                            value: 'female',
                            child: Text('Female',
                                style: TextStyle(color: notifier.getMainText)),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            patientsService.selectedGender.value = value;
                            patientsService.fetchPatients();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8
                          ),
                          isDense: true,
                          labelText: "Blood Group",
                          labelStyle: TextStyle(color: notifier.getMainText),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: notifier.getBorderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: notifier.getBorderColor),
                          ),
                        ),
                        value: patientsService.selectedBloodGroup.value.isEmpty ? null : patientsService.selectedBloodGroup.value,
                        dropdownColor: notifier.getContainer,
                        style: TextStyle(color: notifier.getMainText),
                        items: [
                          DropdownMenuItem(
                            value: '',
                            child: Text('All Blood Groups',
                                style: TextStyle(color: notifier.getMainText)),
                          ),
                          DropdownMenuItem(
                            value: 'A+',
                            child: Text('A+',
                                style: TextStyle(color: notifier.getMainText)),
                          ),
                          DropdownMenuItem(
                            value: 'A-',
                            child: Text('A-',
                                style: TextStyle(color: notifier.getMainText)),
                          ),
                          DropdownMenuItem(
                            value: 'B+',
                            child: Text('B+',
                                style: TextStyle(color: notifier.getMainText)),
                          ),
                          DropdownMenuItem(
                            value: 'B-',
                            child: Text('B-',
                                style: TextStyle(color: notifier.getMainText)),
                          ),
                          DropdownMenuItem(
                            value: 'AB+',
                            child: Text('AB+',
                                style: TextStyle(color: notifier.getMainText)),
                          ),
                          DropdownMenuItem(
                            value: 'AB-',
                            child: Text('AB-',
                                style: TextStyle(color: notifier.getMainText)),
                          ),
                          DropdownMenuItem(
                            value: 'O+',
                            child: Text('O+',
                                style: TextStyle(color: notifier.getMainText)),
                          ),
                          DropdownMenuItem(
                            value: 'O-',
                            child: Text('O-',
                                style: TextStyle(color: notifier.getMainText)),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            patientsService.selectedBloodGroup.value = value;
                            patientsService.fetchPatients();
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8
                          ),
                          isDense: true,
                          labelText: "Sort By",
                          labelStyle: TextStyle(color: notifier.getMainText),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: notifier.getBorderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: notifier.getBorderColor),
                          ),
                        ),
                        value: patientsService.sortBy.value,
                        dropdownColor: notifier.getContainer,
                        style: TextStyle(color: notifier.getMainText),
                        items: [
                          DropdownMenuItem(
                            value: 'created_at',
                            child: Text('Registration Date',
                                style: TextStyle(color: notifier.getMainText)),
                          ),
                          DropdownMenuItem(
                            value: 'first_name',
                            child: Text('First Name',
                                style: TextStyle(color: notifier.getMainText)),
                          ),
                          DropdownMenuItem(
                            value: 'last_name',
                            child: Text('Last Name',
                                style: TextStyle(color: notifier.getMainText)),
                          ),
                          DropdownMenuItem(
                            value: 'email',
                            child: Text('Email',
                                style: TextStyle(color: notifier.getMainText)),
                          ),
                          DropdownMenuItem(
                            value: 'patient_unique_id',
                            child: Text('Patient ID',
                                style: TextStyle(color: notifier.getMainText)),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            patientsService.sortBy.value = value;
                            patientsService.fetchPatients();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Sort Direction Dropdown
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8
                          ),
                          isDense: true,
                          labelText: "Sort Direction",
                          labelStyle: TextStyle(color: notifier.getMainText),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: notifier.getBorderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: notifier.getBorderColor),
                          ),
                        ),
                        value: patientsService.sortDirection.value,
                        dropdownColor: notifier.getContainer,
                        style: TextStyle(color: notifier.getMainText),
                        items: [
                          DropdownMenuItem(
                            value: 'asc',
                            child: Text('Ascending',
                                style: TextStyle(color: notifier.getMainText)),
                          ),
                          DropdownMenuItem(
                            value: 'desc',
                            child: Text('Descending',
                                style: TextStyle(color: notifier.getMainText)),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            patientsService.sortDirection.value = value;
                            patientsService.fetchPatients();
                          }
                        },
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

  Widget _buildCustomPagination(
      int totalPages, int currentPage, void Function(int) onPageChanged) {
    return Obx(
          () {
        final calculatedTotalPages =
        (patientsService.totalPatients.value /
            patientsService.perPage.value)
            .ceil();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // First page button
              IconButton(
                icon: Icon(Icons.first_page,
                    color:
                    currentPage == 0 ? Colors.grey : notifier.getMainText),
                onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
              ),

              // Previous page button
              IconButton(
                icon: Icon(Icons.chevron_left,
                    color:
                    currentPage > 0 ? notifier.getMainText : Colors.grey),
                onPressed: currentPage > 0
                    ? () => onPageChanged(currentPage - 1)
                    : null,
              ),

              // Page counter
              Text(
                "Page ${currentPage + 1} of $totalPages",
                style: TextStyle(fontSize: 14, color: notifier.getMainText),
              ),

              // Next page button
              IconButton(
                icon: Icon(Icons.chevron_right,
                    color: currentPage < calculatedTotalPages - 1
                        ? notifier.getMainText
                        : Colors.grey),
                onPressed: currentPage < totalPages - 1
                    ? () => onPageChanged(currentPage + 1)
                    : null,
              ),

              // Last page button
              IconButton(
                icon: Icon(Icons.last_page,
                    color: currentPage < calculatedTotalPages - 1
                        ? notifier.getMainText
                        : Colors.grey),
                onPressed: currentPage < calculatedTotalPages - 1
                    ? () => onPageChanged(calculatedTotalPages - 1)
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPatientDetail(PatientModel patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        backgroundColor: notifier.getContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Container(
          width: 600,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Profile Image
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
                          color: notifier.getIconColor,
                        ),
                      ),
                    )
                        : Icon(
                      Icons.person,
                      size: 40,
                      color: notifier.getIconColor,
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Patient Name and Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.user['full_name'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: notifier.getMainText,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(patient.user['status'] ?? 'active'),
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
                            const SizedBox(width: 10),
                            Text(
                              "ID: ${patient.patientUniqueId}",
                              style: TextStyle(
                                color: notifier.getMainText,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Close button
                  IconButton(
                    icon: Icon(Icons.close, color: notifier.getIconColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 30),

              // Patient details
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal Information
                      _sectionTitle("Personal Information"),
                      _detailRow("Email", patient.user['email'] ?? 'N/A'),
                      _detailRow("Phone", patient.user['phone'] ?? 'N/A'),
                      _detailRow("Gender", patient.user['gender'] ?? 'N/A'),
                      _detailRow("Date of Birth", patient.user['dob'] ?? 'N/A'),
                      _detailRow("Blood Group", patient.user['blood_group'] ?? 'N/A'),
                      _detailRow("Qualification", patient.user['qualification'] ?? 'N/A'),

                      const SizedBox(height: 20),

                      // Medical Information
                      _sectionTitle("Medical Information"),
                      _detailRow("Appointments", "${patient.stats['appointments_count'] ?? '0'} total"),
                      _detailRow("Documents", "${patient.stats['documents_count'] ?? '0'} total"),

                      const SizedBox(height: 20),

                      // Address (if available)
                      if (patient.address != null) ...[
                        _sectionTitle("Address"),
                        _detailRow("Street", patient.address!['street'] ?? 'N/A'),
                        _detailRow("City", patient.address!['city'] ?? 'N/A'),
                        _detailRow("State", patient.address!['state'] ?? 'N/A'),
                        _detailRow("Zip Code", patient.address!['zip'] ?? 'N/A'),
                        _detailRow("Country", patient.address!['country'] ?? 'N/A'),
                        const SizedBox(height: 20),
                      ],

                      // Documents
                      if (patient.documents.isNotEmpty) ...[
                        _sectionTitle("Recent Documents"),
                        ...patient.documents.take(3).map((doc) => _documentItem(doc)),
                        if (patient.documents.length > 3)
                          TextButton(
                            onPressed: () {
                              // View all documents
                            },
                            child: Text(
                              "View all ${patient.documents.length} documents",
                              style: TextStyle(color: notifier.getIconColor),
                            ),
                          ),
                        const SizedBox(height: 20),
                      ],

                      // Appointments
                      if (patient.appointments.isNotEmpty) ...[
                        _sectionTitle("Recent Appointments"),
                        ...patient.appointments.take(3).map((appointment) => _appointmentItem(appointment)),
                        if (patient.appointments.length > 3)
                          TextButton(
                            onPressed: () {
                              // View all appointments
                            },
                            child: Text(
                              "View all ${patient.appointments.length} appointments",
                              style: TextStyle(color: notifier.getIconColor),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CommonButton(
                    title: "Edit Patient",
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      // _showEditDialog(patient);
                    },
                  ),
                  const SizedBox(width: 10),
                  CommonButton(
                    title: "Close",
                    color: Colors.grey,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),
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
          color: notifier.getMainText,
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: notifier.getMainText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: notifier.getMainText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentItem(Map<String, dynamic> document) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: notifier.getBgColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: notifier.getBorderColor),
      ),
      child: ListTile(
        title: Text(
          document['title'] ?? 'Untitled Document',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: notifier.getMainText,
          ),
        ),
        subtitle: Text(
          document['notes'] != null ?
          document['notes'].toString().substring(0, min(50, document['notes'].toString().length)) + '...' :
          'No notes',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: notifier.getMaingey),
        ),
        trailing: document['file_info']?['file_url'] != null
            ? IconButton(
          icon: Icon(Icons.download, color: notifier.getIconColor),
          onPressed: () {
            // Download document
          },
        )
            : null,
      ),
    );
  }

  Widget _appointmentItem(Map<String, dynamic> appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: notifier.getBgColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: notifier.getBorderColor),
      ),
      child: ListTile(
        dense: true,
        title: Text(
          appointment['doctor_name'] ?? 'Doctor',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: notifier.getMainText,
          ),
        ),
        subtitle: Text(
          "${appointment['date'] ?? 'N/A'} at ${appointment['time'] ?? 'N/A'}",
          style: TextStyle(color: notifier.getMaingey),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: appointment['is_completed'] == true
                ? Colors.green
                : Colors.orange,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            appointment['is_completed'] == true ? 'COMPLETED' : 'PENDING',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showAddPatientDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final dobController = TextEditingController();
    String selectedGender = 'male';
    String selectedBloodGroup = 'O+';

    DateTime selectedDate = DateTime.now().subtract(const Duration(days: 365 * 20)); // Default 20 years ago

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        backgroundColor: notifier.getContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: StatefulBuilder(builder: (context, setState) {
          return Container(
            width: 500,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: notifier.getContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "Add New Patient",
                  style: TextStyle(
                    color: notifier.getMainText,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 15),
                MyTextField(
                  title: 'Full Name',
                  hinttext: "Enter Patient's Full Name",
                  controller: nameController,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  title: 'Email',
                  hinttext: "Enter Patient's Email",
                  controller: emailController,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  title: 'Phone',
                  hinttext: "Enter Patient's Phone Number",
                  controller: phoneController,
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );

                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                        dobController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: MyTextField(
                      title: 'Date of Birth',
                      hinttext: DateFormat('yyyy-MM-dd').format(selectedDate),
                      controller: dobController,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Gender",
                            style: mediumBlackTextStyle.copyWith(
                              color: notifier.getMainText,
                            ),
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: selectedGender,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: notifier.getContainer,
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.grey.withOpacity(0.3)),
                                borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: notifier.getIconColor,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                            ),
                            dropdownColor: notifier.getContainer,
                            style: TextStyle(color: notifier.getMainText),
                            items: [
                              DropdownMenuItem(
                                value: "male",
                                child: Text("Male",
                                    style: TextStyle(color: notifier.getMainText)),
                              ),
                              DropdownMenuItem(
                                value: "female",
                                child: Text("Female",
                                    style: TextStyle(color: notifier.getMainText)),
                              ),
                              DropdownMenuItem(
                                value: "other",
                                child: Text("Other",
                                    style: TextStyle(color: notifier.getMainText)),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedGender = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Blood Group",
                            style: mediumBlackTextStyle.copyWith(
                              color: notifier.getMainText,
                            ),
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: selectedBloodGroup,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: notifier.getContainer,
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.grey.withOpacity(0.3)),
                                borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: notifier.getIconColor,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                            ),
                            dropdownColor: notifier.getContainer,
                            style: TextStyle(color: notifier.getMainText),
                            items: [
                              DropdownMenuItem(
                                value: "A+",
                                child: Text("A+",
                                    style: TextStyle(color: notifier.getMainText)),
                              ),
                              DropdownMenuItem(
                                value: "A-",
                                child: Text("A-",
                                    style: TextStyle(color: notifier.getMainText)),
                              ),
                              DropdownMenuItem(
                                value: "B+",
                                child: Text("B+",
                                    style: TextStyle(color: notifier.getMainText)),
                              ),
                              DropdownMenuItem(
                                value: "B-",
                                child: Text("B-",
                                    style: TextStyle(color: notifier.getMainText)),
                              ),
                              DropdownMenuItem(
                                value: "AB+",
                                child: Text("AB+",
                                    style: TextStyle(color: notifier.getMainText)),
                              ),
                              DropdownMenuItem(
                                value: "AB-",
                                child: Text("AB-",
                                    style: TextStyle(color: notifier.getMainText)),
                              ),
                              DropdownMenuItem(
                                value: "O+",
                                child: Text("O+",
                                    style: TextStyle(color: notifier.getMainText)),
                              ),
                              DropdownMenuItem(
                                value: "O-",
                                child: Text("O-",
                                    style: TextStyle(color: notifier.getMainText)),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedBloodGroup = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CommonButton(
                      title: "Cancel",
                      color: const Color(0xfff73164),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 10),
                    CommonButton(
                      title: "Add Patient",
                      color: appMainColor,
                      onTap: () {
                        if (nameController.text.isEmpty ||
                            emailController.text.isEmpty ||
                            phoneController.text.isEmpty ||
                            dobController.text.isEmpty) {
                          Get.snackbar(
                            "Error",
                            "Please fill all required fields",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        // Here you would call the API to create a new patient
                        // For demonstration purposes, we'll just show a success message
                        Get.snackbar(
                          "Success",
                          "Patient added successfully",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );

                        // Refresh the patient list
                        patientsService.fetchPatients();

                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
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
            color: notifier.getIconColor,
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
                    color: notifier.getMaingey,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(color: notifier.getMainText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColourNotifier>(context, listen: true);

    return Scaffold(
      backgroundColor: notifier.getBgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            int visibleCount = 2;
            if (constraints.maxWidth < 600) {
              visibleCount = 2;
            } else if (constraints.maxWidth < 800) {
              visibleCount = 4;
            } else {
              visibleCount = 5;
            }

            return Column(
              children: [
                const CommonTitle(
                    title: 'Patient Records', path: "Hospital Operations"),
                _buildPageTopBar(),
                _buildFilterSection(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Obx(() {
                      if (patientsService.isLoading.value) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: notifier.getIconColor,
                          ),
                        );
                      }

                      if (patientsService.hasError.value) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                patientsService.errorMessage.value,
                                style: TextStyle(color: notifier.getMainText),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () =>
                                    patientsService.fetchPatients(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: notifier.getIconColor,
                                ),
                                child: const Text(
                                  "Retry",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (patientsService.patients.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_off_outlined,
                                color: notifier.getIconColor,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No patients found",
                                style: TextStyle(
                                  color: notifier.getMainText,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Try adjusting your filters or add a new patient",
                                style: TextStyle(
                                  color: notifier.getMaingey,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return ExpandableTheme(
                        data: ExpandableThemeData(
                          context,
                          contentPadding: const EdgeInsets.all(15),
                          expandedBorderColor: notifier.getBorderColor,
                          paginationSize: 48,
                          headerHeight: 76,
                          headerColor: notifier.getPrimaryColor,
                          headerBorder: BorderSide(
                            color: notifier.getBgColor,
                            width: 8,
                          ),
                          evenRowColor: notifier.getContainer,
                          oddRowColor: notifier.getBgColor,
                          rowBorder: BorderSide(
                            color: notifier.getBorderColor,
                            width: 0.3,
                          ),
                          headerTextMaxLines: 4,
                          headerSortIconColor: notifier.getMainText,
                          headerTextStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: notifier.getMainText,
                          ),
                          rowTextStyle: TextStyle(
                            color: notifier.getMainText,
                          ),
                          expansionIcon: Icon(
                            Icons.keyboard_arrow_down,
                            color: notifier.getIconColor,
                          ),
                          editIcon: Icon(
                            Icons.edit,
                            color: notifier.getMainText,
                          ),
                        ),
                        child: ExpandableDataTable(
                          headers: headers,
                          rows: rows,
                          multipleExpansion: true,
                          isEditable: false,
                          visibleColumnCount: visibleCount,
                          pageSize: pageSize,
                          onPageChanged: (page) {
                            setState(() {
                              currentPage = page;
                            });
                          },
                          renderExpansionContent: (row) {
                            // Find the corresponding patient
                            int index = rows.indexOf(row);
                            if (index == -1 || index >= patientsService.patients.length) {
                              return const SizedBox(); // Fallback
                            }

                            // Get the patient data
                            final patient = patientsService.patients[index];

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
                                            errorBuilder: (context, error, stackTrace) => Icon(
                                              Icons.person,
                                              size: 30,
                                              color: notifier.getIconColor,
                                            ),
                                          ),
                                        )
                                            : Icon(
                                          Icons.person,
                                          size: 30,
                                          color: notifier.getIconColor,
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
                                                color: notifier.getMainText,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              "Patient ID: ${patient.patientUniqueId}",
                                              style: TextStyle(
                                                color: notifier.getMaingey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Status badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(patient.user['status'] ?? 'active'),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          (patient.user['status'] ?? 'active').toUpperCase(),
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
                                      _detailItem("Email", patient.user['email'] ?? 'N/A', Icons.email),
                                      _detailItem("Phone", patient.user['phone'] ?? 'N/A', Icons.phone),
                                      _detailItem("Gender", patient.user['gender'] ?? 'N/A', Icons.person),
                                      _detailItem("Date of Birth", patient.user['dob'] ?? 'N/A', Icons.calendar_today),
                                      _detailItem("Blood Group", patient.user['blood_group'] ?? 'N/A', Icons.bloodtype),
                                      _detailItem("Qualification", patient.user['qualification'] ?? 'N/A', Icons.school),
                                      _detailItem("Appointments", "${patient.stats['appointments_count'] ?? '0'}", Icons.calendar_month),
                                      _detailItem("Documents", "${patient.stats['documents_count'] ?? '0'}", Icons.file_copy),
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
                                          foregroundColor: notifier.getIconColor,
                                          side: BorderSide(color: notifier.getIconColor),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          // Show edit dialog
                                          // _showEditDialog(patient);
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
                          },
                          renderCustomPagination:
                              (totalPages, currentPage, onPageChanged) =>
                              _buildCustomPagination(
                                  totalPages, currentPage, onPageChanged),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}