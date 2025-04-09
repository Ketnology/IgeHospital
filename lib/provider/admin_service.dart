import 'dart:convert';
import 'package:get/get.dart';
import 'package:ige_hospital/constants/api_endpoints.dart';
import 'package:ige_hospital/utils/http_client.dart';
import 'package:ige_hospital/utils/snack_bar_utils.dart';

class AdminModel {
  final String id;
  final String userId;
  final bool isDefault;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic> user;

  AdminModel({
    required this.id,
    required this.userId,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      isDefault: json['is_default'] == '1' || json['is_default'] == true,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      user: json['user'] ?? {},
    );
  }

  // Getters for convenience
  String get fullName => "${user['first_name'] ?? ''} ${user['last_name'] ?? ''}";
  String get email => user['email'] ?? '';
  String get phone => user['phone'] ?? '';
  String get gender => user['gender'] ?? '';
  String get qualification => user['qualification'] ?? '';
  String get status => user['status'] ?? '';
  String get profileImage => user['profile_image'] ?? '';
}

class AdminsService extends GetxService {
  final HttpClient _httpClient = HttpClient();

  // Reactive variables
  final RxList<AdminModel> admins = <AdminModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Pagination
  final RxInt totalAdmins = 0.obs;
  final RxInt currentPage = 1.obs;
  final RxInt perPage = 20.obs;

  // Filters
  final RxString searchQuery = ''.obs;
  final RxString sortBy = 'created_at'.obs;
  final RxString sortDirection = 'desc'.obs;

  // Define the endpoint for admins APIs
  final String adminsEndpoint = "${ApiEndpoints.baseUrl}/admins";

  @override
  void onInit() {
    super.onInit();
    fetchAdmins();
  }

  Future<void> fetchAdmins() async {
    if (isLoading.value) return;

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final Map<String, String> queryParams = {
        if (searchQuery.value.isNotEmpty) 'search': searchQuery.value,
        'sort_by': sortBy.value,
        'sort_direction': sortDirection.value,
        'page': currentPage.value.toString(),
        'per_page': perPage.value.toString(),
      };

      final Uri uri = Uri.parse(adminsEndpoint).replace(queryParameters: queryParams);

      final dynamic result = await _httpClient.get(uri.toString());

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          final List<dynamic> adminsList = result['data']['admins'] ?? [];
          admins.value = adminsList.map((json) => AdminModel.fromJson(json)).toList();

          // Save pagination info
          totalAdmins.value = result['data']['total'] is int
              ? result['data']['total']
              : int.tryParse(result['data']['total'].toString()) ?? 0;

          perPage.value = result['data']['per_page'] is int
              ? result['data']['per_page']
              : int.tryParse(result['data']['per_page'].toString()) ?? 20;

          // If we're on a page that doesn't exist anymore, go back to page 1
          if (admins.isEmpty && totalAdmins.value > 0 && currentPage.value > 1) {
            currentPage.value = 1;
            fetchAdmins();
          }
        } else {
          hasError.value = true;
          errorMessage.value = result['message'] ?? 'Failed to fetch admins';
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to connect to server: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<AdminModel?> getAdminDetails(String id) async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final dynamic result = await _httpClient.get('$adminsEndpoint/$id');

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          return AdminModel.fromJson(result['data']);
        } else {
          hasError.value = true;
          errorMessage.value = result['message'] ?? 'Failed to get admin details';
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

  Future<void> createAdmin(Map<String, dynamic> adminData) async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final dynamic result = await _httpClient.post(
        adminsEndpoint,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(adminData),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 201 || result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Admin created successfully');
          fetchAdmins();
        } else {
          hasError.value = true;
          errorMessage.value = result['message'] ?? 'Failed to create admin';
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

  Future<void> updateAdmin(String id, Map<String, dynamic> adminData) async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final dynamic result = await _httpClient.put(
        '$adminsEndpoint/$id',
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(adminData),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Admin updated successfully');
          fetchAdmins();
        } else {
          hasError.value = true;
          errorMessage.value = result['message'] ?? 'Failed to update admin';
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

  Future<void> deleteAdmin(String id) async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final dynamic result = await _httpClient.delete('$adminsEndpoint/$id');

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Admin deleted successfully');
          fetchAdmins();
        } else {
          hasError.value = true;
          errorMessage.value = result['message'] ?? 'Failed to delete admin';
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
    sortBy.value = 'created_at';
    sortDirection.value = 'desc';
    currentPage.value = 1;
    fetchAdmins();
  }

  void setPage(int page) {
    if (page < 1) page = 1;
    int maxPage = (totalAdmins.value / perPage.value).ceil();
    if (page > maxPage) page = maxPage;
    currentPage.value = page;
    fetchAdmins();
  }

  void nextPage() {
    int maxPages = (totalAdmins.value / perPage.value).ceil();
    if (currentPage.value < maxPages) {
      currentPage.value++;
      fetchAdmins();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchAdmins();
    }
  }
}