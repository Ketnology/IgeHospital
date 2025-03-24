import 'package:get/get.dart';
import 'package:ige_hospital/constants/api_endpoints.dart';
import 'package:ige_hospital/provider/auth_service.dart';
import 'package:ige_hospital/utils/http_client.dart';

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
  final HttpClient _httpClient = HttpClient();
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
      final dynamic result = await _httpClient.post(
        ApiEndpoints.dashboard,
        headers: {
          "Content-Type": "application/json",
        },
      );

      Get.log("Dashboard response received");

      if (result is Map<String, dynamic>) {
        if (result["status"] == 200) {
          Get.log("Dashboard data processing: ${result["data"]["doctors_count"]}");

          doctorCount.value = result["data"]["doctors_count"];
          patientCount.value = result["data"]["patients_count"];
          receptionistCount.value = result["data"]["receptionists_count"];
          adminCount.value = result["data"]["admins_count"];

          if (result["data"]["recent_appointments"] != null) {
            final appointmentsList = result["data"]["recent_appointments"] as List;
            recentAppointments.value = appointmentsList
                .map((json) => AppointmentData.fromJson(json))
                .toList();
          }
        } else {
          hasError.value = true;
          errorMessage.value = result["message"] ?? "Failed to fetch dashboard data";
        }
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