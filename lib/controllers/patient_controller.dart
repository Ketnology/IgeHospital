import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ige_hospital/models/patient_model.dart';
import 'package:ige_hospital/provider/patient_service.dart';
import 'package:ige_hospital/utils/snack_bar_utils.dart';

class PatientController extends GetxController {
  final PatientService _patientService = PatientService();

  // Reactive variables
  var isLoading = false.obs;
  final RxBool hasError = false.obs;
  var patients = <PatientModel>[].obs;
  var filteredPatients = <PatientModel>[].obs;

  // Pagination
  final RxInt totalPatients = 0.obs;
  final RxInt currentPage = 1.obs;
  final RxInt perPage = 12.obs;

  // Filter variables
  var searchQuery = ''.obs;
  var selectedGender = ''.obs;
  var selectedBloodGroup = ''.obs;
  var dateFrom = ''.obs;
  var dateTo = ''.obs;
  var sortBy = 'created_at'.obs;
  var sortDirection = 'desc'.obs;

  // Gender options for filter dropdown
  final genders = ['All', 'Male', 'Female'].obs;

  // Blood group options for filter dropdown
  final bloodGroups =
      ['All', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].obs;

  @override
  void onInit() {
    super.onInit();
    loadPatients();

    // Initialize filter listeners
    ever(searchQuery, (_) => applyFilters());
    ever(selectedGender, (_) => applyFilters());
    ever(selectedBloodGroup, (_) => applyFilters());
    ever(dateFrom, (_) => applyFilters());
    ever(dateTo, (_) => applyFilters());
    ever(sortDirection, (_) => applyFilters());
  }

  Future<void> loadPatients() async {
    isLoading.value = true;

    try {
      final Map<String, dynamic> result =
          await _patientService.getPatientsWithPagination(
        search: searchQuery.value,
        gender: selectedGender.value == 'All'
            ? ''
            : selectedGender.value.toLowerCase(),
        bloodGroup:
            selectedBloodGroup.value == 'All' ? '' : selectedBloodGroup.value,
        dateFrom: dateFrom.value,
        dateTo: dateTo.value,
        sortBy: sortBy.value,
        sortDirection: sortDirection.value,
        page: currentPage.value,
        perPage: perPage.value,
      );

      // Update patients list
      patients.value = result['patients'] as List<PatientModel>;

      // Update pagination info
      totalPatients.value = result['total'] as int;

      // Apply filters to update filteredPatients
      applyFilters();
    } catch (e) {
      Get.log("Error loading patients: $e");
      SnackBarUtils.showErrorSnackBar('Failed to load patients: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    filteredPatients.value = patients.where((patient) {
      // Search by name, email, or phone
      bool matchesSearch = true;
      if (searchQuery.value.isNotEmpty) {
        final String fullName = patient.user['full_name'] ?? '';
        final String email = patient.user['email'] ?? '';
        final String phone = patient.user['phone'] ?? '';

        matchesSearch =
            fullName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
                email.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
                phone.toLowerCase().contains(searchQuery.value.toLowerCase());
      }

      // Filter by gender
      bool matchesGender = true;
      if (selectedGender.value.isNotEmpty && selectedGender.value != 'All') {
        final String gender = patient.user['gender'] ?? '';
        matchesGender =
            gender.toLowerCase() == selectedGender.value.toLowerCase();
      }

      // Filter by blood group
      bool matchesBloodGroup = true;
      if (selectedBloodGroup.value.isNotEmpty &&
          selectedBloodGroup.value != 'All') {
        final String bloodGroup = patient.user['blood_group'] ?? '';
        matchesBloodGroup = bloodGroup == selectedBloodGroup.value;
      }

      // Date range filtering would be applied in the API call

      return matchesSearch && matchesGender && matchesBloodGroup;
    }).toList();

    // Sort the list
    if (sortDirection.value == 'asc') {
      filteredPatients.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else {
      filteredPatients.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  void resetFilters() {
    searchQuery.value = '';
    selectedGender.value = 'All';
    selectedBloodGroup.value = 'All';
    dateFrom.value = '';
    dateTo.value = '';
    sortDirection.value = 'desc';

    // Reset pagination to first page
    currentPage.value = 1;

    // Reload patients from API with reset filters
    loadPatients();
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

  Future<void> addPatient(Map<String, dynamic> patientData) async {
    isLoading.value = true;

    try {
      await _patientService.createPatient(patientData);
      SnackBarUtils.showSuccessSnackBar('Patient added successfully');
      loadPatients();
    } catch (e) {
      SnackBarUtils.showErrorSnackBar('Failed to add patient: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePatient(
      String id, Map<String, dynamic> patientData) async {
    isLoading.value = true;

    try {
      await _patientService.updatePatient(id, patientData);
      SnackBarUtils.showSuccessSnackBar('Patient updated successfully');
      loadPatients();
    } catch (e) {
      SnackBarUtils.showErrorSnackBar('Failed to update patient: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePatient(String id) async {
    isLoading.value = true;

    try {
      await _patientService.deletePatient(id);
      SnackBarUtils.showSuccessSnackBar('Patient deleted successfully');
      loadPatients();
    } catch (e) {
      SnackBarUtils.showErrorSnackBar('Failed to delete patient: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setPage(int page) {
    if (page < 1) page = 1;
    int maxPage = (totalPatients.value / perPage.value).ceil();
    if (page > maxPage) page = maxPage;

    if (currentPage.value != page) {
      currentPage.value = page;
      loadPatients();
    }
  }

  void nextPage() {
    int maxPages = (totalPatients.value / perPage.value).ceil();
    if (currentPage.value < maxPages) {
      currentPage.value++;
      loadPatients();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      loadPatients();
    }
  }
}
