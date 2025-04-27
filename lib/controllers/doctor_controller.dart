import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ige_hospital/constants/api_endpoints.dart';
import 'package:ige_hospital/provider/department_service.dart';
import 'package:ige_hospital/utils/http_client.dart';
import 'package:ige_hospital/utils/snack_bar_utils.dart';

class Doctor {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String gender;
  final String department;
  final String departmentId;
  final String specialty;
  final String status;
  final String profileImage;
  final String qualification;
  final String description;
  final String bloodGroup;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic> user;
  final Map<String, dynamic> departmentData;
  final List<dynamic> appointments;
  final List<dynamic> schedules;
  final Map<String, dynamic> stats;

  Doctor({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.department,
    required this.departmentId,
    required this.specialty,
    required this.status,
    required this.profileImage,
    required this.qualification,
    required this.description,
    required this.bloodGroup,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.departmentData,
    required this.appointments,
    required this.schedules,
    required this.stats,
  });

  String get fullName => "$firstName $lastName";

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    final department = json['department'] ?? {};

    return Doctor(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      firstName: user['first_name'] ?? '',
      lastName: user['last_name'] ?? '',
      email: user['email'] ?? '',
      phone: user['phone'] ?? '',
      gender: user['gender'] ?? '',
      department: department['title'] ?? '',
      departmentId: json['department_id'] ?? '',
      specialty: json['specialist'] ?? '',
      status: user['status'] ?? 'active',
      profileImage: user['profile_image'] ?? '',
      qualification: user['qualification'] ?? '',
      description: json['description'] ?? '',
      bloodGroup: user['blood_group'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      user: user,
      departmentData: department,
      appointments: json['appointments'] ?? [],
      schedules: json['schedules'] ?? [],
      stats: json['stats'] ?? {'appointments_count': 0, 'schedules_count': 0},
    );
  }
}

class DoctorController extends GetxService {
  final HttpClient _httpClient = HttpClient();
  DepartmentService? _departmentService;
  bool _departmentServiceInitialized = false;

  // Reactive variables
  var isLoading = false.obs;
  var doctors = <Doctor>[].obs;
  var filteredDoctors = <Doctor>[].obs;

  // Pagination
  final RxInt totalDoctors = 0.obs;
  final RxInt currentPage = 1.obs;
  final RxInt perPage = 20.obs;

  // Filter variables
  var searchQuery = ''.obs;
  var selectedDepartment = ''.obs;
  var selectedSpecialty = ''.obs;
  var selectedStatus = ''.obs;
  var sortBy = 'created_at'.obs;
  var sortDirection = 'desc'.obs;

  // Department list for filter dropdown
  var departments = <String>['All Departments'].obs;

  // Specialties set from actual doctor data
  var specialties = <String>['All Specialties'].obs;

  @override
  void onInit() {
    super.onInit();
    _initDepartmentService();
    loadDoctors();

    // Initialize filter listeners
    ever(searchQuery, (_) => applyFilters());
    ever(selectedDepartment, (_) => applyFilters());
    ever(selectedSpecialty, (_) => applyFilters());
    ever(selectedStatus, (_) => applyFilters());
    ever(sortDirection, (_) => applyFilters());
  }

  void _initDepartmentService() {
    try {
      _departmentService = Get.find<DepartmentService>();
      _departmentServiceInitialized = true;
      // Update department list after finding the service
      _updateDepartmentList();
    } catch (e) {
      // Service not found, it will be initialized later
      _departmentServiceInitialized = false;
      Get.log("DepartmentService not found, will try again later: $e");
    }
  }

  void _updateDepartmentList() {
    if (_departmentServiceInitialized && _departmentService != null) {
      // Start with 'All Departments'
      List<String> deptList = ['All Departments'];

      // Add departments from the service
      for (var dept in _departmentService!.departments) {
        if (dept.status.toLowerCase() == 'active') {
          deptList.add(dept.title);
        }
      }

      // Update the observable list
      departments.value = deptList;
    }
  }

  Future<void> loadDoctors() async {
    isLoading.value = true;

    try {
      final Map<String, String> queryParams = {
        if (searchQuery.value.isNotEmpty) 'search': searchQuery.value,
        if (selectedDepartment.value.isNotEmpty &&
            selectedDepartment.value != 'All Departments')
          'department_id': _getDepartmentId(selectedDepartment.value),
        if (selectedSpecialty.value.isNotEmpty &&
            selectedSpecialty.value != 'All Specialties')
          'specialist': selectedSpecialty.value,
        'sort_by': sortBy.value,
        'sort_direction': sortDirection.value,
        'page': currentPage.value.toString(),
        'per_page': perPage.value.toString(),
      };

      final Uri uri = Uri.parse(ApiEndpoints.doctorEndpoint)
          .replace(queryParameters: queryParams);

      final dynamic result = await _httpClient.get(uri.toString());

      if (result is Map<String, dynamic> && result['status'] == 200) {
        final List<dynamic> doctorsList = result['data']['doctors'] ?? [];
        doctors.value =
            doctorsList.map((json) => Doctor.fromJson(json)).toList();

        // Extract unique specialties from doctors
        Set<String> specialtySet = {'All Specialties'};
        for (var doctor in doctors) {
          if (doctor.specialty.isNotEmpty) {
            specialtySet.add(doctor.specialty);
          }
        }
        specialties.value = specialtySet.toList();

        // Save pagination info
        totalDoctors.value = result['data']['total'] is int
            ? result['data']['total']
            : int.tryParse(result['data']['total'].toString()) ?? 0;

        // Apply filters to update filteredDoctors
        applyFilters();
      } else {
        SnackBarUtils.showErrorSnackBar(
            result['message'] ?? 'Failed to load doctors');
      }
    } catch (e) {
      Get.log("Error loading doctors: $e");
      SnackBarUtils.showErrorSnackBar('Failed to load doctors: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String _getDepartmentId(String departmentName) {
    if (_departmentServiceInitialized && _departmentService != null) {
      var dept = _departmentService!.departments
          .firstWhereOrNull((dept) => dept.title == departmentName);
      return dept?.id ?? '';
    }
    return '';
  }

  void applyFilters() {
    filteredDoctors.value = doctors.where((doctor) {
      // Search by name, email, or specialty
      bool matchesSearch = true;
      if (searchQuery.value.isNotEmpty) {
        matchesSearch = doctor.fullName
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()) ||
            doctor.email
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()) ||
            doctor.specialty
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase());
      }

      // Filter by department
      bool matchesDepartment = true;
      if (selectedDepartment.value.isNotEmpty &&
          selectedDepartment.value != 'All Departments') {
        matchesDepartment = doctor.department == selectedDepartment.value;
      }

      // Filter by specialty
      bool matchesSpecialty = true;
      if (selectedSpecialty.value.isNotEmpty &&
          selectedSpecialty.value != 'All Specialties') {
        matchesSpecialty = doctor.specialty == selectedSpecialty.value;
      }

      // Filter by status
      bool matchesStatus = true;
      if (selectedStatus.value.isNotEmpty && selectedStatus.value != 'All') {
        matchesStatus =
            doctor.status.toLowerCase() == selectedStatus.value.toLowerCase();
      }

      return matchesSearch &&
          matchesDepartment &&
          matchesSpecialty &&
          matchesStatus;
    }).toList();

    // Sort the list
    if (sortDirection.value == 'asc') {
      filteredDoctors.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else {
      filteredDoctors.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  void resetFilters() {
    searchQuery.value = '';
    selectedDepartment.value = '';
    selectedSpecialty.value = '';
    selectedStatus.value = '';
    sortDirection.value = 'desc';

    // Reset pagination to first page
    currentPage.value = 1;

    // Reload doctors from API with reset filters
    loadDoctors();
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'blocked':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Future<void> addDoctor(Map<String, dynamic> doctorData) async {
    isLoading.value = true;

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
          loadDoctors();
        } else {
          SnackBarUtils.showErrorSnackBar(
              result['message'] ?? 'Failed to create doctor');
        }
      }
    } catch (e) {
      SnackBarUtils.showErrorSnackBar('Failed to connect to server: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateDoctor(String id, Map<String, dynamic> doctorData) async {
    isLoading.value = true;

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
          loadDoctors();
        } else {
          SnackBarUtils.showErrorSnackBar(
              result['message'] ?? 'Failed to update doctor');
        }
      }
    } catch (e) {
      SnackBarUtils.showErrorSnackBar('Failed to connect to server: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteDoctor(String id) async {
    isLoading.value = true;

    try {
      final dynamic result = await _httpClient.delete(
        '${ApiEndpoints.doctorEndpoint}/$id',
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Doctor deleted successfully');
          loadDoctors();
        } else {
          SnackBarUtils.showErrorSnackBar(
              result['message'] ?? 'Failed to delete doctor');
        }
      }
    } catch (e) {
      SnackBarUtils.showErrorSnackBar('Failed to connect to server: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
