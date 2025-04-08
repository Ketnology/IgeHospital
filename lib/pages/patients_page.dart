import 'package:flutter/material.dart';
import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/patient_service.dart';
import 'package:ige_hospital/static_data.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/widgets/add_patient_dialog.dart';
import 'package:ige_hospital/widgets/edit_patient_dialog.dart';
import 'package:ige_hospital/widgets/patient_data_table.dart';
import 'package:ige_hospital/widgets/patient_detail_dialog.dart';
import 'package:ige_hospital/widgets/patient_filters.dart';
import 'package:ige_hospital/widgets/patient_pagination.dart';
import 'package:provider/provider.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/common_title.dart';
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
                icon: Icon(Icons.edit, color: notifier.getIconColor),
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
                        _showAddPatientDialog();
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

  void _showPatientDetail(PatientModel patient) {
    showDialog(
      context: context,
      builder: (context) => PatientDetailDialog(
        patient: patient,
        notifier: notifier,
      ),
    ).then((result) {
      if (result == 'edit') {
        _showEditDialog(patient);
      }
    });
  }

  void _showAddPatientDialog() {
    showDialog(
      context: context,
      builder: (context) => AddPatientDialog(
        notifier: notifier,
        patientsService: patientsService,
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

  void _showEditDialog(PatientModel patient) {
    showDialog(
      context: context,
      builder: (context) => EditPatientDialog(
        patient: patient,
        notifier: notifier,
        patientsService: patientsService,
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
                PatientFilters(
                  notifier: notifier,
                  patientsService: patientsService,
                ),
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

                      return PatientDataTable(
                        patients: patientsService.patients,
                        notifier: notifier,
                        patientsService: patientsService,
                        visibleCount: visibleCount,
                        pageSize: pageSize,
                        currentPage: currentPage,
                        onPageChanged: (page) {
                          setState(() {
                            currentPage = page;
                          });
                        },
                        paginationBuilder: _buildPagination,
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

  Widget _buildPagination(
      int totalPages, int currentPage, Function(int) onPageChanged) {
    return PatientPagination(
      notifier: notifier,
      patientsService: patientsService,
      totalPages: totalPages,
      currentPage: currentPage,
      onPageChanged: onPageChanged,
    );
  }
}
