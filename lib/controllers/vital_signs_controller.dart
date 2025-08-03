import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/models/vital_signs_model.dart';
import 'package:ige_hospital/provider/vital_signs_service.dart';
import 'package:ige_hospital/utils/snack_bar_utils.dart';

class VitalSignsController extends GetxController {
  final VitalSignsService _vitalSignsService = Get.put(VitalSignsService());

  // Observable variables
  var vitalSigns = <VitalSignModel>[].obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  // Pagination
  var currentPage = 1.obs;
  var totalVitalSigns = 0.obs;
  var perPage = 20.obs;
  var lastPage = 1.obs;

  // Current patient ID
  var currentPatientId = ''.obs;
  var currentPatientName = ''.obs;

  // Form controllers for create/edit
  final systolicController = TextEditingController();
  final diastolicController = TextEditingController();
  final heartRateController = TextEditingController();
  final temperatureController = TextEditingController();
  final respiratoryRateController = TextEditingController();
  final oxygenSaturationController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final notesController = TextEditingController();

  // Temperature unit
  var temperatureUnit = 'celsius'.obs;
  var weightUnit = 'kg'.obs;
  var heightUnit = 'cm'.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  void _disposeControllers() {
    systolicController.dispose();
    diastolicController.dispose();
    heartRateController.dispose();
    temperatureController.dispose();
    respiratoryRateController.dispose();
    oxygenSaturationController.dispose();
    weightController.dispose();
    heightController.dispose();
    notesController.dispose();
  }

  // Initialize for a specific patient
  void initializeForPatient(String patientId, String patientName) {
    currentPatientId.value = patientId;
    currentPatientName.value = patientName;
    currentPage.value = 1;
    loadVitalSigns();
  }

  // Load vital signs for current patient
  Future<void> loadVitalSigns() async {
    if (currentPatientId.value.isEmpty) return;

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await _vitalSignsService.getPatientVitalSigns(
        patientId: currentPatientId.value,
        page: currentPage.value,
        perPage: perPage.value,
      );

      vitalSigns.value = result['vital_signs'];
      totalVitalSigns.value = result['total'];
      lastPage.value = result['last_page'];
      currentPage.value = result['current_page'];

    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      Get.log("Error loading vital signs: $e");
      SnackBarUtils.showErrorSnackBar('Failed to load vital signs: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Create new vital signs
  Future<void> createVitalSigns() async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;

      final vitalSignsData = {
        'patient_id': currentPatientId.value,
        'systolic_pressure': int.parse(systolicController.text),
        'diastolic_pressure': int.parse(diastolicController.text),
        'heart_rate': int.parse(heartRateController.text),
        'temperature': double.parse(temperatureController.text),
        'temperature_unit': temperatureUnit.value,
        'respiratory_rate': int.parse(respiratoryRateController.text),
        'oxygen_saturation': int.parse(oxygenSaturationController.text),
        'weight': double.parse(weightController.text),
        'weight_unit': weightUnit.value,
        'height': int.parse(heightController.text),
        'height_unit': heightUnit.value,
        'notes': notesController.text,
        'recorded_at': DateTime.now().toIso8601String(),
      };

      await _vitalSignsService.createVitalSigns(vitalSignsData);
      await loadVitalSigns(); // Refresh list
      clearForm();
      Get.back(); // Close dialog

    } catch (e) {
      Get.log("Error creating vital signs: $e");
      SnackBarUtils.showErrorSnackBar('Failed to create vital signs: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Update vital signs
  Future<void> updateVitalSigns(String id) async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;

      final vitalSignsData = {
        'systolic_pressure': int.parse(systolicController.text),
        'diastolic_pressure': int.parse(diastolicController.text),
        'heart_rate': int.parse(heartRateController.text),
        'temperature': double.parse(temperatureController.text),
        'temperature_unit': temperatureUnit.value,
        'respiratory_rate': int.parse(respiratoryRateController.text),
        'oxygen_saturation': int.parse(oxygenSaturationController.text),
        'weight': double.parse(weightController.text),
        'weight_unit': weightUnit.value,
        'height': int.parse(heightController.text),
        'height_unit': heightUnit.value,
        'notes': notesController.text,
      };

      await _vitalSignsService.updateVitalSigns(id, vitalSignsData);
      await loadVitalSigns(); // Refresh list
      clearForm();
      Get.back(); // Close dialog

    } catch (e) {
      Get.log("Error updating vital signs: $e");
      SnackBarUtils.showErrorSnackBar('Failed to update vital signs: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete vital signs
  Future<void> deleteVitalSigns(String id) async {
    try {
      await _vitalSignsService.deleteVitalSigns(id);
      await loadVitalSigns(); // Refresh list
    } catch (e) {
      Get.log("Error deleting vital signs: $e");
      SnackBarUtils.showErrorSnackBar('Failed to delete vital signs: ${e.toString()}');
    }
  }

  // Fill form with existing data for editing
  void fillFormForEdit(VitalSignModel vitalSign) {
    systolicController.text = vitalSign.systolicPressure.toString();
    diastolicController.text = vitalSign.diastolicPressure.toString();
    heartRateController.text = vitalSign.heartRate.replaceAll(' bpm', '');
    temperatureController.text = vitalSign.temperature.replaceAll('°C', '');
    respiratoryRateController.text = vitalSign.respiratoryRate.replaceAll(' /min', '');
    oxygenSaturationController.text = vitalSign.oxygenSaturation.replaceAll('%', '');
    weightController.text = vitalSign.weight.replaceAll(' kg', '');
    heightController.text = vitalSign.height.replaceAll(' cm', '');
    notesController.text = vitalSign.notes;
  }

  // Clear form
  void clearForm() {
    systolicController.clear();
    diastolicController.clear();
    heartRateController.clear();
    temperatureController.clear();
    respiratoryRateController.clear();
    oxygenSaturationController.clear();
    weightController.clear();
    heightController.clear();
    notesController.clear();
    temperatureUnit.value = 'celsius';
    weightUnit.value = 'kg';
    heightUnit.value = 'cm';
  }

  // Validate form
  bool _validateForm() {
    if (systolicController.text.isEmpty ||
        diastolicController.text.isEmpty ||
        heartRateController.text.isEmpty ||
        temperatureController.text.isEmpty ||
        respiratoryRateController.text.isEmpty ||
        oxygenSaturationController.text.isEmpty ||
        weightController.text.isEmpty ||
        heightController.text.isEmpty) {
      SnackBarUtils.showErrorSnackBar('Please fill all required fields');
      return false;
    }

    // Validate numeric inputs
    if (int.tryParse(systolicController.text) == null ||
        int.tryParse(diastolicController.text) == null ||
        int.tryParse(heartRateController.text) == null ||
        double.tryParse(temperatureController.text) == null ||
        int.tryParse(respiratoryRateController.text) == null ||
        int.tryParse(oxygenSaturationController.text) == null ||
        double.tryParse(weightController.text) == null ||
        int.tryParse(heightController.text) == null) {
      SnackBarUtils.showErrorSnackBar('Please enter valid numeric values');
      return false;
    }

    return true;
  }

  // Pagination methods
  void nextPage() {
    if (currentPage.value < lastPage.value) {
      currentPage.value++;
      loadVitalSigns();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      loadVitalSigns();
    }
  }

  void setPage(int page) {
    if (page >= 1 && page <= lastPage.value) {
      currentPage.value = page;
      loadVitalSigns();
    }
  }

  // Helper methods for analysis
  int get normalCount => vitalSigns.where((v) => v.overallStatus == 'Normal').length;
  int get attentionCount => vitalSigns.where((v) => v.overallStatus == 'Attention').length;
  int get criticalCount => vitalSigns.where((v) => v.overallStatus == 'Critical').length;

  // Get the latest vital signs
  VitalSignModel? get latestVitalSigns {
    if (vitalSigns.isEmpty) return null;
    return vitalSigns.first; // Assuming the list is sorted by date descending
  }

  // Check if there are any critical readings
  bool get hasCriticalReadings => criticalCount > 0;

  // Get color based on vital sign status
  Color getStatusColor(String status) {
    switch (status) {
      case 'Normal':
        return Colors.green;
      case 'Attention':
        return Colors.orange;
      case 'Critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get status text
  String getStatusText(String status) {
    switch (status) {
      case 'Normal':
        return 'Normal';
      case 'Attention':
        return 'Needs Attention';
      case 'Critical':
        return 'Critical';
      default:
        return 'Unknown';
    }
  }
}