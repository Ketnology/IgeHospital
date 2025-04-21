import 'dart:convert';
import 'package:get/get.dart';
import 'package:ige_hospital/constants/api_endpoints.dart';
import 'package:ige_hospital/models/appointment_model.dart';
import 'package:ige_hospital/provider/auth_service.dart';
import 'package:ige_hospital/utils/http_client.dart';
import 'package:ige_hospital/utils/snack_bar_utils.dart';

class AppointmentResponse {
  final int total;
  final int page;
  final int perPage;
  final List<AppointmentModel> appointments;

  AppointmentResponse({
    required this.total,
    required this.page,
    required this.perPage,
    required this.appointments,
  });

  factory AppointmentResponse.fromJson(Map<String, dynamic> json) {
    return AppointmentResponse(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      perPage: json['per_page'] ?? 1000,
      appointments: (json['appointments'] as List?)
              ?.map((e) => AppointmentModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class AppointmentsService extends GetxService {
  final HttpClient _httpClient = HttpClient();
  final AuthService authService = Get.find<AuthService>();

  final RxList<AppointmentModel> appointments = <AppointmentModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final RxInt totalAppointments = 0.obs;
  final RxInt currentPage = 1.obs;
  final RxInt perPage = 1000.obs;

  final RxString searchQuery = ''.obs;
  final RxString selectedDoctorId = ''.obs;
  final RxString selectedPatientId = ''.obs;
  final RxString selectedDepartmentId = ''.obs;
  final RxString dateFrom = ''.obs;
  final RxString dateTo = ''.obs;
  final RxBool filterCompleted = false.obs;
  final RxString sortBy = 'opd_date'.obs;
  final RxString sortDirection = 'asc'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    if (isLoading.value) return;

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final Map<String, dynamic> payload = {
        'doctor_id': selectedDoctorId.value,
        'patient_id': selectedPatientId.value,
        'department_id': selectedDepartmentId.value,
        'date_from': dateFrom.value,
        'date_to': dateTo.value,
        'is_completed': filterCompleted.value,
        'search': searchQuery.value,
        'sort_by': sortBy.value,
        'sort_direction': sortDirection.value,
        'per_page': 1000,
        'page': 1,
      };

      final dynamic result = await _httpClient.post(
        ApiEndpoints.appointmentEndpoint,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          final responseData = AppointmentResponse.fromJson(result['data']);
          appointments.value = responseData.appointments;
          totalAppointments.value = responseData.total;
          perPage.value = responseData.perPage;

          // If we're on a page that doesn't exist anymore, go back to page 1
          if (appointments.isEmpty &&
              totalAppointments.value > 0 &&
              currentPage.value > 1) {
            currentPage.value = 1;
            fetchAppointments();
          }
        } else {
          hasError.value = true;
          errorMessage.value =
              result['message'] ?? 'Failed to fetch appointments';
        }
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
    selectedDoctorId.value = '';
    selectedPatientId.value = '';
    selectedDepartmentId.value = '';
    dateFrom.value = '';
    dateTo.value = '';
    filterCompleted.value = false;
    sortBy.value = 'opd_date';
    sortDirection.value = 'asc';
    currentPage.value = 1;
    fetchAppointments();
  }

  Future<void> createAppointment(Map<String, dynamic> appointmentData) async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final dynamic result = await _httpClient.post(
        ApiEndpoints.appointmentEndpoint,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(appointmentData),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 201 || result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Appointment created successfully');
          fetchAppointments();
        } else {
          hasError.value = true;
          errorMessage.value =
              result['message'] ?? 'Failed to create appointment';
          SnackBarUtils.showErrorSnackBar(errorMessage.value);
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to connect to server';
      SnackBarUtils.showErrorSnackBar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateAppointment(
      String id, Map<String, dynamic> appointmentData) async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final dynamic result = await _httpClient.put(
        '${ApiEndpoints.appointmentEndpoint}/$id',
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(appointmentData),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Appointment updated successfully');
          fetchAppointments();
        } else {
          hasError.value = true;
          errorMessage.value =
              result['message'] ?? 'Failed to update appointment';
          SnackBarUtils.showErrorSnackBar(errorMessage.value);
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to connect to server';
      SnackBarUtils.showErrorSnackBar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAppointment(String id) async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final dynamic result = await _httpClient.delete(
        '${ApiEndpoints.appointmentEndpoint}/$id',
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Appointment deleted successfully');
          fetchAppointments();
        } else {
          hasError.value = true;
          errorMessage.value =
              result['message'] ?? 'Failed to delete appointment';
          SnackBarUtils.showErrorSnackBar(errorMessage.value);
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to connect to server';
      SnackBarUtils.showErrorSnackBar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
}
