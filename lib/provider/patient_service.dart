import 'dart:convert';
import 'package:get/get.dart';
import 'package:ige_hospital/constants/api_endpoints.dart';
import 'package:ige_hospital/models/patient_model.dart';
import 'package:ige_hospital/utils/http_client.dart';
import 'package:ige_hospital/utils/snack_bar_utils.dart';

class PatientsService extends GetxService {
  final HttpClient _httpClient = HttpClient();

  // Reactive variables
  final RxList<PatientModel> patients = <PatientModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Pagination
  final RxInt totalPatients = 0.obs;
  final RxInt currentPage = 1.obs;
  final RxInt perPage = 20.obs;

  // Filters
  final RxString searchQuery = ''.obs;
  final RxString selectedGender = ''.obs;
  final RxString selectedBloodGroup = ''.obs;
  final RxString dateFrom = ''.obs;
  final RxString dateTo = ''.obs;
  final RxString sortBy = 'created_at'.obs;
  final RxString sortDirection = 'desc'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    if (isLoading.value) return;

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final Map<String, String> queryParams = {
        if (selectedGender.value.isNotEmpty) 'gender': selectedGender.value,
        if (selectedBloodGroup.value.isNotEmpty) 'blood_group': selectedBloodGroup.value,
        if (dateFrom.value.isNotEmpty) 'date_from': dateFrom.value,
        if (dateTo.value.isNotEmpty) 'date_to': dateTo.value,
        if (searchQuery.value.isNotEmpty) 'search': searchQuery.value,
        'sort_by': sortBy.value,
        'sort_direction': sortDirection.value,
        'page': currentPage.value.toString(),
        'per_page': perPage.value.toString(),
      };

      final Uri uri = Uri.parse(ApiEndpoints.patientEndpoint).replace(queryParameters: queryParams);

      final dynamic result = await _httpClient.get(uri.toString());

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          final List<dynamic> patientsList = result['data']['patients'] ?? [];
          patients.value = patientsList.map((json) => PatientModel.fromJson(json)).toList();

          // Save pagination info
          totalPatients.value = result['data']['total'] is int
              ? result['data']['total']
              : int.tryParse(result['data']['total'].toString()) ?? 0;

          perPage.value = result['data']['per_page'] is int
              ? result['data']['per_page']
              : int.tryParse(result['data']['per_page'].toString()) ?? 20;

          // If we're on a page that doesn't exist anymore, go back to page 1
          if (patients.isEmpty && totalPatients.value > 0 && currentPage.value > 1) {
            currentPage.value = 1;
            fetchPatients();
          }
        } else {
          hasError.value = true;
          errorMessage.value = result['message'] ?? 'Failed to fetch patients';
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to connect to server: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<PatientModel?> getPatientDetails(String id) async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final dynamic result = await _httpClient.get('${ApiEndpoints.patientEndpoint}$id');

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          return PatientModel.fromJson(result['data']);
        } else {
          hasError.value = true;
          errorMessage.value = result['message'] ?? 'Failed to get patient details';
        }
      }
      return null;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to connect to server: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createPatient(Map<String, dynamic> patientData) async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final dynamic result = await _httpClient.post(
        ApiEndpoints.patientEndpoint,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(patientData),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 201 || result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Patient created successfully');
          fetchPatients();
        } else {
          hasError.value = true;
          errorMessage.value = result['message'] ?? 'Failed to create patient';
          SnackBarUtils.showErrorSnackBar(errorMessage.value);
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to connect to server: $e';
      SnackBarUtils.showErrorSnackBar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePatient(String id, Map<String, dynamic> patientData) async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final dynamic result = await _httpClient.put(
        '${ApiEndpoints.patientEndpoint}$id',
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(patientData),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Patient updated successfully');
          fetchPatients();
        } else {
          hasError.value = true;
          errorMessage.value = result['message'] ?? 'Failed to update patient';
          SnackBarUtils.showErrorSnackBar(errorMessage.value);
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to connect to server: $e';
      SnackBarUtils.showErrorSnackBar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePatient(String id) async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final dynamic result = await _httpClient.delete(
        '${ApiEndpoints.patientEndpoint}$id',
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Patient deleted successfully');
          fetchPatients();
        } else {
          hasError.value = true;
          errorMessage.value = result['message'] ?? 'Failed to delete patient';
          SnackBarUtils.showErrorSnackBar(errorMessage.value);
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to connect to server: $e';
      SnackBarUtils.showErrorSnackBar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  void resetFilters() {
    searchQuery.value = '';
    selectedGender.value = '';
    selectedBloodGroup.value = '';
    dateFrom.value = '';
    dateTo.value = '';
    sortBy.value = 'created_at';
    sortDirection.value = 'desc';
    currentPage.value = 1;
    fetchPatients();
  }

  void setPage(int page) {
    if (page < 1) page = 1;
    int maxPage = (totalPatients.value / perPage.value).ceil();
    if (page > maxPage) page = maxPage;
    currentPage.value = page;
    fetchPatients();
  }

  void nextPage() {
    int maxPages = (totalPatients.value / perPage.value).ceil();
    if (currentPage.value < maxPages) {
      currentPage.value++;
      fetchPatients();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchPatients();
    }
  }
}