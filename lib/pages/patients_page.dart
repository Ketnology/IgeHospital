import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/patient_controller.dart';
import 'package:ige_hospital/models/patient_model.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/provider/permission_service.dart';
import 'package:ige_hospital/widgets/common_title.dart';
import 'package:ige_hospital/widgets/patient_component/add_patient_dialog.dart';
import 'package:ige_hospital/widgets/patient_component/edit_patient_dialog.dart';
import 'package:ige_hospital/widgets/patient_component/patient_detail_dialog.dart';
import 'package:ige_hospital/widgets/patient_component/patient_filters.dart';
import 'package:ige_hospital/widgets/patient_component/patient_pagination.dart';
import 'package:ige_hospital/widgets/patient_component/patient_card.dart';
import 'package:ige_hospital/widgets/permission_wrapper.dart';
import 'package:ige_hospital/widgets/permission_button.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:provider/provider.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  late PatientController controller;
  final TextEditingController searchController = TextEditingController();
  final PermissionService permissionService = Get.find<PermissionService>();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(PatientController());

    // Set listener for search text changes
    searchController.addListener(() {
      if (searchController.text != controller.searchQuery.value) {
        controller.searchQuery.value = searchController.text;
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _showAddPatientDialog() {
    showDialog(
      context: context,
      builder: (context) => AddPatientDialog(
        controller: controller,
      ),
    );
  }

  void _showEditPatientDialog(PatientModel patient) {
    showDialog(
      context: context,
      builder: (context) => EditPatientDialog(
        patient: patient,
        controller: controller,
      ),
    );
  }

  void _showPatientDetail(PatientModel patient) {
    showDialog(
      context: context,
      builder: (context) => PatientDetailDialog(
        patient: patient,
      ),
    ).then((result) {
      if (result == 'edit' && permissionService.hasPermission('edit_patients')) {
        _showEditPatientDialog(patient);
      }
    });
  }

  void _showDeleteConfirmation(PatientModel patient) {
    final notifier = Provider.of<ColourNotifier>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: notifier.getContainer,
        title: Text(
          'Delete Patient',
          style: TextStyle(color: notifier.getMainText),
        ),
        content: Text(
          'Are you sure you want to delete ${patient.user['full_name']}? This action cannot be undone.',
          style: TextStyle(color: notifier.getMainText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: notifier.getMainText),
            ),
          ),
          PermissionWrapper(
            permission: 'delete_patients',
            child: ElevatedButton(
              onPressed: () {
                controller.deletePatient(patient.id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Scaffold(
      backgroundColor: notifier.getBgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommonTitle(
                title: 'Patient Records', path: "Hospital Operations"),
            _buildPageTopBar(notifier),
            if (_showFilters)
              PatientFilters(
                controller: controller,
                searchController: searchController,
                showFilters: _showFilters,
              ),
            _buildPatientsList(notifier),
          ],
        ),
      ),
      floatingActionButton: PermissionWrapper(
        permission: 'create_patients',
        child: FloatingActionButton(
          backgroundColor: notifier.getIconColor,
          onPressed: () {
            setState(() {
              _showFilters = !_showFilters;
            });
          },
          child: Icon(
            _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
            color: notifier.getBgColor,
          ),
        ),
      ),
    );
  }

  Widget _buildPageTopBar(ColourNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Stats and Filters Button
          Row(
            children: [
              // Total patients count
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: notifier.getIconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: notifier.getIconColor.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people,
                      size: 16,
                      color: notifier.getIconColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${controller.totalPatients.value} Patients',
                      style: TextStyle(
                        color: notifier.getIconColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(width: 12),

              // Toggle Filters Button
              IconButton(
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                icon: Icon(
                  _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
                  color: notifier.getIconColor,
                ),
                tooltip: _showFilters ? 'Hide filters' : 'Show filters',
              ),
              const SizedBox(width: 8),

              // Refresh Button
              IconButton(
                onPressed: () => controller.loadPatients(),
                icon: Icon(Icons.refresh, color: notifier.getIconColor),
                tooltip: 'Refresh',
              ),
            ],
          ),

          // Add Patient Button - Only show if user can create patients
          PermissionButton(
            permission: 'create_patients',
            onPressed: _showAddPatientDialog,
            child: ElevatedButton(
              onPressed: null, // Will be overridden by PermissionButton
              style: ElevatedButton.styleFrom(
                backgroundColor: appMainColor,
                fixedSize: const Size.fromHeight(40),
                elevation: 0,
              ),
              child: Row(
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
    );
  }

  Widget _buildPatientsList(ColourNotifier notifier) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: notifier.getIconColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading patients...',
                    style: TextStyle(
                      color: notifier.getMainText,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          if (controller.hasError.value) {
            return _buildErrorState(notifier);
          }

          if (controller.patients.isEmpty) {
            return _buildEmptyState(notifier);
          }

          return Column(
            children: [
              // Quick stats row if patients exist
              if (controller.patients.isNotEmpty) _buildQuickStats(notifier),

              const SizedBox(height: 16),

              Expanded(
                child: _buildPatientGrid(controller.filteredPatients),
              ),

              // Always show pagination for all screen sizes
              PatientPagination(
                controller: controller,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildQuickStats(ColourNotifier notifier) {
    return Obx(() {
      // Calculate stats from current patients
      final patientsWithVitals = controller.patients.where((p) => p.hasVitalSigns).length;
      final activePatients = controller.patients.where((p) => p.user['status'] == 'active').length;
      final totalAppointments = controller.patients.fold<int>(0, (sum, p) =>
      sum + int.parse(p.stats['appointments_count']?.toString() ?? '0'));

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notifier.getContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: notifier.getBorderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Active Patients',
                activePatients.toString(),
                Icons.person_outline,
                Colors.green,
                notifier,
              ),
            ),
            Container(
              width: 1,
              height: 30,
              color: notifier.getBorderColor,
            ),
            Expanded(
              child: _buildStatItem(
                'With Vital Signs',
                patientsWithVitals.toString(),
                Icons.favorite_outline,
                Colors.red,
                notifier,
              ),
            ),
            Container(
              width: 1,
              height: 30,
              color: notifier.getBorderColor,
            ),
            Expanded(
              child: _buildStatItem(
                'Total Appointments',
                totalAppointments.toString(),
                Icons.calendar_today_outlined,
                Colors.blue,
                notifier,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(
      String label,
      String value,
      IconData icon,
      Color color,
      ColourNotifier notifier,
      ) {
    return Flexible(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: notifier.getMainText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: notifier.getMaingey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientGrid(List<PatientModel> patients) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid based on screen width
        int crossAxisCount;
        double childAspectRatio;

        if (constraints.maxWidth > 1400) {
          crossAxisCount = 4;
          childAspectRatio = 0.85; // Increased for more height
        } else if (constraints.maxWidth > 1000) {
          crossAxisCount = 3;
          childAspectRatio = 0.8; // Increased for more height
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
          childAspectRatio = 0.75; // Increased for more height
        } else {
          crossAxisCount = 1;
          childAspectRatio = 1.0; // Increased for more height
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: patients.length,
          itemBuilder: (context, index) {
            final patient = patients[index];
            return _buildPatientCardWithPermissions(patient);
          },
        );
      },
    );
  }

  Widget _buildPatientCardWithPermissions(PatientModel patient) {
    final notifier = Provider.of<ColourNotifier>(context, listen: false);

    return PatientCard(
      patient: patient,
      onView: () => _showPatientDetail(patient),
      onEdit: permissionService.hasPermission('edit_patients')
          ? () => _showEditPatientDialog(patient)
          : null,
      onDelete: permissionService.hasPermission('delete_patients')
          ? () => _showDeleteConfirmation(patient)
          : null,
    );
  }

  Widget _buildErrorState(ColourNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load patients',
            style: TextStyle(
              color: notifier.getMainText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.errorMessage.value.isNotEmpty
                ? controller.errorMessage.value
                : 'Please try again later',
            style: TextStyle(
              color: notifier.getMaingey,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => controller.loadPatients(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: notifier.getIconColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColourNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 60,
            color: notifier.getMaingey,
          ),
          const SizedBox(height: 16),
          Text(
            'No patients found',
            style: TextStyle(
              color: notifier.getMainText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.searchQuery.value.isNotEmpty
                ? 'No patients match your search criteria'
                : 'Add a new patient to get started',
            style: TextStyle(
              color: notifier.getMaingey,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (controller.searchQuery.value.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () {
                searchController.clear();
                controller.resetFilters();
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: notifier.getIconColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            )
          else
            PermissionButton(
              permission: 'create_patients',
              onPressed: _showAddPatientDialog,
              child: ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.person_add),
                label: const Text('Add Patient'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: notifier.getIconColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }
}