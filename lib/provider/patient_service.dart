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
  final RxInt perPage = 1000.obs;

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
    Get.log("[PatientsService] Initializing PatientsService");
    super.onInit();
    fetchPatients(); // Changed from fetchAllPatients to fetchPatients
  }

  // Parse API response safely, handling both array and object responses
  List<dynamic> _safelyParseResponse(dynamic result) {
    Get.log(
        "[PatientsService] Attempting to parse API response: ${result?.runtimeType}");
    try {
      // Case 1: Response is a Map with data.patients field
      if (result is Map<String, dynamic>) {
        Get.log("[PatientsService] Response is a Map");
        if (result['data'] != null) {
          Get.log("[PatientsService] 'data' field exists in response");
          if (result['data']['patients'] != null) {
            Get.log(
                "[PatientsService] 'data.patients' field exists, returning it");
            return result['data']['patients'] as List<dynamic>;
          } else if (result['data'] is List) {
            Get.log("[PatientsService] 'data' field is a List, returning it");
            return result['data'] as List<dynamic>;
          }
        } else if (result['patients'] != null) {
          Get.log(
              "[PatientsService] 'patients' field exists at root level, returning it");
          return result['patients'] as List<dynamic>;
        }

        // Log what fields are actually in the response
        Get.log(
            "[PatientsService] Available fields in response: ${result.keys.join(', ')}");
        if (result['data'] != null) {
          if (result['data'] is Map) {
            Get.log(
                "[PatientsService] Fields in data object: ${(result['data'] as Map).keys.join(', ')}");
          }
        }
      }

      // Case 2: Response is a direct array of patients
      if (result is List) {
        Get.log("[PatientsService] Response is a List, returning directly");
        return result;
      }

      // Default empty list if no pattern matches
      Get.log(
          "[PatientsService] No recognizable pattern in response, returning empty list");
      return [];
    } catch (e) {
      Get.log("[PatientsService] Error parsing response: $e");
      errorMessage.value = 'Error parsing response: $e';
      return [];
    }
  }

  Future<void> fetchPatients() async {
    Get.log("[PatientsService] fetchPatients() called");
    Get.log(
        "[PatientsService] Current filter state - search: '${searchQuery.value}', gender: '${selectedGender.value}', blood group: '${selectedBloodGroup.value}', dateFrom: '${dateFrom.value}', dateTo: '${dateTo.value}'");

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final Map<String, String> queryParams = {
        if (searchQuery.value.isNotEmpty) 'search': searchQuery.value,
        if (selectedGender.value.isNotEmpty) 'gender': selectedGender.value,
        if (selectedBloodGroup.value.isNotEmpty)
          'blood_group': selectedBloodGroup.value,
        if (dateFrom.value.isNotEmpty) 'date_from': dateFrom.value,
        if (dateTo.value.isNotEmpty) 'date_to': dateTo.value,
        'sort_by': sortBy.value,
        'sort_direction': sortDirection.value,
        'page': currentPage.value.toString(),
        'per_page': perPage.value.toString(),
      };
      Get.log("[PatientsService] API query params: $queryParams");

      final Uri uri = Uri.parse(ApiEndpoints.patientEndpoint)
          .replace(queryParameters: queryParams);
      Get.log("[PatientsService] Making GET request to: $uri");

      final dynamic result = await _httpClient.get(uri.toString());
      Get.log("[PatientsService] Received API response");

      // Parse the response
      final patientsList = _safelyParseResponse(result);
      Get.log(
          "[PatientsService] Parsed ${patientsList.length} patients from API response");

      if (patientsList.isNotEmpty) {
        patients.value =
            patientsList.map((json) => PatientModel.fromJson(json)).toList();
        Get.log(
            "[PatientsService] Updated patients.value with ${patients.length} patients");

        // Get total count for pagination
        int total = patientsList.length;
        Get.log("[PatientsService] Default total count: $total");

        // Try to get total from response if available
        if (result is Map<String, dynamic>) {
          Get.log("[PatientsService] Looking for pagination metadata");
          if (result['meta'] != null && result['meta']['total'] != null) {
            total = result['meta']['total'];
            Get.log("[PatientsService] Found total from meta.total: $total");
          } else if (result['data'] is Map && result['data']['total'] != null) {
            total = result['data']['total'] is int
                ? result['data']['total']
                : int.tryParse(result['data']['total'].toString()) ??
                    patientsList.length;
            Get.log("[PatientsService] Found total from data.total: $total");
          } else {
            Get.log(
                "[PatientsService] Could not find pagination metadata in response");
          }
        }

        totalPatients.value = total;
        Get.log("[PatientsService] totalPatients.value set to: $total");
      } else {
        Get.log(
            "[PatientsService] No patients returned from API, setting empty list");
        patients.value = [];
        if (currentPage.value > 1) {
          Get.log(
              "[PatientsService] Current page > 1 but no results, resetting to page 1");
          currentPage.value = 1;
          fetchPatients();
        }
      }
    } catch (e) {
      Get.log("[PatientsService] Error in fetchPatients: $e");
      Get.log("[PatientsService] Error stack trace: ${StackTrace.current}");
      hasError.value = true;
      errorMessage.value = 'Failed to fetch patients: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<PatientModel?> getPatientDetails(String id) async {
    Get.log("[PatientsService] getPatientDetails() called for id: $id");
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      Get.log("[PatientsService] Fetching patient from API");
      final dynamic result =
          await _httpClient.get('${ApiEndpoints.patientEndpoint}/$id');
      Get.log("[PatientsService] Received API response for patient details");

      PatientModel? patient;

      if (result is Map<String, dynamic>) {
        Get.log(
            "[PatientsService] Response is a Map with keys: ${result.keys.join(', ')}");
        // Try to find patient data in various places in the response
        if (result['data'] != null) {
          Get.log("[PatientsService] Found 'data' field in response");
          try {
            patient = PatientModel.fromJson(result['data']);
            Get.log(
                "[PatientsService] Successfully created PatientModel from data field");
          } catch (e) {
            Get.log(
                "[PatientsService] Error creating PatientModel from data field: $e");
          }
        } else if (result['patient'] != null) {
          Get.log("[PatientsService] Found 'patient' field in response");
          try {
            patient = PatientModel.fromJson(result['patient']);
            Get.log(
                "[PatientsService] Successfully created PatientModel from patient field");
          } catch (e) {
            Get.log(
                "[PatientsService] Error creating PatientModel from patient field: $e");
          }
        } else {
          Get.log(
              "[PatientsService] No recognized patient data structure in response");
        }
      } else if (result is List && result.isNotEmpty) {
        // In case the API returns a list with one patient
        Get.log(
            "[PatientsService] Response is a List with ${result.length} items");
        try {
          patient = PatientModel.fromJson(result[0]);
          Get.log(
              "[PatientsService] Successfully created PatientModel from first list item");
        } catch (e) {
          Get.log(
              "[PatientsService] Error creating PatientModel from list item: $e");
        }
      } else {
        Get.log(
            "[PatientsService] Unexpected response type: ${result?.runtimeType}");
      }

      if (patient != null) {
        return patient;
      } else {
        Get.log(
            "[PatientsService] Could not find patient data in the response");
        hasError.value = true;
        errorMessage.value = 'Could not find patient data in the response';
        return null;
      }
    } catch (e) {
      Get.log("[PatientsService] Error in getPatientDetails: $e");
      Get.log("[PatientsService] Error stack trace: ${StackTrace.current}");
      hasError.value = true;
      errorMessage.value = 'Failed to get patient details: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createPatient(Map<String, dynamic> patientData) async {
    Get.log(
        "[PatientsService] createPatient() called with data: ${jsonEncode(patientData)}");
    isLoading.value = true;
    hasError.value = false;

    try {
      Get.log(
          "[PatientsService] Sending POST request to ${ApiEndpoints.patientEndpoint}");
      final dynamic result = await _httpClient.post(
        ApiEndpoints.patientEndpoint,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(patientData),
      );
      Get.log("[PatientsService] Received response");

      bool success = false;

      if (result is Map<String, dynamic>) {
        Get.log(
            "[PatientsService] Response is a Map with keys: ${result.keys.join(', ')}");
        // Check various success indicators
        if (result['status'] == 201 || result['status'] == 200) {
          Get.log(
              "[PatientsService] Request successful (status ${result['status']})");
          success = true;
        } else {
          Get.log(
              "[PatientsService] Request failed with status: ${result['status']}");
          if (result['message'] != null) {
            Get.log("[PatientsService] Error message: ${result['message']}");
          }
        }
      } else {
        Get.log(
            "[PatientsService] Unexpected response type: ${result?.runtimeType}");
      }

      if (success) {
        Get.log(
            "[PatientsService] Patient created successfully, refreshing list");
        SnackBarUtils.showSuccessSnackBar('Patient created successfully');
        fetchPatients(); // Refresh the list from API
      } else {
        // Handle error
        Get.log("[PatientsService] Failed to create patient");
        hasError.value = true;
        if (result is Map<String, dynamic> && result['message'] != null) {
          errorMessage.value = result['message'];
          Get.log("[PatientsService] Error message: ${result['message']}");
        } else {
          errorMessage.value = 'Failed to create patient';
        }
        SnackBarUtils.showErrorSnackBar(errorMessage.value);
      }
    } catch (e) {
      Get.log("[PatientsService] Error in createPatient: $e");
      Get.log("[PatientsService] Error stack trace: ${StackTrace.current}");
      hasError.value = true;
      errorMessage.value = 'Failed to connect to server: $e';
      SnackBarUtils.showErrorSnackBar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePatient(
      String id, Map<String, dynamic> patientData) async {
    Get.log(
        "[PatientsService] updatePatient() called for id: $id with data: ${jsonEncode(patientData)}");
    isLoading.value = true;
    hasError.value = false;

    try {
      Get.log(
          "[PatientsService] Sending PUT request to ${ApiEndpoints.patientEndpoint}/$id");
      final dynamic result = await _httpClient.put(
        '${ApiEndpoints.patientEndpoint}/$id',
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(patientData),
      );
      Get.log("[PatientsService] Received response");

      bool success = false;

      if (result is Map<String, dynamic>) {
        Get.log(
            "[PatientsService] Response is a Map with keys: ${result.keys.join(', ')}");
        // Check for success
        if (result['status'] == 200 || result['status'] == 201) {
          Get.log(
              "[PatientsService] Request successful (status ${result['status']})");
          success = true;
        } else {
          Get.log(
              "[PatientsService] Request failed with status: ${result['status']}");
          if (result['message'] != null) {
            Get.log("[PatientsService] Error message: ${result['message']}");
          }
        }
      } else {
        Get.log(
            "[PatientsService] Unexpected response type: ${result?.runtimeType}");
      }

      if (success) {
        Get.log(
            "[PatientsService] Patient updated successfully, refreshing list");
        SnackBarUtils.showSuccessSnackBar('Patient updated successfully');
        // fetchPatients(); // Refresh the list from API
      } else {
        // Handle error
        hasError.value = true;
        if (result is Map<String, dynamic> && result['message'] != null) {
          errorMessage.value = result['message'];
        } else {
          errorMessage.value = 'Failed to update patient';
        }
        SnackBarUtils.showErrorSnackBar(errorMessage.value);
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
        '${ApiEndpoints.patientEndpoint}/$id',
      );

      bool success = false;

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200 || result['status'] == 204) {
          success = true;
        }
      }

      if (success) {
        Get.log(
            "[PatientsService] Patient deleted successfully, refreshing list");
        SnackBarUtils.showSuccessSnackBar('Patient deleted successfully');
        fetchPatients(); // Refresh the list from API
      } else {
        hasError.value = true;
        if (result is Map<String, dynamic> && result['message'] != null) {
          errorMessage.value = result['message'];
        } else {
          errorMessage.value = 'Failed to delete patient';
        }
        SnackBarUtils.showErrorSnackBar(errorMessage.value);
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
    if (maxPage < 1) maxPage = 1;
    if (page > maxPage) page = maxPage;
    currentPage.value = page;
    fetchPatients();
  }

  void nextPage() {
    int maxPages = (totalPatients.value / perPage.value).ceil();
    if (maxPages < 1) maxPages = 1;
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
