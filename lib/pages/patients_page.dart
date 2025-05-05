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
import 'package:provider/provider.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  late PatientController controller;
  final TextEditingController searchController = TextEditingController();

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
    final isMobile = MediaQuery.of(context).size.width < 768;
    final isTablet = MediaQuery.of(context).size.width >= 768 &&
        MediaQuery.of(context).size.width < 1024;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: notifier.getBgColor,
      appBar: isMobile ? _buildMobileAppBar(notifier) : null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Desktop/Tablet header
            if (!isMobile)
              const CommonTitle(
                  title: 'Patient Records', path: 'Hospital Operations'),

            // Search and add button - responsive layout
            _buildPageTopBar(notifier, isDesktop, isTablet, isMobile),

            // Filters
            PatientFilters(
              controller: controller,
              searchController: searchController,
            ),

            // Patients list with pagination
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 8.0 : 20.0),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: notifier.getIconColor,
                      ),
                    );
                  }

                  if (controller.hasError.value) {
                    return _buildErrorState(notifier, isMobile);
                  }

                  if (controller.patients.isEmpty) {
                    return _buildEmptyState(notifier, isMobile);
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: _buildPatientList(controller.filteredPatients,
                            isMobile, isTablet, isDesktop),
                      ),
                      // Always show pagination for all screen sizes
                      PatientPagination(
                        controller: controller,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientList(List<PatientModel> patients, bool isMobile,
      bool isTablet, bool isDesktop) {
    if (isMobile) {
      return _buildMobileList(patients);
    } else if (isTablet) {
      return _buildTabletGrid(patients);
    } else {
      return _buildDesktopGrid(patients);
    }
  }

  Widget _buildMobileList(List<PatientModel> patients) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: patients.length,
      itemBuilder: (context, index) => PatientCard(
        patient: patients[index],
        onView: () => _showPatientDetail(patients[index]),
        onEdit: () => _showEditPatientDialog(patients[index]),
        onDelete: () => _showDeleteConfirmation(patients[index]),
      ),
      separatorBuilder: (context, index) => const SizedBox(height: 8),
    );
  }

  Widget _buildTabletGrid(List<PatientModel> patients) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: patients.length,
      itemBuilder: (context, index) => PatientCard(
        patient: patients[index],
        onView: () => _showPatientDetail(patients[index]),
        onEdit: () => _showEditPatientDialog(patients[index]),
        onDelete: () => _showDeleteConfirmation(patients[index]),
      ),
    );
  }

  Widget _buildDesktopGrid(List<PatientModel> patients) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: patients.length,
      itemBuilder: (context, index) => PatientCard(
        patient: patients[index],
        onView: () => _showPatientDetail(patients[index]),
        onEdit: () => _showEditPatientDialog(patients[index]),
        onDelete: () => _showDeleteConfirmation(patients[index]),
      ),
    );
  }

  PreferredSizeWidget _buildMobileAppBar(ColourNotifier notifier) {
    return AppBar(
      backgroundColor: notifier.getContainer,
      elevation: 1,
      title: Text(
        'Patient Records',
        style: TextStyle(
          color: notifier.getMainText,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: SvgPicture.asset(
              "assets/plus-circle.svg",
              color: notifier.getIconColor,
              width: 24,
              height: 24,
            ),
            onPressed: _showAddPatientDialog,
          ),
        ),
      ],
    );
  }

  Widget _buildPageTopBar(
      ColourNotifier notifier, bool isDesktop, bool isTablet, bool isMobile) {
    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Manage patients and their medical records',
          style: TextStyle(
            color: notifier.getMaingey,
            fontSize: 14,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: isDesktop
          ? Row(
              children: [
                Expanded(
                  child: Text(
                    'Manage patients and their medical records',
                    style: TextStyle(
                      color: notifier.getMaingey,
                      fontSize: 16,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddPatientDialog,
                  icon: SvgPicture.asset(
                    "assets/plus-circle.svg",
                    color: Colors.white,
                    width: 18,
                    height: 18,
                  ),
                  label: const Text('Add Patient'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: notifier.getIconColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                ),
              ],
            )
          : Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Manage patients and their medical records',
                    style: TextStyle(
                      color: notifier.getMaingey,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showAddPatientDialog,
                    icon: SvgPicture.asset(
                      "assets/plus-circle.svg",
                      color: Colors.white,
                      width: 18,
                      height: 18,
                    ),
                    label: const Text('Add Patient'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: notifier.getIconColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildErrorState(ColourNotifier notifier, bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: isMobile ? 50 : 60,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load patients',
            style: TextStyle(
              color: notifier.getMainText,
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later',
            style: TextStyle(
              color: notifier.getMaingey,
              fontSize: isMobile ? 14 : 16,
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
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: isMobile ? 10 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColourNotifier notifier, bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_outlined,
            size: isMobile ? 50 : 60,
            color: notifier.getMaingey,
          ),
          const SizedBox(height: 16),
          Text(
            'No patients found',
            style: TextStyle(
              color: notifier.getMainText,
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a new patient or adjust your filters',
            style: TextStyle(
              color: notifier.getMaingey,
              fontSize: isMobile ? 14 : 16,
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
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: isMobile ? 10 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
