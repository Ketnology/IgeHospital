import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ige_hospital/constants/api_endpoints.dart';
import 'package:ige_hospital/provider/auth_service.dart';

class AppointmentData {
  final String id;
  final Map<String, dynamic> doctor;
  final Map<String, dynamic> patient;
  final Map<String, dynamic> dateTime;
  final String status;

  AppointmentData({
    required this.id,
    required this.doctor,
    required this.patient,
    required this.dateTime,
    required this.status,
  });

  factory AppointmentData.fromJson(Map<String, dynamic> json) {
    return AppointmentData(
      id: json['id'] ?? '',
      doctor: json['doctor'] ?? {},
      patient: json['patient'] ?? {},
      dateTime: json['date_time'] ?? {},
      status: json['status'] ?? 'pending',
    );
  }
}

class DashboardService extends GetxService {
  final AuthService authService = Get.find<AuthService>();

  final RxInt doctorCount = 0.obs;
  final RxInt patientCount = 0.obs;
  final RxInt receptionistCount = 0.obs;
  final RxInt adminCount = 0.obs;

  final RxList<AppointmentData> recentAppointments = <AppointmentData>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<DashboardService> init() async {
    await fetchDashboardData();
    return this;
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.dashboard),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${authService.token.value}",
        },
      );

      Get.log("Dashboard response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["status"] == 200) {
          Get.log("Dashboard response data data: ${data["data"]["doctors_count"]}");

          doctorCount.value = data["data"]["doctors_count"];
          patientCount.value = data["data"]["patients_count"];
          receptionistCount.value = data["data"]["receptionists_count"];
          adminCount.value = data["data"]["admins_count"];

          if (data["data"]["recent_appointments"] != null) {
            final appointmentsList = data["data"]["recent_appointments"] as List;
            recentAppointments.value = appointmentsList
                .map((json) => AppointmentData.fromJson(json))
                .toList();
          }
        } else {
          hasError.value = true;
          errorMessage.value = data["message"] ?? "Failed to fetch dashboard data";
        }
      } else {
        hasError.value = true;
        errorMessage.value = "Server error: ${response.statusCode}";
      }
    } catch (e) {
      Get.log("Dashboard error: $e");
      hasError.value = true;
      errorMessage.value = "Failed to connect to server";
    } finally {
      isLoading.value = false;
    }
  }

  void refreshDashboardData() {
    fetchDashboardData();
  }
}