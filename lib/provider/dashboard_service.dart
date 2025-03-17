import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ige_hospital/constants/api_endpoints.dart';
import 'package:ige_hospital/provider/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class DashboardService extends GetxController {
  final AuthService authService = Get.find<AuthService>();

  final RxInt doctorCount = 0.obs;
  final RxInt patientCount = 0.obs;
  final RxInt receptionistCount = 0.obs;
  final RxInt adminCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<AppointmentData> recentAppointments = <AppointmentData>[].obs;

  // Keys for shared preferences
  static const String _keyDoctorCount = 'dashboard_doctor_count';
  static const String _keyPatientCount = 'dashboard_patient_count';
  static const String _keyReceptionistCount = 'dashboard_receptionist_count';
  static const String _keyAdminCount = 'dashboard_admin_count';
  static const String _keyAppointments = 'dashboard_appointments';
  static const String _keyLastUpdated = 'dashboard_last_updated';

  @override
  void onInit() {
    super.onInit();
    // Load saved values first, then fetch fresh data
    _loadSavedData().then((_) => fetchDashboardData());
  }

  // Load saved dashboard data from SharedPreferences
  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      doctorCount.value = prefs.getInt(_keyDoctorCount) ?? 0;
      patientCount.value = prefs.getInt(_keyPatientCount) ?? 0;
      receptionistCount.value = prefs.getInt(_keyReceptionistCount) ?? 0;
      adminCount.value = prefs.getInt(_keyAdminCount) ?? 0;

      final appointmentsJson = prefs.getString(_keyAppointments);
      if (appointmentsJson != null) {
        try {
          final List<dynamic> appointmentsList = jsonDecode(appointmentsJson);
          recentAppointments.value = appointmentsList
              .map((json) => AppointmentData.fromJson(json))
              .toList();
        } catch (e) {
          Get.log("Error parsing saved appointments: $e");
        }
      }

      // Log when the data was last updated
      final lastUpdated = prefs.getString(_keyLastUpdated);
      if (lastUpdated != null) {
        Get.log("Dashboard data last updated: $lastUpdated");
      }
    } catch (e) {
      Get.log("Error loading saved dashboard data: $e");
    }
  }

  // Save dashboard data to SharedPreferences
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt(_keyDoctorCount, doctorCount.value);
      await prefs.setInt(_keyPatientCount, patientCount.value);
      await prefs.setInt(_keyReceptionistCount, receptionistCount.value);
      await prefs.setInt(_keyAdminCount, adminCount.value);

      final List<Map<String, dynamic>> appointmentsJson = recentAppointments
          .map((appointment) => {
        'id': appointment.id,
        'doctor': appointment.doctor,
        'patient': appointment.patient,
        'date_time': appointment.dateTime,
        'status': appointment.status,
      })
          .toList();
      await prefs.setString(_keyAppointments, jsonEncode(appointmentsJson));

      // Save current timestamp
      final now = DateTime.now().toIso8601String();
      await prefs.setString(_keyLastUpdated, now);

      Get.log("Dashboard data saved at: $now");
    } catch (e) {
      Get.log("Error saving dashboard data: $e");
    }
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
          // Update observable values
          doctorCount.value = data["data"]["doctors"] ?? doctorCount.value;
          patientCount.value = data["data"]["patients"] ?? patientCount.value;
          receptionistCount.value = data["data"]["receptionists"] ?? receptionistCount.value;
          adminCount.value = data["data"]["admins"] ?? adminCount.value;

          if (data["data"]["recent_appointments"] != null) {
            final appointmentsList = data["data"]["recent_appointments"] as List;
            recentAppointments.value = appointmentsList
                .map((json) => AppointmentData.fromJson(json))
                .toList();
          }

          // Save the updated values
          _saveData();
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

  // Clear saved data (useful for logout)
  Future<void> clearSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyDoctorCount);
      await prefs.remove(_keyPatientCount);
      await prefs.remove(_keyReceptionistCount);
      await prefs.remove(_keyAdminCount);
      await prefs.remove(_keyAppointments);
      await prefs.remove(_keyLastUpdated);

      Get.log("Dashboard saved data cleared");
    } catch (e) {
      Get.log("Error clearing dashboard data: $e");
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}