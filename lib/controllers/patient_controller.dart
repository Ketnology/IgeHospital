import 'package:get/get.dart';
import 'package:ige_hospital/models/patient_model.dart';
import 'package:ige_hospital/provider/patient_service.dart';
import 'package:ige_hospital/utils/snack_bar_utils.dart';

class PatientController extends GetxController {
  final PatientService _patientService = Get.put(PatientService());

  // Observable variables
  var patients = <PatientModel>[].obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  // Pagination
  var currentPage = 1.obs;
  var totalPatients = 0.obs;
  var perPage = 12.obs;

  // Filters
  var searchQuery = ''.obs;
  var selectedGender = ''.obs;
  var selectedBloodGroup = ''.obs;
  var dateFrom = ''.obs;
  var dateTo = ''.obs;
  var sortBy = 'created_at'.obs;
  var sortDirection = 'desc'.obs;

  // Filter options
  var genders = ['All', 'Male', 'Female'].obs;
  var bloodGroups = ['All', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].obs;

  @override
  void onInit() {
    super.onInit();
    loadPatients();

    // Set up debounced search
    debounce(searchQuery, (_) => loadPatients(), time: const Duration(milliseconds: 500));
  }

  // Computed property for filtered patients (for UI display)
  List<PatientModel> get filteredPatients {
    return patients.where((patient) {
      bool matchesSearch = true;
      if (searchQuery.value.isNotEmpty) {
        final search = searchQuery.value.toLowerCase();
        final fullName = patient.user['full_name']?.toString().toLowerCase() ?? '';
        final email = patient.user['email']?.toString().toLowerCase() ?? '';
        final phone = patient.user['phone']?.toString().toLowerCase() ?? '';
        final patientId = patient.patientUniqueId.toLowerCase();

        matchesSearch = fullName.contains(search) ||
            email.contains(search) ||
            phone.contains(search) ||
            patientId.contains(search);
      }
      return matchesSearch;
    }).toList();
  }

  Future<void> loadPatients() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await _patientService.getPatientsWithPagination(
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        gender: selectedGender.value.isNotEmpty ? selectedGender.value : null,
        bloodGroup: selectedBloodGroup.value.isNotEmpty ? selectedBloodGroup.value : null,
        dateFrom: dateFrom.value.isNotEmpty ? dateFrom.value : null,
        dateTo: dateTo.value.isNotEmpty ? dateTo.value : null,
        sortBy: sortBy.value,
        sortDirection: sortDirection.value,
        page: currentPage.value,
        perPage: perPage.value,
      );

      patients.value = result['patients'];
      totalPatients.value = result['total'];
      perPage.value = result['per_page'];

    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      Get.log("Error loading patients: $e");
      SnackBarUtils.showErrorSnackBar('Failed to load patients: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addPatient(Map<String, dynamic> patientData) async {
    try {
      await _patientService.createPatient(patientData);
      await loadPatients(); // Refresh the list
    } catch (e) {
      Get.log("Error adding patient: $e");
      SnackBarUtils.showErrorSnackBar('Failed to add patient: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> updatePatient(String id, Map<String, dynamic> patientData) async {
    try {
      await _patientService.updatePatient(id, patientData);
      await loadPatients(); // Refresh the list
    } catch (e) {
      Get.log("Error updating patient: $e");
      SnackBarUtils.showErrorSnackBar('Failed to update patient: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> deletePatient(String id) async {
    try {
      await _patientService.deletePatient(id);
      await loadPatients(); // Refresh the list
    } catch (e) {
      Get.log("Error deleting patient: $e");
      SnackBarUtils.showErrorSnackBar('Failed to delete patient: ${e.toString()}');
    }
  }

  Future<PatientModel?> getPatientDetails(String id) async {
    try {
      return await _patientService.getPatientDetails(id);
    } catch (e) {
      Get.log("Error getting patient details: $e");
      SnackBarUtils.showErrorSnackBar('Failed to get patient details: ${e.toString()}');
      return null;
    }
  }

  // Pagination methods
  void nextPage() {
    if (currentPage.value < totalPages) {
      currentPage.value++;
      loadPatients();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      loadPatients();
    }
  }

  void setPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
      loadPatients();
    }
  }

  int get totalPages => (totalPatients.value / perPage.value).ceil();

  // Filter methods
  void resetFilters() {
    searchQuery.value = '';
    selectedGender.value = '';
    selectedBloodGroup.value = '';
    dateFrom.value = '';
    dateTo.value = '';
    sortDirection.value = 'desc';
    currentPage.value = 1;
    loadPatients();
  }

  void applySearch(String query) {
    searchQuery.value = query;
    currentPage.value = 1; // Reset to first page when searching
  }

  void applyGenderFilter(String gender) {
    selectedGender.value = gender == 'All' ? '' : gender.toLowerCase();
    currentPage.value = 1;
    loadPatients();
  }

  void applyBloodGroupFilter(String bloodGroup) {
    selectedBloodGroup.value = bloodGroup == 'All' ? '' : bloodGroup;
    currentPage.value = 1;
    loadPatients();
  }

  void applyDateRange(String from, String to) {
    dateFrom.value = from;
    dateTo.value = to;
    currentPage.value = 1;
    loadPatients();
  }

  void changeSortDirection(String direction) {
    sortDirection.value = direction;
    currentPage.value = 1;
    loadPatients();
  }
}