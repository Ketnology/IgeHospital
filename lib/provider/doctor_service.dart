import 'dart:convert';
import 'package:get/get.dart';
import 'package:ige_hospital/constants/api_endpoints.dart';
import 'package:ige_hospital/utils/http_client.dart';
import 'package:ige_hospital/utils/snack_bar_utils.dart';

class DoctorModel {
  final String id;
  final String userId;
  final String doctorDepartmentId;
  final String specialist;
  final String description;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic> user;
  final Map<String, dynamic> department;

  DoctorModel({
    required this.id,
    required this.userId,
    required this.doctorDepartmentId,
    required this.specialist,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.department,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      doctorDepartmentId: json['doctor_department_id'] ?? '',
      specialist: json['specialist'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      user: json['user'] ?? {},
      department: json['department'] ?? {},
    );
  }

  // Getters for convenience
  String get fullName => "${user['first_name'] ?? ''} ${user['last_name'] ?? ''}";
  String get email => user['email'] ?? '';
  String get phone => user['phone'] ?? '';
  String get gender => user['gender'] ?? '';
  String get bloodGroup => user['blood_group'] ?? '';
  String get qualification => user['qualification'] ?? '';
  String get status => user['status'] ?? '';
  String get profileImage => user['profile_image'] ?? '';
  String get departmentName => department['title'] ?? '';
}

class DoctorsService extends GetxService {
  final HttpClient _httpClient = HttpClient();

  // Reactive variables
  final RxList<DoctorModel> doctors = <DoctorModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Pagination
  final RxInt totalDoctors = 0.obs;
  final RxInt currentPage = 1.obs;
  final RxInt perPage = 20.obs;

  // Filters
  final RxString searchQuery = ''.obs;
  final RxString departmentId = ''.obs;
  final RxString specialist = ''.obs;
  final RxString sortBy = 'created_at'.obs;
  final RxString sortDirection = 'desc'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    if (isLoading.value) return;

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final Map<String, String> queryParams = {
        if (searchQuery.value.isNotEmpty) 'search': searchQuery.value,
        if (departmentId.value.isNotEmpty) 'department_id': departmentId.value,
        if (specialist.value.isNotEmpty) 'specialist': specialist.value,
        'sort_by': sortBy.value,
        'sort_direction': sortDirection.value,
        'page': currentPage.value.toString(),
        'per_page': perPage.value.toString(),
      };

      final Uri uri = Uri.parse(ApiEndpoints.doctors).replace(queryParameters: queryParams);

      final dynamic result = await _httpClient.get(uri.toString());

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          final List<dynamic> doctorsList = result['data']['doctors'] ?? [];
          doctors.value = doctorsList.map((json) => DoctorModel.fromJson(json)).toList();

          // Save pagination info
          totalDoctors.value = result['data']['total'] is int
              ? result['data']['total']
              : int.tryParse(result['data']['total'].toString()) ?? 0;

          perPage.value = result['data']['per_page'] is int
              ? result['data']['per_page']
              : int.tryParse(result['data']['per_page'].toString()) ?? 20;

          // If we're on a page that doesn't exist anymore, go back to page 1
          if (doctors.isEmpty && totalDoctors.value > 0 && currentPage.value > 1) {
            currentPage.value = 1;
            fetchDoctors();
          }
        } else {
          hasError.value = true;
          errorMessage.value = result['message'] ?? 'Failed to fetch doctors';
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to connect to server: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<DoctorModel?> getDoctorDetails(String id) async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final dynamic result = await _httpClient.get('${ApiEndpoints.doctorDetails}$id');

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          return DoctorModel.fromJson(result['data']);
        } else {
          hasError.value = true;
          errorMessage.value = result['message'] ?? 'Failed to get doctor details';
        }
      }
      return null;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to connect to server: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createDoctor(Map<String, dynamic> doctorData) async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final dynamic result = await _httpClient.post(
        ApiEndpoints.doctors,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(doctorData),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 201 || result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Doctor created successfully');
          fetchDoctors();
        } else {
          hasError.value = true;
          errorMessage.value = result['message'] ?? 'Failed to create doctor';
          SnackBarUtils.showErrorSnackBar(errorMessage.value);
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to connect to server: $e';
      SnackBarUtils.showErrorSnackBar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateDoctor(String id, Map<String, dynamic> doctorData) async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final dynamic result = await _httpClient.put(
        '${ApiEndpoints.doctorDetails}$id',
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(doctorData),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Doctor updated successfully');
          fetchDoctors();
        } else {
          hasError.value = true;
          errorMessage.value = result['message'] ?? 'Failed to update doctor';
          SnackBarUtils.showErrorSnackBar(errorMessage.value);
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to connect to server: $e';
      SnackBarUtils.showErrorSnackBar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteDoctor(String id) async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final dynamic result = await _httpClient.delete(
        '${ApiEndpoints.doctorDetails}$id',
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Doctor deleted successfully');
          fetchDoctors();
        } else {
          hasError.value = true;
          errorMessage.value = result['message'] ?? 'Failed to delete doctor';
          SnackBarUtils.showErrorSnackBar(errorMessage.value);
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to connect to server: $e';
      SnackBarUtils.showErrorSnackBar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  void resetFilters() {
    searchQuery.value = '';
    departmentId.value = '';
    specialist.value = '';
    sortBy.value = 'created_at';
    sortDirection.value = 'desc';
    currentPage.value = 1;
    fetchDoctors();
  }

  void setPage(int page) {
    if (page < 1) page = 1;
    int maxPage = (totalDoctors.value / perPage.value).ceil();
    if (page > maxPage) page = maxPage;
    currentPage.value = page;
    fetchDoctors();
  }

  void nextPage() {
    int maxPages = (totalDoctors.value / perPage.value).ceil();
    if (currentPage.value < maxPages) {
      currentPage.value++;
      fetchDoctors();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchDoctors();
    }
  }
}