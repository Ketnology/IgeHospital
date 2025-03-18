import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ige_hospital/constants/api_endpoints.dart';
import 'package:ige_hospital/provider/auth_service.dart';
import 'package:ige_hospital/utils/snack_bar_utils.dart';

class AppointmentModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String departmentId;
  final String opdDate;
  final String problem;
  final bool isCompleted;
  final String customField;
  final String appointmentDate;
  final String appointmentTime;
  final String date;
  final String time;
  final String doctor;
  final String doctorName;
  final String? doctorImage;
  final String doctorDepartment;
  final String patient;
  final String patientName;
  final String? patientImage;
  final String createdAt;
  final String updatedAt;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.departmentId,
    required this.opdDate,
    required this.problem,
    required this.isCompleted,
    required this.customField,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.date,
    required this.time,
    required this.doctor,
    required this.doctorName,
    this.doctorImage,
    required this.doctorDepartment,
    required this.patient,
    required this.patientName,
    this.patientImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? '',
      patientId: json['patient_id'] ?? '',
      doctorId: json['doctor_id'] ?? '',
      departmentId: json['department_id'] ?? '',
      opdDate: json['opd_date'] ?? '',
      problem: json['problem'] ?? '',
      isCompleted: json['is_completed'] ?? false,
      customField: json['custom_field']?.toString() ?? '',
      appointmentDate: json['appointment_date'] ?? '',
      appointmentTime: json['appointment_time'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      doctor: json['doctor'] ?? '',
      doctorName: json['doctor_name'] ?? '',
      doctorImage: json['doctor_image'],
      doctorDepartment: json['doctor_department'] ?? '',
      patient: json['patient'] ?? '',
      patientName: json['patient_name'] ?? '',
      patientImage: json['patient_image'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'doctor_id': doctorId,
        'department_id': departmentId,
        'opd_date': opdDate,
        'problem': problem,
        'is_completed': isCompleted,
        'custom_field': customField,
        'appointment_date': appointmentDate,
        'appointment_time': appointmentTime,
        'date': date,
        'time': time,
        'doctor': doctor,
        'doctor_name': doctorName,
        'doctor_image': doctorImage,
        'doctor_department': doctorDepartment,
        'patient': patient,
        'patient_name': patientName,
        'patient_image': patientImage,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

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
        'per_page': perPage.value,
        'page': currentPage.value,
      };

      final response = await http.post(
        Uri.parse(ApiEndpoints.appointments),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authService.token.value}',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 200) {
          final responseData = AppointmentResponse.fromJson(data['data']);
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
              data['message'] ?? 'Failed to fetch appointments';
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

  void setPage(int page) {
    if (page < 1) page = 1;
    currentPage.value = page;
    fetchAppointments();
  }

  void nextPage() {
    int maxPages = (totalAppointments.value / perPage.value).ceil();
    if (currentPage.value < maxPages) {
      currentPage.value++;
      fetchAppointments();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchAppointments();
    }
  }

  Future<void> createAppointment(Map<String, dynamic> appointmentData) async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.appointments),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authService.token.value}',
        },
        body: jsonEncode(appointmentData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        SnackBarUtils.showSuccessSnackBar('Appointment created successfully');
        fetchAppointments();
      } else {
        hasError.value = true;
        errorMessage.value = data['message'] ?? 'Failed to create appointment';
        SnackBarUtils.showErrorSnackBar(errorMessage.value);
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to connect to server';
      SnackBarUtils.showErrorSnackBar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateAppointment(String id, Map<String, dynamic> appointmentData) async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final response = await http.put(
        Uri.parse('${ApiEndpoints.appointmentDetails}$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authService.token.value}',
        },
        body: jsonEncode(appointmentData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        SnackBarUtils.showSuccessSnackBar('Appointment updated successfully');
        fetchAppointments();
      } else {
        hasError.value = true;
        errorMessage.value = data['message'] ?? 'Failed to update appointment';
        SnackBarUtils.showErrorSnackBar(errorMessage.value);
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
      final response = await http.delete(
        Uri.parse('${ApiEndpoints.appointmentDetails}$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authService.token.value}',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        SnackBarUtils.showSuccessSnackBar('Appointment deleted successfully');
        fetchAppointments();
      } else {
        hasError.value = true;
        errorMessage.value = data['message'] ?? 'Failed to delete appointment';
        SnackBarUtils.showErrorSnackBar(errorMessage.value);
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
