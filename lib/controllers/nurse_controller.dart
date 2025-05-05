import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ige_hospital/constants/api_endpoints.dart';
import 'package:ige_hospital/provider/department_service.dart';
import 'package:ige_hospital/utils/http_client.dart';
import 'package:ige_hospital/utils/snack_bar_utils.dart';

class Nurse {
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
  final String bloodGroup;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic> user;
  final Map<String, dynamic> departmentData;
  final List<dynamic> appointments;
  final Map<String, dynamic> stats;

  Nurse({
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
    required this.bloodGroup,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.departmentData,
    required this.appointments,
    required this.stats,
  });

  String get fullName => "$firstName $lastName";

  factory Nurse.fromJson(Map<String, dynamic> json) {
    // Safely convert user and department to Map<String, dynamic>
    final user = json['user'] != null
        ? Map<String, dynamic>.from(json['user'])
        : <String, dynamic>{};

    final department = json['department'] != null
        ? Map<String, dynamic>.from(json['department'])
        : <String, dynamic>{};

    // Safely handle stats
    final stats = json['stats'] != null
        ? Map<String, dynamic>.from(json['stats'])
        : <String, dynamic>{'appointments_count': 0};

    return Nurse(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      firstName: user['first_name']?.toString() ?? '',
      lastName: user['last_name']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      phone: user['phone']?.toString() ?? '',
      gender: user['gender']?.toString() ?? '',
      department: department['title']?.toString() ?? '',
      departmentId: json['department_id']?.toString() ?? '',
      specialty: json['specialty']?.toString() ?? '',
      status: user['status']?.toString() ?? 'active',
      profileImage: user['profile_image']?.toString() ?? '',
      qualification: user['qualification']?.toString() ?? '',
      bloodGroup: user['blood_group']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      user: user,
      departmentData: department,
      appointments: json['appointments'] ?? [],
      stats: stats,
    );
  }
}

class NurseController extends GetxService {
  final HttpClient _httpClient = HttpClient();
  DepartmentService? _departmentService;
  bool _departmentServiceInitialized = false;

  // Reactive variables
  var isLoading = false.obs;
  var nurses = <Nurse>[].obs;
  var filteredNurses = <Nurse>[].obs;

  // Pagination
  final RxInt totalNurses = 0.obs;
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

  // Specialties set from actual nurse data
  var specialties = <String>['All Specialties'].obs;

  @override
  void onInit() {
    super.onInit();
    _initDepartmentService();
    loadNurses();

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

  Future<void> loadNurses() async {
    isLoading.value = true;

    try {
      final Map<String, String> queryParams = {
        if (searchQuery.value.isNotEmpty) 'search': searchQuery.value,
        if (selectedDepartment.value.isNotEmpty &&
            selectedDepartment.value != 'All Departments')
          'department_id': _getDepartmentId(selectedDepartment.value),
        if (selectedSpecialty.value.isNotEmpty &&
            selectedSpecialty.value != 'All Specialties')
          'specialty': selectedSpecialty.value,
        if (selectedStatus.value.isNotEmpty && selectedStatus.value != 'All')
          'status': selectedStatus.value,
        'sort_by': sortBy.value,
        'sort_direction': sortDirection.value,
        'page': currentPage.value.toString(),
        'per_page': perPage.value.toString(),
      };

      final Uri uri = Uri.parse(ApiEndpoints.nursesEndpoint)
          .replace(queryParameters: queryParams);

      final dynamic result = await _httpClient.get(uri.toString());

      if (result is Map<String, dynamic> && result['status'] == 200) {
        final List<dynamic> nursesList = result['data']['receptionists'] ?? [];
        nurses.value = nursesList
            .map((json) => Nurse.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        // Extract unique specialties from nurses
        Set<String> specialtySet = {'All Specialties'};
        for (var nurse in nurses) {
          if (nurse.specialty.isNotEmpty) {
            specialtySet.add(nurse.specialty);
          }
        }
        specialties.value = specialtySet.toList();

        // Save pagination info
        totalNurses.value = result['data']['total'] is int
            ? result['data']['total']
            : int.tryParse(result['data']['total'].toString()) ?? 0;

        // Apply filters to update filteredNurses
        applyFilters();
      } else {
        SnackBarUtils.showErrorSnackBar(
            result['message'] ?? 'Failed to load nurses');
      }
    } catch (e) {
      Get.log("Error loading nurses: $e");
      SnackBarUtils.showErrorSnackBar('Failed to load nurses: $e');
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
    filteredNurses.value = nurses.where((nurse) {
      // Search by name, email, or specialty
      bool matchesSearch = true;
      if (searchQuery.value.isNotEmpty) {
        matchesSearch = nurse.fullName
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()) ||
            nurse.email
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()) ||
            nurse.specialty
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase());
      }

      // Filter by department
      bool matchesDepartment = true;
      if (selectedDepartment.value.isNotEmpty &&
          selectedDepartment.value != 'All Departments') {
        matchesDepartment = nurse.department == selectedDepartment.value;
      }

      // Filter by specialty
      bool matchesSpecialty = true;
      if (selectedSpecialty.value.isNotEmpty &&
          selectedSpecialty.value != 'All Specialties') {
        matchesSpecialty = nurse.specialty == selectedSpecialty.value;
      }

      // Filter by status
      bool matchesStatus = true;
      if (selectedStatus.value.isNotEmpty && selectedStatus.value != 'All') {
        matchesStatus =
            nurse.status.toLowerCase() == selectedStatus.value.toLowerCase();
      }

      return matchesSearch &&
          matchesDepartment &&
          matchesSpecialty &&
          matchesStatus;
    }).toList();

    // Sort the list
    if (sortDirection.value == 'asc') {
      filteredNurses.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else {
      filteredNurses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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

    // Reload nurses from API with reset filters
    loadNurses();
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

  Future<void> addNurse(Map<String, dynamic> nurseData) async {
    isLoading.value = true;

    try {
      final dynamic result = await _httpClient.post(
        ApiEndpoints.nursesEndpoint,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(nurseData),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 201 || result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Nurse created successfully');
          loadNurses();
        } else {
          SnackBarUtils.showErrorSnackBar(
              result['message'] ?? 'Failed to create nurse');
        }
      }
    } catch (e) {
      SnackBarUtils.showErrorSnackBar('Failed to connect to server: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateNurse(String id, Map<String, dynamic> nurseData) async {
    isLoading.value = true;

    try {
      final dynamic result = await _httpClient.put(
        '${ApiEndpoints.nursesEndpoint}/$id',
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(nurseData),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Nurse updated successfully');
          loadNurses();
        } else {
          SnackBarUtils.showErrorSnackBar(
              result['message'] ?? 'Failed to update nurse');
        }
      }
    } catch (e) {
      SnackBarUtils.showErrorSnackBar('Failed to connect to server: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteNurse(String id) async {
    isLoading.value = true;

    try {
      final dynamic result = await _httpClient.delete(
        '${ApiEndpoints.nursesEndpoint}/$id',
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Nurse deleted successfully');
          loadNurses();
        } else {
          SnackBarUtils.showErrorSnackBar(
              result['message'] ?? 'Failed to delete nurse');
        }
      }
    } catch (e) {
      SnackBarUtils.showErrorSnackBar('Failed to connect to server: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
