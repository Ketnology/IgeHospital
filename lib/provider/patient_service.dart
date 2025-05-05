import 'dart:convert';
import 'package:get/get.dart';
import 'package:ige_hospital/constants/api_endpoints.dart';
import 'package:ige_hospital/models/patient_model.dart';
import 'package:ige_hospital/utils/http_client.dart';
import 'package:ige_hospital/utils/snack_bar_utils.dart';

class PatientService extends GetxService {
  final HttpClient _httpClient = HttpClient();

  Future<List<PatientModel>> getPatients(
      {String? search,
      String? gender,
      String? bloodGroup,
      String? dateFrom,
      String? dateTo,
      String sortBy = 'created_at',
      String sortDirection = 'desc',
      int page = 1,
      int perPage = 20}) async {
    try {
      final Map<String, String> queryParams = {
        if (search != null && search.isNotEmpty) 'search': search,
        if (gender != null && gender.isNotEmpty) 'gender': gender,
        if (bloodGroup != null && bloodGroup.isNotEmpty)
          'blood_group': bloodGroup,
        if (dateFrom != null && dateFrom.isNotEmpty) 'date_from': dateFrom,
        if (dateTo != null && dateTo.isNotEmpty) 'date_to': dateTo,
        'sort_by': sortBy,
        'sort_direction': sortDirection,
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final Uri uri = Uri.parse(ApiEndpoints.patientEndpoint)
          .replace(queryParameters: queryParams);
      final dynamic result = await _httpClient.get(uri.toString());

      if (result is Map<String, dynamic> && result['status'] == 200) {
        final List<dynamic> patientsList = result['data']['patients'] ?? [];
        final List<PatientModel> patients =
            patientsList.map((json) => PatientModel.fromJson(json)).toList();

        return patients;
      } else {
        throw Exception(result['message'] ?? 'Failed to fetch patients');
      }
    } catch (e) {
      Get.log("Error in getPatients: $e");
      throw Exception('Failed to fetch patients: $e');
    }
  }

  Future<Map<String, dynamic>> getPatientsWithPagination({
    String? search,
    String? gender,
    String? bloodGroup,
    String? dateFrom,
    String? dateTo,
    String sortBy = 'created_at',
    String sortDirection = 'desc',
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final Map<String, String> queryParams = {
        if (search != null && search.isNotEmpty) 'search': search,
        if (gender != null && gender.isNotEmpty) 'gender': gender,
        if (bloodGroup != null && bloodGroup.isNotEmpty)
          'blood_group': bloodGroup,
        if (dateFrom != null && dateFrom.isNotEmpty) 'date_from': dateFrom,
        if (dateTo != null && dateTo.isNotEmpty) 'date_to': dateTo,
        'sort_by': sortBy,
        'sort_direction': sortDirection,
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final Uri uri = Uri.parse(ApiEndpoints.patientEndpoint)
          .replace(queryParameters: queryParams);
      final dynamic result = await _httpClient.get(uri.toString());

      if (result is Map<String, dynamic> && result['status'] == 200) {
        final List<dynamic> patientsList = result['data']['patients'] ?? [];
        final List<PatientModel> patients =
            patientsList.map((json) => PatientModel.fromJson(json)).toList();

        final int total = result['data']['total'] is int
            ? result['data']['total']
            : int.tryParse(result['data']['total'].toString()) ??
                patientsList.length;

        final int currentPerPage = result['data']['per_page'] is int
            ? result['data']['per_page']
            : int.tryParse(result['data']['per_page'].toString()) ?? perPage;

        return {
          'patients': patients,
          'total': total,
          'page': page,
          'per_page': currentPerPage,
        };
      } else {
        throw Exception(result['message'] ?? 'Failed to fetch patients');
      }
    } catch (e) {
      Get.log("Error in getPatientsWithPagination: $e");
      throw Exception('Failed to fetch patients: $e');
    }
  }

  Future<PatientModel> getPatientDetails(String id) async {
    try {
      final dynamic result =
          await _httpClient.get('${ApiEndpoints.patientEndpoint}/$id');

      if (result is Map<String, dynamic> && result['status'] == 200) {
        return PatientModel.fromJson(result['data']);
      } else {
        throw Exception(result['message'] ?? 'Failed to get patient details');
      }
    } catch (e) {
      Get.log("Error in getPatientDetails: $e");
      throw Exception('Failed to get patient details: $e');
    }
  }

  Future<void> createPatient(Map<String, dynamic> patientData) async {
    try {
      final dynamic result = await _httpClient.post(
        ApiEndpoints.patientEndpoint,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(patientData),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 201 || result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Patient created successfully');
        } else {
          throw Exception(result['message'] ?? 'Failed to create patient');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in createPatient: $e");
      throw Exception('Failed to create patient: $e');
    }
  }

  Future<void> updatePatient(
      String id, Map<String, dynamic> patientData) async {
    try {
      final dynamic result = await _httpClient.put(
        '${ApiEndpoints.patientEndpoint}/$id',
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(patientData),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Patient updated successfully');
        } else {
          throw Exception(result['message'] ?? 'Failed to update patient');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in updatePatient: $e");
      throw Exception('Failed to update patient: $e');
    }
  }

  Future<void> deletePatient(String id) async {
    try {
      final dynamic result =
          await _httpClient.delete('${ApiEndpoints.patientEndpoint}/$id');

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Patient deleted successfully');
        } else {
          throw Exception(result['message'] ?? 'Failed to delete patient');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in deletePatient: $e");
      throw Exception('Failed to delete patient: $e');
    }
  }
}
