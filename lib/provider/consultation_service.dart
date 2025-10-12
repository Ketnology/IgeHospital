import 'dart:convert';
import 'package:get/get.dart';
import 'package:ige_hospital/constants/api_endpoints.dart';
import 'package:ige_hospital/models/consultation_model.dart';
import 'package:ige_hospital/utils/http_client.dart';
import 'package:ige_hospital/utils/snack_bar_utils.dart';

class ConsultationService extends GetxService {
  final HttpClient _httpClient = HttpClient();

  // Get all consultations with filters
  Future<Map<String, dynamic>> getConsultations({
    String? doctorId,
    String? patientId,
    String? status,
    String? dateFrom,
    String? dateTo,
    String? search,
    String sortBy = 'consultation_date',
    String sortDirection = 'desc',
    int page = 1,
    int perPage = 15,
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
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final Uri uri = Uri.parse(ApiEndpoints.liveConsultationsEndpoint).replace(queryParameters: queryParams);
      final dynamic result = await _httpClient.get(uri.toString());

      if (result is Map<String, dynamic> && result['status'] == 200) {
        final List<dynamic> consultationsList = result['data']['consultations'] ?? [];
        final List<LiveConsultation> consultations = consultationsList
            .map((json) => LiveConsultation.fromJson(json))
            .toList();

        return {
          'consultations': consultations,
          'total': result['data']['total'] ?? 0,
          'per_page': result['data']['per_page'] ?? perPage,
          'current_page': result['data']['current_page'] ?? page,
          'last_page': result['data']['last_page'] ?? 1,
        };
      } else {
        throw Exception(result['message'] ?? 'Failed to fetch consultations');
      }
    } catch (e) {
      Get.log("Error in getConsultations: $e");
      throw Exception('Failed to fetch consultations: $e');
    }
  }

  // Get consultation by ID
  Future<LiveConsultation> getConsultationById(String id) async {
    try {
      final dynamic result = await _httpClient.get('${ApiEndpoints.liveConsultationsEndpoint}/$id');

      if (result is Map<String, dynamic> && result['status'] == 200) {
        return LiveConsultation.fromJson(result['data']);
      } else {
        throw Exception(result['message'] ?? 'Failed to get consultation details');
      }
    } catch (e) {
      Get.log("Error in getConsultationById: $e");
      throw Exception('Failed to get consultation details: $e');
    }
  }

  // Create new consultation
  Future<LiveConsultation> createConsultation(Map<String, dynamic> consultationData) async {
    try {
      final dynamic result = await _httpClient.post(
        ApiEndpoints.liveConsultationsEndpoint,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(consultationData),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 201 || result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Consultation created successfully');
          return LiveConsultation.fromJson(result['data']);
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

  // Update consultation
  Future<LiveConsultation> updateConsultation(String id, Map<String, dynamic> consultationData) async {
    try {
      final dynamic result = await _httpClient.put(
        '${ApiEndpoints.liveConsultationsEndpoint}/$id',
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(consultationData),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Consultation updated successfully');
          return LiveConsultation.fromJson(result['data']);
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

  // Delete consultation
  Future<void> deleteConsultation(String id) async {
    try {
      final dynamic result = await _httpClient.delete('${ApiEndpoints.liveConsultationsEndpoint}/$id');

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

  // Join consultation
  Future<void> joinConsultation(String id) async {
    try {
      final dynamic result = await _httpClient.post('${ApiEndpoints.liveConsultationsEndpoint}/$id/join');

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Joined consultation successfully');
        } else {
          throw Exception(result['message'] ?? 'Failed to join consultation');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in joinConsultation: $e");
      throw Exception('Failed to join consultation: $e');
    }
  }

  // Start consultation (doctor only)
  Future<void> startConsultation(String id) async {
    try {
      final dynamic result = await _httpClient.post('${ApiEndpoints.liveConsultationsEndpoint}/$id/start');

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Consultation started successfully');
        } else {
          throw Exception(result['message'] ?? 'Failed to start consultation');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in startConsultation: $e");
      throw Exception('Failed to start consultation: $e');
    }
  }

  // End consultation (doctor only)
  Future<void> endConsultation(String id) async {
    try {
      final dynamic result = await _httpClient.post('${ApiEndpoints.liveConsultationsEndpoint}/$id/end');

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Consultation ended successfully');
        } else {
          throw Exception(result['message'] ?? 'Failed to end consultation');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in endConsultation: $e");
      throw Exception('Failed to end consultation: $e');
    }
  }

  // Change consultation status
  Future<LiveConsultation> changeConsultationStatus(String id, String status) async {
    try {
      final dynamic result = await _httpClient.patch(
        '${ApiEndpoints.liveConsultationsEndpoint}/$id/status',
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': status}),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Consultation status updated successfully');
          return LiveConsultation.fromJson(result['data']);
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

  // Get upcoming consultations
  Future<List<LiveConsultation>> getUpcomingConsultations({int limit = 10}) async {
    try {
      final Uri uri = Uri.parse(ApiEndpoints.upcomingConsultationsEndpoint).replace(
        queryParameters: {'limit': limit.toString()},
      );
      final dynamic result = await _httpClient.get(uri.toString());

      if (result is Map<String, dynamic> && result['status'] == 200) {
        // Updated to handle the new response structure where data is directly an array
        final List<dynamic> consultationsList = result['data'] ?? [];
        return consultationsList
            .map((json) => LiveConsultation.fromJson(json))
            .toList();
      } else {
        throw Exception(result['message'] ?? 'Failed to fetch upcoming consultations');
      }
    } catch (e) {
      Get.log("Error in getUpcomingConsultations: $e");
      throw Exception('Failed to fetch upcoming consultations: $e');
    }
  }

  // Get today's consultations
  Future<List<LiveConsultation>> getTodaysConsultations() async {
    try {
      final dynamic result = await _httpClient.get(ApiEndpoints.todaysConsultationsEndpoint);

      if (result is Map<String, dynamic> && result['status'] == 200) {
        // Updated to handle the new response structure where data is directly an array
        final List<dynamic> consultationsList = result['data'] ?? [];
        return consultationsList
            .map((json) => LiveConsultation.fromJson(json))
            .toList();
      } else {
        throw Exception(result['message'] ?? 'Failed to fetch today\'s consultations');
      }
    } catch (e) {
      Get.log("Error in getTodaysConsultations: $e");
      throw Exception('Failed to fetch today\'s consultations: $e');
    }
  }

  // Get consultation statistics
  Future<ConsultationStatistics> getConsultationStatistics({
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final Map<String, String> queryParams = {};
      if (dateFrom != null && dateFrom.isNotEmpty) queryParams['date_from'] = dateFrom;
      if (dateTo != null && dateTo.isNotEmpty) queryParams['date_to'] = dateTo;

      final Uri uri = Uri.parse(ApiEndpoints.consultationStatisticsEndpoint).replace(queryParameters: queryParams);
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