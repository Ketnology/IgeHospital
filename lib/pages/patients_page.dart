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

  // Key for PatientDataTable to force rebuild when data changes
  final tableKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Fetch patients on page load
    patientsService.fetchPatients();

    // Set up listener for patient data changes
    ever(patientsService.patients, (_) {
      if (mounted) {
        // Update the table key to force a rebuild
        setState(() {
          tableKey.currentState?.setState(() {});
        });
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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

  void _showAddPatientDialog() {
    showDialog(
      context: context,
      builder: (context) => AddPatientDialog(
        notifier: notifier,
        patientsService: patientsService,
      ),
    ).then((_) {
      // Refresh data after dialog is closed
      patientsService.fetchPatients();
    });
  }

  void _showViewPatientDialog(PatientModel patient) {
    showDialog(
      context: context,
      builder: (context) => PatientDetailDialog(
        patient: patient,
        notifier: notifier,
      ),
    ).then((result) {
      if (result == 'edit') {
        _showEditPatientDialog(patient);
      }
    });
  }

  void _showEditPatientDialog(PatientModel patient) {
    showDialog(
      context: context,
      builder: (context) => EditPatientDialog(
        patient: patient,
        notifier: notifier,
        patientsService: patientsService,
      ),
    ).then((_) {
      if (mounted) {
        patientsService.fetchPatients();
        // Trigger UI update
        setState(() {});
      }
    });
  }

  void _showDeleteConfirmation(PatientModel patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: notifier.getContainer,
        title: Text(
          "Confirm Delete",
          style: TextStyle(color: notifier.getMainText),
        ),
        content: Text(
          "Are you sure you want to delete ${patient.user['full_name']}?",
          style: TextStyle(color: notifier.getMainText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: notifier.getMainText),
            ),
          ),
          TextButton(
            onPressed: () {
              patientsService.deletePatient(patient.id);
              Navigator.pop(context);
            },
            child: Text(
              "Delete",
              style: TextStyle(color: Colors.red),
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

                      // Use a unique key based on the patients list length to force rebuild
                      return PatientDataTable(
                        key: ValueKey('patient-table-${patientsService.patients.length}'),
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
                        onViewPatient: _showViewPatientDialog,
                        onEditPatient: _showEditPatientDialog,
                        onDeletePatient: _showDeleteConfirmation,
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