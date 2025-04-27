import 'dart:convert';
import 'package:get/get.dart';
import 'package:ige_hospital/constants/api_endpoints.dart';
import 'package:ige_hospital/controllers/doctor_controller.dart';
import 'package:ige_hospital/utils/http_client.dart';
import 'package:ige_hospital/utils/snack_bar_utils.dart';

class DoctorService extends GetxService {
  final HttpClient _httpClient = HttpClient();

  // API Methods
  Future<List<Doctor>> getDoctors({
    String? search,
    String? departmentId,
    String? specialty,
    String? status,
    String sortBy = 'created_at',
    String sortDirection = 'desc',
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final Map<String, String> queryParams = {
        if (search != null && search.isNotEmpty) 'search': search,
        if (departmentId != null && departmentId.isNotEmpty)
          'department_id': departmentId,
        if (specialty != null && specialty.isNotEmpty) 'specialist': specialty,
        if (status != null && status.isNotEmpty) 'status': status,
        'sort_by': sortBy,
        'sort_direction': sortDirection,
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final Uri uri = Uri.parse(ApiEndpoints.doctorEndpoint)
          .replace(queryParameters: queryParams);
      final dynamic result = await _httpClient.get(uri.toString());

      if (result is Map<String, dynamic> && result['status'] == 200) {
        final List<dynamic> doctorsList = result['data']['doctors'] ?? [];
        final List<Doctor> doctors =
            doctorsList.map((json) => Doctor.fromJson(json)).toList();

        return doctors;
      } else {
        throw Exception(result['message'] ?? 'Failed to fetch doctors');
      }
    } catch (e) {
      Get.log("Error in getDoctors: $e");
      throw Exception('Failed to fetch doctors: $e');
    }
  }

  Future<Map<String, dynamic>> getDoctorsWithPagination({
    String? search,
    String? departmentId,
    String? specialty,
    String? status,
    String sortBy = 'created_at',
    String sortDirection = 'desc',
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final Map<String, String> queryParams = {
        if (search != null && search.isNotEmpty) 'search': search,
        if (departmentId != null && departmentId.isNotEmpty)
          'department_id': departmentId,
        if (specialty != null && specialty.isNotEmpty) 'specialist': specialty,
        if (status != null && status.isNotEmpty) 'status': status,
        'sort_by': sortBy,
        'sort_direction': sortDirection,
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final Uri uri = Uri.parse(ApiEndpoints.doctorEndpoint)
          .replace(queryParameters: queryParams);
      final dynamic result = await _httpClient.get(uri.toString());

      if (result is Map<String, dynamic> && result['status'] == 200) {
        final List<dynamic> doctorsList = result['data']['doctors'] ?? [];
        final List<Doctor> doctors =
            doctorsList.map((json) => Doctor.fromJson(json)).toList();

        final int total = result['data']['total'] is int
            ? result['data']['total']
            : int.tryParse(result['data']['total'].toString()) ??
                doctorsList.length;

        final int currentPerPage = result['data']['per_page'] is int
            ? result['data']['per_page']
            : int.tryParse(result['data']['per_page'].toString()) ?? perPage;

        return {
          'doctors': doctors,
          'total': total,
          'page': page,
          'per_page': currentPerPage,
        };
      } else {
        throw Exception(result['message'] ?? 'Failed to fetch doctors');
      }
    } catch (e) {
      Get.log("Error in getDoctorsWithPagination: $e");
      throw Exception('Failed to fetch doctors: $e');
    }
  }

  Future<Doctor> getDoctorDetails(String id) async {
    try {
      final dynamic result =
          await _httpClient.get('${ApiEndpoints.doctorEndpoint}/$id');

      if (result is Map<String, dynamic> && result['status'] == 200) {
        return Doctor.fromJson(result['data']);
      } else {
        throw Exception(result['message'] ?? 'Failed to get doctor details');
      }
    } catch (e) {
      Get.log("Error in getDoctorDetails: $e");
      throw Exception('Failed to get doctor details: $e');
    }
  }

  Future<void> createDoctor(Map<String, dynamic> doctorData) async {
    try {
      final dynamic result = await _httpClient.post(
        ApiEndpoints.doctorEndpoint,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(doctorData),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 201 || result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Doctor created successfully');
        } else {
          throw Exception(result['message'] ?? 'Failed to create doctor');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in createDoctor: $e");
      throw Exception('Failed to create doctor: $e');
    }
  }

  Future<void> updateDoctor(String id, Map<String, dynamic> doctorData) async {
    try {
      final dynamic result = await _httpClient.put(
        '${ApiEndpoints.doctorEndpoint}/$id',
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(doctorData),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Doctor updated successfully');
        } else {
          throw Exception(result['message'] ?? 'Failed to update doctor');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in updateDoctor: $e");
      throw Exception('Failed to update doctor: $e');
    }
  }

  Future<void> deleteDoctor(String id) async {
    try {
      final dynamic result =
          await _httpClient.delete('${ApiEndpoints.doctorEndpoint}/$id');

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Doctor deleted successfully');
        } else {
          throw Exception(result['message'] ?? 'Failed to delete doctor');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in deleteDoctor: $e");
      throw Exception('Failed to delete doctor: $e');
    }
  }
}
