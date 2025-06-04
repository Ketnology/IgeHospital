import 'dart:convert';
import 'package:get/get.dart';
import 'package:ige_hospital/constants/api_endpoints.dart';
import 'package:ige_hospital/models/consultation_model.dart';
import 'package:ige_hospital/utils/http_client.dart';
import 'package:ige_hospital/utils/snack_bar_utils.dart';

class ConsultationService extends GetxService {
  final HttpClient _httpClient = HttpClient();

  // ========== GET ALL CONSULTATIONS ==========
  Future<Map<String, dynamic>> getConsultations({
    String? doctorId,
    String? patientId,
    String? status,
    String? dateFrom,
    String? dateTo,
    String? search,
    String sortBy = 'consultation_date',
    String sortDirection = 'desc',
    int perPage = 15,
    int page = 1,
  }) async {
    try {
      final Map<String, String> queryParams = {
        if (doctorId != null && doctorId.isNotEmpty) 'doctor_id': doctorId,
        if (patientId != null && patientId.isNotEmpty) 'patient_id': patientId,
        if (status != null && status.isNotEmpty) 'status': status,
        if (dateFrom != null && dateFrom.isNotEmpty) 'date_from': dateFrom,
        if (dateTo != null && dateTo.isNotEmpty) 'date_to': dateTo,
        if (search != null && search.isNotEmpty) 'search': search,
        'sort_by': sortBy,
        'sort_direction': sortDirection,
        'per_page': perPage.toString(),
        'page': page.toString(),
      };

      final Uri uri = Uri.parse('${ApiEndpoints.baseUrl}/live-consultations')
          .replace(queryParameters: queryParams);
      final dynamic result = await _httpClient.get(uri.toString());

      if (result is Map<String, dynamic> && result['status'] == 200) {
        final List<dynamic> consultationsList = result['data']['consultations'] ?? [];
        final List<ConsultationModel> consultations = consultationsList
            .map((json) => ConsultationModel.fromJson(json))
            .toList();

        return {
          'consultations': consultations,
          'total': result['data']['total'] ?? 0,
          'current_page': result['data']['current_page'] ?? 1,
          'last_page': result['data']['last_page'] ?? 1,
          'per_page': result['data']['per_page'] ?? perPage,
        };
      } else {
        throw Exception(result['message'] ?? 'Failed to fetch consultations');
      }
    } catch (e) {
      Get.log("Error in getConsultations: $e");
      throw Exception('Failed to fetch consultations: $e');
    }
  }

  // ========== GET CONSULTATION DETAILS ==========
  Future<ConsultationModel> getConsultationDetails(String id) async {
    try {
      final dynamic result = await _httpClient
          .get('${ApiEndpoints.baseUrl}/live-consultations/$id');

      if (result is Map<String, dynamic> && result['status'] == 200) {
        return ConsultationModel.fromJson(result['data']);
      } else {
        throw Exception(result['message'] ?? 'Failed to get consultation details');
      }
    } catch (e) {
      Get.log("Error in getConsultationDetails: $e");
      throw Exception('Failed to get consultation details: $e');
    }
  }

  // ========== CREATE CONSULTATION ==========
  Future<ConsultationModel> createConsultation(Map<String, dynamic> consultationData) async {
    try {
      final dynamic result = await _httpClient.post(
        '${ApiEndpoints.baseUrl}/live-consultations',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(consultationData),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 201 || result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Consultation created successfully');
          return ConsultationModel.fromJson(result['data']);
        } else {
          throw Exception(result['message'] ?? 'Failed to create consultation');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in createConsultation: $e");
      throw Exception('Failed to create consultation: $e');
    }
  }

  // ========== UPDATE CONSULTATION ==========
  Future<ConsultationModel> updateConsultation(
      String id, Map<String, dynamic> consultationData) async {
    try {
      final dynamic result = await _httpClient.put(
        '${ApiEndpoints.baseUrl}/live-consultations/$id',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(consultationData),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Consultation updated successfully');
          return ConsultationModel.fromJson(result['data']);
        } else {
          throw Exception(result['message'] ?? 'Failed to update consultation');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in updateConsultation: $e");
      throw Exception('Failed to update consultation: $e');
    }
  }

  // ========== DELETE CONSULTATION ==========
  Future<void> deleteConsultation(String id) async {
    try {
      final dynamic result = await _httpClient
          .delete('${ApiEndpoints.baseUrl}/live-consultations/$id');

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Consultation deleted successfully');
        } else {
          throw Exception(result['message'] ?? 'Failed to delete consultation');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in deleteConsultation: $e");
      throw Exception('Failed to delete consultation: $e');
    }
  }

  // ========== JOIN CONSULTATION ==========
  Future<void> joinConsultation(String id) async {
    try {
      final dynamic result = await _httpClient
          .post('${ApiEndpoints.baseUrl}/live-consultations/$id/join');

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Joined consultation successfully');
        } else {
          throw Exception(result['message'] ?? 'Unable to join consultation at this time');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in joinConsultation: $e");
      throw Exception('Failed to join consultation: $e');
    }
  }

  // ========== START CONSULTATION ==========
  Future<void> startConsultation(String id) async {
    try {
      final dynamic result = await _httpClient
          .post('${ApiEndpoints.baseUrl}/live-consultations/$id/start');

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Consultation started successfully');
        } else {
          throw Exception(result['message'] ?? 'Unable to start consultation');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in startConsultation: $e");
      throw Exception('Failed to start consultation: $e');
    }
  }

  // ========== END CONSULTATION ==========
  Future<void> endConsultation(String id) async {
    try {
      final dynamic result = await _httpClient
          .post('${ApiEndpoints.baseUrl}/live-consultations/$id/end');

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Consultation ended successfully');
        } else {
          throw Exception(result['message'] ?? 'Unable to end consultation');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in endConsultation: $e");
      throw Exception('Failed to end consultation: $e');
    }
  }

  // ========== CHANGE CONSULTATION STATUS ==========
  Future<ConsultationModel> changeConsultationStatus(String id, String status) async {
    try {
      final dynamic result = await _httpClient.patch(
        '${ApiEndpoints.baseUrl}/live-consultations/$id/status',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Consultation status updated successfully');
          return ConsultationModel.fromJson(result['data']);
        } else {
          throw Exception(result['message'] ?? 'Failed to update consultation status');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in changeConsultationStatus: $e");
      throw Exception('Failed to update consultation status: $e');
    }
  }

  // ========== GET UPCOMING CONSULTATIONS ==========
  Future<List<ConsultationModel>> getUpcomingConsultations({int limit = 10}) async {
    try {
      final Uri uri = Uri.parse('${ApiEndpoints.baseUrl}/live-consultations/upcoming')
          .replace(queryParameters: {'limit': limit.toString()});
      final dynamic result = await _httpClient.get(uri.toString());

      if (result is Map<String, dynamic> && result['status'] == 200) {
        final List<dynamic> consultationsList = result['data'] ?? [];
        return consultationsList
            .map((json) => ConsultationModel.fromJson(json))
            .toList();
      } else {
        throw Exception(result['message'] ?? 'Failed to fetch upcoming consultations');
      }
    } catch (e) {
      Get.log("Error in getUpcomingConsultations: $e");
      throw Exception('Failed to fetch upcoming consultations: $e');
    }
  }

  // ========== GET TODAY'S CONSULTATIONS ==========
  Future<List<ConsultationModel>> getTodaysConsultations() async {
    try {
      final dynamic result = await _httpClient
          .get('${ApiEndpoints.baseUrl}/live-consultations/today');

      if (result is Map<String, dynamic> && result['status'] == 200) {
        final List<dynamic> consultationsList = result['data'] ?? [];
        return consultationsList
            .map((json) => ConsultationModel.fromJson(json))
            .toList();
      } else {
        throw Exception(result['message'] ?? 'Failed to fetch today\'s consultations');
      }
    } catch (e) {
      Get.log("Error in getTodaysConsultations: $e");
      throw Exception('Failed to fetch today\'s consultations: $e');
    }
  }

  // ========== GET CONSULTATION STATISTICS ==========
  Future<ConsultationStatistics> getConsultationStatistics({
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final Map<String, String> queryParams = {};
      if (dateFrom != null && dateFrom.isNotEmpty) queryParams['date_from'] = dateFrom;
      if (dateTo != null && dateTo.isNotEmpty) queryParams['date_to'] = dateTo;

      final Uri uri = Uri.parse('${ApiEndpoints.baseUrl}/live-consultations/statistics')
          .replace(queryParameters: queryParams);
      final dynamic result = await _httpClient.get(uri.toString());

      if (result is Map<String, dynamic> && result['status'] == 200) {
        return ConsultationStatistics.fromJson(result['data']);
      } else {
        throw Exception(result['message'] ?? 'Failed to fetch consultation statistics');
      }
    } catch (e) {
      Get.log("Error in getConsultationStatistics: $e");
      throw Exception('Failed to fetch consultation statistics: $e');
    }
  }
}