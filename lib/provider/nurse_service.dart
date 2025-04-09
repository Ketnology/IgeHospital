import 'dart:convert';
import 'package:get/get.dart';
import 'package:ige_hospital/constants/api_endpoints.dart';
import 'package:ige_hospital/utils/http_client.dart';
import 'package:ige_hospital/utils/snack_bar_utils.dart';

class NurseModel {
  final String id;
  final String userId;
  final String departmentId;
  final String? specialty;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic> user;
  final Map<String, dynamic>? department;

  NurseModel({
    required this.id,
    required this.userId,
    required this.departmentId,
    this.specialty,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    this.department,
  });

  factory NurseModel.fromJson(Map<String, dynamic> json) {
    return NurseModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      departmentId: json['department_id'] ?? '',
      specialty: json['specialty'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      user: json['user'] ?? {},
      department: json['department'],
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
  String get departmentName => department?['title'] ?? '';
}

class NursesService extends GetxService {
  final HttpClient _httpClient = HttpClient();

  // Reactive variables
  final RxList<NurseModel> nurses = <NurseModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Pagination
  final RxInt totalNurses = 0.obs;
  final RxInt currentPage = 1.obs;
  final RxInt perPage = 20.obs;

  // Filters
  final RxString searchQuery = ''.obs;
  final RxString departmentId = ''.obs;
  final RxString specialty = ''.obs;
  final RxString sortBy = 'created_at'.obs;
  final RxString sortDirection = 'desc'.obs;

  // Define the endpoint for nurses APIs
  final String nursesEndpoint = "${ApiEndpoints.baseUrl}/nurses";

  @override
  void onInit() {
    super.onInit();
    fetchNurses();
  }

  Future<void> fetchNurses() async {
    if (isLoading.value) return;

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final Map<String, String> queryParams = {
        if (searchQuery.value.isNotEmpty) 'search': searchQuery.value,
        if (departmentId.value.isNotEmpty) 'department_id': departmentId.value,
        if (specialty.value.isNotEmpty) 'specialty': specialty.value,
        'sort_by': sortBy.value,
        'sort_direction': sortDirection.value,
        'page': currentPage.value.toString(),
        'per_page': perPage.value.toString(),
      };

      final Uri uri = Uri.parse(nursesEndpoint).replace(queryParameters: queryParams);

      final dynamic result = await _httpClient.get(uri.toString());

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          final List<dynamic> nursesList = result['data']['nurses'] ?? [];
          nurses.value = nursesList.map((json) => NurseModel.fromJson(json)).toList();

          // Save pagination info
          totalNurses.value = result['data']['total'] is int
              ? result['data']['total']
              : int.tryParse(result['data']['total'].toString()) ?? 0;

          perPage.value = result['data']['per_page'] is int
              ? result['data']['per_page']
              : int.tryParse(result['data']['per_page'].toString()) ?? 20;

          // If we're on a page that doesn't exist anymore, go back to page 1
          if (nurses.isEmpty && totalNurses.value > 0 && currentPage.value > 1) {
            currentPage.value = 1;
            fetchNurses();
          }
        } else {
          hasError.value = true;
          errorMessage.value = result['message'] ?? 'Failed to fetch nurses';
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to connect to server: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<NurseModel?> getNurseDetails(String id) async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final dynamic result = await _httpClient.get('$nursesEndpoint/$id');

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          return NurseModel.fromJson(result['data']);
        } else {
          hasError.value = true;
          errorMessage.value = result['message'] ?? 'Failed to get nurse details';
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

  Future<void> createNurse(Map<String, dynamic> nurseData) async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final dynamic result = await _httpClient.post(
        nursesEndpoint,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(nurseData),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 201 || result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Nurse created successfully');
          fetchNurses();
        } else {
          hasError.value = true;
          errorMessage.value = result['message'] ?? 'Failed to create nurse';
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

  Future<void> updateNurse(String id, Map<String, dynamic> nurseData) async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final dynamic result = await _httpClient.put(
        '$nursesEndpoint/$id',
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(nurseData),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Nurse updated successfully');
          fetchNurses();
        } else {
          hasError.value = true;
          errorMessage.value = result['message'] ?? 'Failed to update nurse';
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

  Future<void> deleteNurse(String id) async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final dynamic result = await _httpClient.delete('$nursesEndpoint/$id');

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Nurse deleted successfully');
          fetchNurses();
        } else {
          hasError.value = true;
          errorMessage.value = result['message'] ?? 'Failed to delete nurse';
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
    specialty.value = '';
    sortBy.value = 'created_at';
    sortDirection.value = 'desc';
    currentPage.value = 1;
    fetchNurses();
  }

  void setPage(int page) {
    if (page < 1) page = 1;
    int maxPage = (totalNurses.value / perPage.value).ceil();
    if (page > maxPage) page = maxPage;
    currentPage.value = page;
    fetchNurses();
  }

  void nextPage() {
    int maxPages = (totalNurses.value / perPage.value).ceil();
    if (currentPage.value < maxPages) {
      currentPage.value++;
      fetchNurses();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchNurses();
    }
  }
}