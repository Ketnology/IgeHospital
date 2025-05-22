import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/patient_controller.dart';
import 'package:ige_hospital/models/patient_model.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/common_title.dart';
import 'package:ige_hospital/widgets/patient_component/add_patient_dialog.dart';
import 'package:ige_hospital/widgets/patient_component/edit_patient_dialog.dart';
import 'package:ige_hospital/widgets/patient_component/patient_detail_dialog.dart';
import 'package:ige_hospital/widgets/patient_component/patient_filters.dart';
import 'package:ige_hospital/widgets/patient_component/patient_pagination.dart';
import 'package:ige_hospital/widgets/patient_component/patient_card.dart';
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
      if (result == 'edit') {
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
          ElevatedButton(
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
      floatingActionButton: FloatingActionButton(
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
    );
  }

  Widget _buildPageTopBar(ColourNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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

          // Add Patient Button
          ElevatedButton(
            onPressed: _showAddPatientDialog,
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
              child: CircularProgressIndicator(
                color: notifier.getIconColor,
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

  Widget _buildPatientGrid(List<PatientModel> patients) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 380,
        childAspectRatio: 0.85,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: patients.length,
      itemBuilder: (context, index) {
        final patient = patients[index];
        return PatientCard(
          patient: patient,
          onView: () => _showPatientDetail(patient),
          onEdit: () => _showEditPatientDialog(patient),
          onDelete: () => _showDeleteConfirmation(patient),
        );
      },
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
            'Please try again later',
            style: TextStyle(
              color: notifier.getMaingey,
              fontSize: 16,
            ),
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
            'Add a new patient or adjust your filters',
            style: TextStyle(
              color: notifier.getMaingey,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAddPatientDialog,
            icon: const Icon(Icons.person_add),
            label: const Text('Add Patient'),
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
}
