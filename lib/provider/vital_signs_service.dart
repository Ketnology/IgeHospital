import 'dart:convert';
import 'package:get/get.dart';
import 'package:ige_hospital/constants/api_endpoints.dart';
import 'package:ige_hospital/models/vital_signs_model.dart';
import 'package:ige_hospital/utils/http_client.dart';
import 'package:ige_hospital/utils/snack_bar_utils.dart';

class VitalSignsService extends GetxService {
  final HttpClient _httpClient = HttpClient();

  // Get all vital signs for a specific patient (staff view)
  Future<Map<String, dynamic>> getPatientVitalSigns({
    required String patientId,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'per_page': perPage.toString(),
        'page': page.toString(),
      };

      final Uri uri = Uri.parse('${ApiEndpoints.baseUrl}/patients/$patientId/vital-signs/staff')
          .replace(queryParameters: queryParams);

      final dynamic result = await _httpClient.get(uri.toString());

      if (result is Map<String, dynamic> && result['status'] == 200) {
        final List<dynamic> vitalSignsList = result['data']['vital_signs'] ?? [];
        final List<VitalSignModel> vitalSigns = vitalSignsList
            .map((json) => VitalSignModel.fromJson(json))
            .toList();

        return {
          'vital_signs': vitalSigns,
          'total': result['data']['total'] ?? 0,
          'per_page': result['data']['per_page'] ?? perPage,
          'current_page': result['data']['current_page'] ?? page,
          'last_page': result['data']['last_page'] ?? 1,
        };
      } else {
        throw Exception(result['message'] ?? 'Failed to fetch vital signs');
      }
    } catch (e) {
      Get.log("Error in getPatientVitalSigns: $e");
      throw Exception('Failed to fetch vital signs: $e');
    }
  }

  // Create new vital signs
  Future<VitalSignModel> createVitalSigns(Map<String, dynamic> vitalSignsData) async {
    try {
      final dynamic result = await _httpClient.post(
        '${ApiEndpoints.baseUrl}/vital-signs',
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(vitalSignsData),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 201 || result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Vital signs recorded successfully');
          return VitalSignModel.fromJson(result['data']);
        } else {
          throw Exception(result['message'] ?? 'Failed to create vital signs');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in createVitalSigns: $e");
      throw Exception('Failed to create vital signs: $e');
    }
  }

  // Update vital signs
  Future<VitalSignModel> updateVitalSigns(
      String id, Map<String, dynamic> vitalSignsData) async {
    try {
      final dynamic result = await _httpClient.put(
        '${ApiEndpoints.baseUrl}/vital-signs/$id',
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(vitalSignsData),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Vital signs updated successfully');
          return VitalSignModel.fromJson(result['data']);
        } else {
          throw Exception(result['message'] ?? 'Failed to update vital signs');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in updateVitalSigns: $e");
      throw Exception('Failed to update vital signs: $e');
    }
  }

  // Delete vital signs
  Future<void> deleteVitalSigns(String id) async {
    try {
      final dynamic result = await _httpClient.delete(
        '${ApiEndpoints.baseUrl}/vital-signs/$id',
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Vital signs deleted successfully');
        } else {
          throw Exception(result['message'] ?? 'Failed to delete vital signs');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in deleteVitalSigns: $e");
      throw Exception('Failed to delete vital signs: $e');
    }
  }

  // Get vital signs by ID
  Future<VitalSignModel> getVitalSignsById(String id) async {
    try {
      final dynamic result = await _httpClient.get(
        '${ApiEndpoints.baseUrl}/vital-signs/$id',
      );

      if (result is Map<String, dynamic> && result['status'] == 200) {
        return VitalSignModel.fromJson(result['data']);
      } else {
        throw Exception(result['message'] ?? 'Failed to get vital signs details');
      }
    } catch (e) {
      Get.log("Error in getVitalSignsById: $e");
      throw Exception('Failed to get vital signs details: $e');
    }
  }
}