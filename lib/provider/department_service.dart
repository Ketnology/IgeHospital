import 'dart:convert';
import 'package:get/get.dart';
import 'package:ige_hospital/constants/api_endpoints.dart';
import 'package:ige_hospital/utils/http_client.dart';

class DepartmentModel {
  final String id;
  final String title;
  final String? description;
  final String status;
  final String createdAt;
  final String updatedAt;

  DepartmentModel({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'status': status,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class DepartmentService extends GetxService {
  final HttpClient _httpClient = HttpClient();

  final RxList<DepartmentModel> departments = <DepartmentModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Define the endpoint for departments APIs
  final String departmentsEndpoint = "${ApiEndpoints.baseUrl}/departments";

  @override
  void onInit() {
    super.onInit();
    fetchDepartments();
  }

  Future<DepartmentService> init() async {
    await fetchDepartments();
    return this;
  }

  Future<void> fetchDepartments() async {
    if (isLoading.value) return;

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final dynamic result = await _httpClient.get(departmentsEndpoint);

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          final List<dynamic> departmentsList = result['data']['departments'] ?? [];
          departments.value = departmentsList.map((json) => DepartmentModel.fromJson(json)).toList();
        } else {
          hasError.value = true;
          errorMessage.value = result['message'] ?? 'Failed to fetch departments';
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to connect to server: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to get department title from ID
  String getDepartmentTitle(String departmentId) {
    final department = departments.firstWhereOrNull((dept) => dept.id == departmentId);
    return department?.title ?? 'Unknown Department';
  }

  // // Utility method to get dropdown items for departments
  // List<DropdownMenuItem<String>> getDepartmentDropdownItems() {
  //   List<DropdownMenuItem<String>> items = [
  //     const DropdownMenuItem<String>(
  //       value: '',
  //       child: Text('All Departments'),
  //     )
  //   ];
  //
  //   // Add departments from the loaded list
  //   for (var department in departments) {
  //     if (department.status.toLowerCase() == 'active') {
  //       items.add(DropdownMenuItem<String>(
  //         value: department.id,
  //         child: Text(department.title),
  //       ));
  //     }
  //   }
  //
  //   return items;
  // }
}