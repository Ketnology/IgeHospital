# Controllers Documentation

> **Document Version:** 1.0.0
> **Last Updated:** November 2024

## Overview

Controllers in IGE Hospital are GetX controllers that manage UI state and coordinate between views and services. They handle user interactions, form validation, and reactive state updates.

---

## Controller Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                          VIEW                                │
│  Pages, Widgets, Dialogs                                    │
└──────────────────────────────┬──────────────────────────────┘
                               │ User Actions
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                       CONTROLLER                             │
│  - UI State (isLoading, hasError, etc.)                     │
│  - Form Controllers (TextEditingController)                 │
│  - Business Logic Coordination                              │
│  - Event Handlers                                           │
└──────────────────────────────┬──────────────────────────────┘
                               │ API Calls
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                        SERVICE                               │
│  API Communication, Data Transformation                     │
└─────────────────────────────────────────────────────────────┘
```

---

## Auth Controller

### Location: `lib/controllers/auth_controller.dart`

Manages authentication UI and user state display.

```dart
class AuthController extends GetxController {
  // Service dependency
  final AuthService authService = Get.find<AuthService>();

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // UI State
  final RxBool isLoading = false.obs;
  final RxString userName = "".obs;
  final RxString userEmail = "".obs;
  final RxString userRole = "".obs;

  @override
  void onInit() {
    super.onInit();
    updateUserInfo();

    // Listen to auth changes
    ever(authService.currentUser, (_) => updateUserInfo());
    ever(authService.isAuthenticated, (_) => updateUserInfo());
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Update displayed user info
  void updateUserInfo() {
    if (authService.isAuthenticated.value &&
        authService.currentUser.value != null) {
      userName.value = authService.getUserName();
      userEmail.value = authService.getUserEmail();
      userRole.value = authService.getUserType();
    } else {
      userName.value = "";
      userEmail.value = "";
      userRole.value = "";
    }
  }

  /// Handle login
  Future<void> login() async {
    if (!_validateInputs()) return;

    isLoading.value = true;

    try {
      await authService.login(
        emailController.text.trim(),
        passwordController.text,
      );
      _clearForm();
    } catch (e) {
      SnackBarUtils.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle logout
  Future<void> logout() async {
    await authService.logout();
  }

  /// Validate form inputs
  bool _validateInputs() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty) {
      SnackBarUtils.showError('Please enter your email');
      return false;
    }

    if (!_isValidEmail(email)) {
      SnackBarUtils.showError('Please enter a valid email');
      return false;
    }

    if (password.isEmpty) {
      SnackBarUtils.showError('Please enter your password');
      return false;
    }

    if (password.length < 6) {
      SnackBarUtils.showError('Password must be at least 6 characters');
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _clearForm() {
    emailController.clear();
    passwordController.clear();
  }
}
```

---

## Patient Controller

### Location: `lib/controllers/patient_controller.dart`

Manages patient list, filters, and CRUD operations.

```dart
class PatientController extends GetxController {
  // Service dependency
  final PatientService _patientService = Get.put(PatientService());

  // Data state
  var patients = <PatientModel>[].obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  // Pagination
  var currentPage = 1.obs;
  var totalPatients = 0.obs;
  var perPage = 12.obs;
  var lastPage = 1.obs;

  // Filters
  var searchQuery = ''.obs;
  var selectedGender = ''.obs;
  var selectedBloodGroup = ''.obs;
  var dateFrom = ''.obs;
  var dateTo = ''.obs;

  // Sorting
  var sortBy = 'created_at'.obs;
  var sortDirection = 'desc'.obs;

  @override
  void onInit() {
    super.onInit();
    loadPatients();

    // Debounce search
    debounce(
      searchQuery,
      (_) => _applyFilters(),
      time: const Duration(milliseconds: 500),
    );
  }

  /// Load patients with current filters
  Future<void> loadPatients() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final result = await _patientService.getPatientsWithPagination(
        page: currentPage.value,
        perPage: perPage.value,
        search: searchQuery.value,
        gender: selectedGender.value,
        bloodGroup: selectedBloodGroup.value,
        dateFrom: dateFrom.value,
        dateTo: dateTo.value,
        sortBy: sortBy.value,
        sortDirection: sortDirection.value,
      );

      patients.value = result['patients'];
      totalPatients.value = result['total'];
      lastPage.value = result['lastPage'];
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      Get.log('Error loading patients: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Add new patient
  Future<bool> addPatient(Map<String, dynamic> data) async {
    try {
      await _patientService.createPatient(data);
      await loadPatients();
      SnackBarUtils.showSuccess('Patient created successfully');
      return true;
    } catch (e) {
      SnackBarUtils.showError(e.toString());
      return false;
    }
  }

  /// Update existing patient
  Future<bool> updatePatient(String id, Map<String, dynamic> data) async {
    try {
      await _patientService.updatePatient(id, data);
      await loadPatients();
      SnackBarUtils.showSuccess('Patient updated successfully');
      return true;
    } catch (e) {
      SnackBarUtils.showError(e.toString());
      return false;
    }
  }

  /// Delete patient
  Future<bool> deletePatient(String id) async {
    try {
      await _patientService.deletePatient(id);
      await loadPatients();
      SnackBarUtils.showSuccess('Patient deleted successfully');
      return true;
    } catch (e) {
      SnackBarUtils.showError(e.toString());
      return false;
    }
  }

  /// Navigate to page
  void goToPage(int page) {
    if (page >= 1 && page <= lastPage.value) {
      currentPage.value = page;
      loadPatients();
    }
  }

  /// Apply filters (reset to page 1)
  void _applyFilters() {
    currentPage.value = 1;
    loadPatients();
  }

  /// Set gender filter
  void setGenderFilter(String gender) {
    selectedGender.value = gender;
    _applyFilters();
  }

  /// Set blood group filter
  void setBloodGroupFilter(String bloodGroup) {
    selectedBloodGroup.value = bloodGroup;
    _applyFilters();
  }

  /// Set date range filter
  void setDateFilter(String from, String to) {
    dateFrom.value = from;
    dateTo.value = to;
    _applyFilters();
  }

  /// Clear all filters
  void clearFilters() {
    searchQuery.value = '';
    selectedGender.value = '';
    selectedBloodGroup.value = '';
    dateFrom.value = '';
    dateTo.value = '';
    _applyFilters();
  }

  /// Computed: filtered patients (client-side)
  List<PatientModel> get filteredPatients {
    if (searchQuery.value.isEmpty) return patients;

    final query = searchQuery.value.toLowerCase();
    return patients.where((p) {
      return p.name.toLowerCase().contains(query) ||
             p.email.toLowerCase().contains(query) ||
             p.phone.contains(query);
    }).toList();
  }

  /// Refresh data
  Future<void> refresh() async {
    currentPage.value = 1;
    await loadPatients();
  }
}
```

---

## Consultation Controller

### Location: `lib/controllers/consultation_controller.dart`

Manages live consultation operations.

```dart
class ConsultationController extends GetxController {
  final ConsultationService _service = Get.find<ConsultationService>();
  final PermissionService _permService = Get.find<PermissionService>();

  // Data state
  var consultations = <LiveConsultation>[].obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  // Filters
  var statusFilter = ''.obs;
  var dateFromFilter = ''.obs;
  var dateToFilter = ''.obs;

  // Statistics
  var statistics = Rxn<ConsultationStatistics>();

  @override
  void onInit() {
    super.onInit();
    loadConsultations();
    loadStatistics();
  }

  /// Load consultations
  Future<void> loadConsultations() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      consultations.value = await _service.getConsultations(
        status: statusFilter.value.isNotEmpty ? statusFilter.value : null,
        dateFrom: dateFromFilter.value.isNotEmpty ? dateFromFilter.value : null,
        dateTo: dateToFilter.value.isNotEmpty ? dateToFilter.value : null,
      );
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Load statistics
  Future<void> loadStatistics() async {
    try {
      statistics.value = await _service.getStatistics();
    } catch (e) {
      Get.log('Error loading statistics: $e');
    }
  }

  /// Join consultation
  Future<void> joinConsultation(String id) async {
    try {
      final joinInfo = await _service.joinConsultation(id);
      final joinUrl = joinInfo['join_url'] as String?;

      if (joinUrl != null && joinUrl.isNotEmpty) {
        // Open meeting URL
        // launchUrl(Uri.parse(joinUrl));
        SnackBarUtils.showSuccess('Opening meeting...');
      }
    } catch (e) {
      SnackBarUtils.showError(e.toString());
    }
  }

  /// Start consultation (doctor only)
  Future<void> startConsultation(String id) async {
    if (!_permService.hasPermission(Permissions.startConsultations)) {
      SnackBarUtils.showError('You cannot start consultations');
      return;
    }

    try {
      final startInfo = await _service.startConsultation(id);
      await loadConsultations();
      SnackBarUtils.showSuccess('Consultation started');

      final startUrl = startInfo['start_url'] as String?;
      if (startUrl != null) {
        // Open host URL
      }
    } catch (e) {
      SnackBarUtils.showError(e.toString());
    }
  }

  /// End consultation (doctor only)
  Future<void> endConsultation(String id) async {
    if (!_permService.hasPermission(Permissions.endConsultations)) {
      SnackBarUtils.showError('You cannot end consultations');
      return;
    }

    try {
      await _service.endConsultation(id);
      await loadConsultations();
      SnackBarUtils.showSuccess('Consultation ended');
    } catch (e) {
      SnackBarUtils.showError(e.toString());
    }
  }

  /// Create new consultation
  Future<bool> createConsultation(Map<String, dynamic> data) async {
    try {
      await _service.createConsultation(data);
      await loadConsultations();
      await loadStatistics();
      SnackBarUtils.showSuccess('Consultation scheduled');
      return true;
    } catch (e) {
      SnackBarUtils.showError(e.toString());
      return false;
    }
  }

  /// Check if user can start a specific consultation
  bool canStartConsultation(LiveConsultation consultation) {
    if (!consultation.permissions.canStart) return false;
    if (!_permService.hasPermission(Permissions.startConsultations)) {
      return false;
    }

    // Doctors can only start their own
    if (_permService.isDoctor) {
      return consultation.doctor.id == _permService.currentUserId;
    }

    return _permService.isAdmin;
  }

  /// Computed: upcoming consultations
  List<LiveConsultation> get upcomingConsultations {
    return consultations.where((c) => c.statusInfo.isUpcoming).toList();
  }

  /// Computed: ongoing consultations
  List<LiveConsultation> get ongoingConsultations {
    return consultations.where((c) => c.isOngoing).toList();
  }

  /// Filter by status
  void filterByStatus(String status) {
    statusFilter.value = status;
    loadConsultations();
  }

  /// Clear filters
  void clearFilters() {
    statusFilter.value = '';
    dateFromFilter.value = '';
    dateToFilter.value = '';
    loadConsultations();
  }
}
```

---

## Vital Signs Controller

### Location: `lib/controllers/vital_signs_controller.dart`

Manages patient vital signs tracking.

```dart
class VitalSignsController extends GetxController {
  final VitalSignsService _service = Get.find<VitalSignsService>();

  // Current patient context
  var patientId = ''.obs;
  var patientName = ''.obs;

  // Data state
  var vitalSigns = <VitalSignModel>[].obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  // Pagination
  var currentPage = 1.obs;
  var totalRecords = 0.obs;
  var lastPage = 1.obs;

  /// Set patient context
  void setPatient(String id, String name) {
    patientId.value = id;
    patientName.value = name;
    currentPage.value = 1;
    loadVitalSigns();
  }

  /// Load vital signs for current patient
  Future<void> loadVitalSigns() async {
    if (patientId.value.isEmpty) return;

    isLoading.value = true;
    hasError.value = false;

    try {
      final result = await _service.getPatientVitalSigns(
        patientId.value,
        page: currentPage.value,
      );

      vitalSigns.value = result['vital_signs'];
      totalRecords.value = result['total'];
      lastPage.value = result['last_page'];
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Record new vital signs
  Future<bool> recordVitalSigns(Map<String, dynamic> data) async {
    try {
      data['patient_id'] = patientId.value;
      await _service.createVitalSigns(data);
      await loadVitalSigns();
      SnackBarUtils.showSuccess('Vital signs recorded');
      return true;
    } catch (e) {
      SnackBarUtils.showError(e.toString());
      return false;
    }
  }

  /// Update vital signs
  Future<bool> updateVitalSigns(String id, Map<String, dynamic> data) async {
    try {
      await _service.updateVitalSigns(id, data);
      await loadVitalSigns();
      SnackBarUtils.showSuccess('Vital signs updated');
      return true;
    } catch (e) {
      SnackBarUtils.showError(e.toString());
      return false;
    }
  }

  /// Delete vital signs
  Future<bool> deleteVitalSigns(String id) async {
    try {
      await _service.deleteVitalSigns(id);
      await loadVitalSigns();
      SnackBarUtils.showSuccess('Record deleted');
      return true;
    } catch (e) {
      SnackBarUtils.showError(e.toString());
      return false;
    }
  }

  /// Navigate pages
  void goToPage(int page) {
    if (page >= 1 && page <= lastPage.value) {
      currentPage.value = page;
      loadVitalSigns();
    }
  }

  /// Get latest vital signs
  VitalSignModel? get latestVitalSigns {
    return vitalSigns.isNotEmpty ? vitalSigns.first : null;
  }
}
```

---

## Accounting Controller

### Location: `lib/controllers/accounting_controller.dart`

Manages all accounting operations.

```dart
class AccountingController extends GetxController {
  final AccountingService _service = Get.put(AccountingService());

  // Tab state
  var currentTab = 0.obs;

  // Accounts
  var accounts = <Account>[].obs;
  var isLoadingAccounts = false.obs;

  // Payments
  var payments = <Payment>[].obs;
  var isLoadingPayments = false.obs;

  // Bills
  var bills = <Bill>[].obs;
  var isLoadingBills = false.obs;

  // Dashboard
  var dashboardData = Rxn<Map<String, dynamic>>();
  var isLoadingDashboard = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllData();
  }

  /// Load all accounting data
  Future<void> loadAllData() async {
    await Future.wait([
      loadAccounts(),
      loadPayments(),
      loadBills(),
      loadDashboard(),
    ]);
  }

  /// Load accounts
  Future<void> loadAccounts() async {
    isLoadingAccounts.value = true;
    try {
      accounts.value = await _service.getAccounts();
    } catch (e) {
      Get.log('Error loading accounts: $e');
    } finally {
      isLoadingAccounts.value = false;
    }
  }

  /// Load payments
  Future<void> loadPayments() async {
    isLoadingPayments.value = true;
    try {
      payments.value = await _service.getPayments();
    } catch (e) {
      Get.log('Error loading payments: $e');
    } finally {
      isLoadingPayments.value = false;
    }
  }

  /// Load bills
  Future<void> loadBills() async {
    isLoadingBills.value = true;
    try {
      bills.value = await _service.getBills();
    } catch (e) {
      Get.log('Error loading bills: $e');
    } finally {
      isLoadingBills.value = false;
    }
  }

  /// Load dashboard
  Future<void> loadDashboard() async {
    isLoadingDashboard.value = true;
    try {
      dashboardData.value = await _service.getAccountingDashboard();
    } catch (e) {
      Get.log('Error loading dashboard: $e');
    } finally {
      isLoadingDashboard.value = false;
    }
  }

  /// Create account
  Future<bool> createAccount(Map<String, dynamic> data) async {
    try {
      await _service.createAccount(data);
      await loadAccounts();
      SnackBarUtils.showSuccess('Account created');
      return true;
    } catch (e) {
      SnackBarUtils.showError(e.toString());
      return false;
    }
  }

  /// Toggle account status
  Future<void> toggleAccountStatus(String id) async {
    try {
      await _service.toggleAccountStatus(id);
      await loadAccounts();
    } catch (e) {
      SnackBarUtils.showError(e.toString());
    }
  }

  /// Create payment
  Future<bool> createPayment(Map<String, dynamic> data) async {
    try {
      await _service.createPayment(data);
      await loadPayments();
      await loadDashboard();
      SnackBarUtils.showSuccess('Payment recorded');
      return true;
    } catch (e) {
      SnackBarUtils.showError(e.toString());
      return false;
    }
  }

  /// Update bill status
  Future<void> updateBillStatus(String id, String status) async {
    try {
      await _service.updateBillStatus(id, status);
      await loadBills();
      await loadDashboard();
      SnackBarUtils.showSuccess('Bill status updated');
    } catch (e) {
      SnackBarUtils.showError(e.toString());
    }
  }

  /// Computed: active accounts
  List<Account> get activeAccounts {
    return accounts.where((a) => a.isActive).toList();
  }

  /// Computed: pending bills
  List<Bill> get pendingBills {
    return bills.where((b) => b.isPending).toList();
  }

  /// Computed: overdue bills
  List<Bill> get overdueBills {
    return bills.where((b) => b.isOverdue).toList();
  }
}
```

---

## Password Toggle Controller

### Location: `lib/controllers/password_toggle_controller.dart`

Simple controller for password field visibility.

```dart
class PasswordToggleController extends GetxController {
  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void reset() {
    isPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;
  }
}
```

---

## Controller Best Practices

### 1. Lifecycle Management

```dart
class MyController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // Initialize data, setup listeners
  }

  @override
  void onReady() {
    super.onReady();
    // Called after first frame rendered
  }

  @override
  void onClose() {
    // Dispose resources
    textController.dispose();
    subscription?.cancel();
    super.onClose();
  }
}
```

### 2. Error Handling Pattern

```dart
Future<bool> performAction() async {
  try {
    await _service.doSomething();
    SnackBarUtils.showSuccess('Success!');
    return true;
  } catch (e) {
    SnackBarUtils.showError(e.toString());
    return false;
  }
}
```

### 3. Loading State Pattern

```dart
var isLoading = false.obs;
var hasError = false.obs;
var errorMessage = ''.obs;

Future<void> loadData() async {
  isLoading.value = true;
  hasError.value = false;

  try {
    // Load data
  } catch (e) {
    hasError.value = true;
    errorMessage.value = e.toString();
  } finally {
    isLoading.value = false;
  }
}
```

### 4. Debounce Search

```dart
@override
void onInit() {
  super.onInit();

  debounce(
    searchQuery,
    (_) => loadData(),
    time: Duration(milliseconds: 500),
  );
}
```

### 5. Computed Properties

```dart
// Use getters for computed values
List<Item> get filteredItems {
  return items.where((i) => i.matches(filter)).toList();
}

int get totalCount => items.length;
```
