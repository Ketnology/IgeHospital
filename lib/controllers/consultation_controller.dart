import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/models/consultation_model.dart';
import 'package:ige_hospital/provider/consultation_service.dart';
import 'package:ige_hospital/utils/snack_bar_utils.dart';

class ConsultationController extends GetxController {
  final ConsultationService _consultationService = Get.put(ConsultationService());

  // Reactive variables
  var isLoading = false.obs;
  var consultations = <LiveConsultation>[].obs;
  var filteredConsultations = <LiveConsultation>[].obs;
  var upcomingConsultations = <LiveConsultation>[].obs;
  var todaysConsultations = <LiveConsultation>[].obs;
  var statistics = Rxn<ConsultationStatistics>();

  // Pagination
  final RxInt totalConsultations = 0.obs;
  final RxInt currentPage = 1.obs;
  final RxInt perPage = 12.obs;
  final RxInt lastPage = 1.obs;

  // Filter variables
  var searchQuery = ''.obs;
  var selectedDoctorId = ''.obs;
  var selectedPatientId = ''.obs;
  var selectedStatus = ''.obs;
  var selectedDateFrom = ''.obs;
  var selectedDateTo = ''.obs;
  var sortBy = 'consultation_date'.obs;
  var sortDirection = 'desc'.obs;

  // Status options
  final List<String> statusOptions = [
    'All',
    'Scheduled',
    'Ongoing',
    'Completed',
    'Cancelled'
  ];

  // Type options
  final List<String> typeOptions = [
    'All Types',
    'Scheduled',
    'Follow-up',
    'Emergency',
    'Comprehensive'
  ];

  @override
  void onInit() {
    super.onInit();
    loadConsultations();
    loadUpcomingConsultations();
    loadTodaysConsultations();
    loadStatistics();

    // Initialize filter listeners
    ever(searchQuery, (_) => _debounceSearch());
    ever(selectedDoctorId, (_) => loadConsultations());
    ever(selectedPatientId, (_) => loadConsultations());
    ever(selectedStatus, (_) => loadConsultations());
    ever(selectedDateFrom, (_) => loadConsultations());
    ever(selectedDateTo, (_) => loadConsultations());
    ever(sortDirection, (_) => loadConsultations());
  }

  // Debounced search to prevent too many API calls
  void _debounceSearch() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (searchQuery.value.isNotEmpty) {
        loadConsultations();
      }
    });
  }

  Future<void> loadConsultations() async {
    isLoading.value = true;

    try {
      final result = await _consultationService.getConsultations(
        doctorId: selectedDoctorId.value.isEmpty ? null : selectedDoctorId.value,
        patientId: selectedPatientId.value.isEmpty ? null : selectedPatientId.value,
        status: selectedStatus.value.isEmpty || selectedStatus.value == 'All'
            ? null : selectedStatus.value.toLowerCase(),
        dateFrom: selectedDateFrom.value.isEmpty ? null : selectedDateFrom.value,
        dateTo: selectedDateTo.value.isEmpty ? null : selectedDateTo.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        sortBy: sortBy.value,
        sortDirection: sortDirection.value,
        page: currentPage.value,
        perPage: perPage.value,
      );

      consultations.value = result['consultations'];
      filteredConsultations.value = result['consultations'];
      totalConsultations.value = result['total'];
      currentPage.value = result['current_page'];
      lastPage.value = result['last_page'];
    } catch (e) {
      Get.log("Error loading consultations: $e");
      SnackBarUtils.showErrorSnackBar('Failed to load consultations: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUpcomingConsultations({int limit = 10}) async {
    try {
      upcomingConsultations.value = await _consultationService.getUpcomingConsultations(limit: limit);
    } catch (e) {
      Get.log("Error loading upcoming consultations: $e");
      SnackBarUtils.showErrorSnackBar('Failed to load upcoming consultations');
    }
  }

  Future<void> loadTodaysConsultations() async {
    try {
      todaysConsultations.value = await _consultationService.getTodaysConsultations();
    } catch (e) {
      Get.log("Error loading today's consultations: $e");
      SnackBarUtils.showErrorSnackBar('Failed to load today\'s consultations');
    }
  }

  Future<void> loadStatistics({String? dateFrom, String? dateTo}) async {
    try {
      statistics.value = await _consultationService.getConsultationStatistics(
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
    } catch (e) {
      Get.log("Error loading consultation statistics: $e");
      SnackBarUtils.showErrorSnackBar('Failed to load consultation statistics');
    }
  }

  Future<LiveConsultation?> getConsultationById(String id) async {
    try {
      return await _consultationService.getConsultationById(id);
    } catch (e) {
      Get.log("Error getting consultation by ID: $e");
      SnackBarUtils.showErrorSnackBar('Failed to get consultation details');
      return null;
    }
  }

  Future<void> createConsultation(Map<String, dynamic> consultationData) async {
    isLoading.value = true;

    try {
      await _consultationService.createConsultation(consultationData);
      loadConsultations();
      loadUpcomingConsultations();
    } catch (e) {
      SnackBarUtils.showErrorSnackBar('Failed to create consultation: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateConsultation(String id, Map<String, dynamic> consultationData) async {
    isLoading.value = true;

    try {
      await _consultationService.updateConsultation(id, consultationData);
      loadConsultations();
      loadUpcomingConsultations();
    } catch (e) {
      SnackBarUtils.showErrorSnackBar('Failed to update consultation: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteConsultation(String id) async {
    isLoading.value = true;

    try {
      await _consultationService.deleteConsultation(id);
      loadConsultations();
      loadUpcomingConsultations();
    } catch (e) {
      SnackBarUtils.showErrorSnackBar('Failed to delete consultation: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> joinConsultation(String id) async {
    try {
      await _consultationService.joinConsultation(id);
      loadConsultations();
    } catch (e) {
      SnackBarUtils.showErrorSnackBar('Failed to join consultation: ${e.toString()}');
    }
  }

  Future<void> startConsultation(String id) async {
    try {
      await _consultationService.startConsultation(id);
      loadConsultations();
      loadTodaysConsultations();
    } catch (e) {
      SnackBarUtils.showErrorSnackBar('Failed to start consultation: ${e.toString()}');
    }
  }

  Future<void> endConsultation(String id) async {
    try {
      await _consultationService.endConsultation(id);
      loadConsultations();
      loadTodaysConsultations();
    } catch (e) {
      SnackBarUtils.showErrorSnackBar('Failed to end consultation: ${e.toString()}');
    }
  }

  Future<void> changeConsultationStatus(String id, String status) async {
    try {
      await _consultationService.changeConsultationStatus(id, status);
      loadConsultations();
      loadUpcomingConsultations();
      loadTodaysConsultations();
    } catch (e) {
      SnackBarUtils.showErrorSnackBar('Failed to change consultation status: ${e.toString()}');
    }
  }

  void resetFilters() {
    searchQuery.value = '';
    selectedDoctorId.value = '';
    selectedPatientId.value = '';
    selectedStatus.value = '';
    selectedDateFrom.value = '';
    selectedDateTo.value = '';
    sortDirection.value = 'desc';
    currentPage.value = 1;
    loadConsultations();
  }

  void changePage(int page) {
    currentPage.value = page;
    loadConsultations();
  }

  void nextPage() {
    if (currentPage.value < lastPage.value) {
      currentPage.value++;
      loadConsultations();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      loadConsultations();
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return const Color(0xFF3B82F6); // Blue
      case 'ongoing':
        return const Color(0xFF10B981); // Green
      case 'completed':
        return const Color(0xFF6B7280); // Gray
      case 'cancelled':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'Scheduled';
      case 'ongoing':
        return 'Ongoing';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.capitalizeFirst ?? status;
    }
  }

  Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'scheduled':
        return const Color(0xFF3B82F6); // Blue
      case 'follow-up':
        return const Color(0xFF8B5CF6); // Purple
      case 'emergency':
        return const Color(0xFFEF4444); // Red
      case 'comprehensive':
        return const Color(0xFF10B981); // Green
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  Icon getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'scheduled':
        return const Icon(Icons.schedule, size: 16);
      case 'follow-up':
        return const Icon(Icons.repeat, size: 16);
      case 'emergency':
        return const Icon(Icons.emergency, size: 16);
      case 'comprehensive':
        return const Icon(Icons.medical_services, size: 16);
      default:
        return const Icon(Icons.video_call, size: 16);
    }
  }

  bool get hasNextPage => currentPage.value < lastPage.value;
  bool get hasPreviousPage => currentPage.value > 1;

  String get pageInfo {
    if (totalConsultations.value == 0) return '0 consultations';

    final start = ((currentPage.value - 1) * perPage.value) + 1;
    final end = (currentPage.value * perPage.value > totalConsultations.value)
        ? totalConsultations.value
        : currentPage.value * perPage.value;

    return '$start-$end of ${totalConsultations.value}';
  }
}