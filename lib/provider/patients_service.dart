import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ige_hospital/constants/api_endpoints.dart';
import 'package:ige_hospital/provider/auth_service.dart';
import 'package:ige_hospital/models/patient_model.dart';
import 'package:ige_hospital/utils/http_client.dart';

class PatientsService extends GetxService {
  final HttpClient _httpClient = HttpClient();
  final AuthService authService = Get.find<AuthService>();

  final RxList<PatientModel> patients = <PatientModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final RxInt totalPatients = 0.obs;
  final RxInt currentPage = 1.obs;
  final RxInt perPage = 1000.obs;

  final RxString searchQuery = ''.obs;
  final RxString selectedGender = ''.obs;
  final RxString selectedBloodGroup = ''.obs;
  final RxString dateFrom = ''.obs;
  final RxString dateTo = ''.obs;
  final RxString sortBy = 'created_at'.obs;
  final RxString sortDirection = 'desc'.obs;

  Future<void> fetchPatients() async {
    if (isLoading.value) return;

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final Map<String, dynamic> payload = {
        'gender': selectedGender.value,
        'blood_group': selectedBloodGroup.value,
        'date_from': dateFrom.value,
        'date_to': dateTo.value,
        'search': searchQuery.value,
        'sort_by': sortBy.value,
        'sort_direction': sortDirection.value,
        'per_page': perPage.value,
        'page': currentPage.value,
      };

      final response = await _httpClient.post(
        ApiEndpoints.patients,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authService.token.value}',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 200) {
          final List<dynamic> patientsList = data['data']['patients'] ?? [];
          patients.value = patientsList.map((json) => PatientModel.fromJson(json)).toList();
          totalPatients.value = data['data']['total'] ?? 0;
          perPage.value = data['data']['per_page'] ?? 10;

          // If we're on a page that doesn't exist anymore, go back to page 1
          if (patients.isEmpty && totalPatients.value > 0 && currentPage.value > 1) {
            currentPage.value = 1;
            fetchPatients();
          }
        } else {
          hasError.value = true;
          errorMessage.value = data['message'] ?? 'Failed to fetch patients';
        }
      } else if (response.statusCode == 401) {
        hasError.value = true;
        errorMessage.value = 'Session expired. Please login again.';
        authService.logout();
      } else {
        hasError.value = true;
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to connect to server: $e';
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