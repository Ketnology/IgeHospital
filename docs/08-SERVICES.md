# Services Documentation

> **Document Version:** 1.0.0
> **Last Updated:** November 2024

## Overview

Services in IGE Hospital handle business logic and API communication. They are GetX controllers that provide a clean interface between UI/Controllers and the REST API.

---

## Service Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                       CONTROLLERS                            │
│  PatientController | DoctorController | ConsultController   │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                        SERVICES                              │
│  PatientService | DoctorService | ConsultationService       │
│  - API method calls                                          │
│  - Request/Response handling                                 │
│  - Data transformation                                       │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                      HTTP CLIENT                             │
│  - Token injection                                           │
│  - Request execution                                         │
│  - Error handling                                            │
└─────────────────────────────────────────────────────────────┘
```

---

## HTTP Client

### Location: `lib/utils/http_client.dart`

The HttpClient is a singleton that handles all API communication.

```dart
class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;
  HttpClient._internal();

  /// GET request
  Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    await _validateTokenIfNeeded();
    return await http.get(
      Uri.parse(url),
      headers: _addAuthHeader(headers),
    );
  }

  /// POST request
  Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    await _validateTokenIfNeeded();
    return await http.post(
      Uri.parse(url),
      headers: _addAuthHeader(headers),
      body: body is String ? body : jsonEncode(body),
    );
  }

  /// PUT request
  Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    await _validateTokenIfNeeded();
    return await http.put(
      Uri.parse(url),
      headers: _addAuthHeader(headers),
      body: body is String ? body : jsonEncode(body),
    );
  }

  /// PATCH request
  Future<http.Response> patch(
    String url, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    await _validateTokenIfNeeded();
    return await http.patch(
      Uri.parse(url),
      headers: _addAuthHeader(headers),
      body: body is String ? body : jsonEncode(body),
    );
  }

  /// DELETE request
  Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
  }) async {
    await _validateTokenIfNeeded();
    return await http.delete(
      Uri.parse(url),
      headers: _addAuthHeader(headers),
    );
  }

  /// Add authorization header
  Map<String, String> _addAuthHeader(Map<String, String>? headers) {
    final authService = Get.find<AuthService>();
    final token = authService.token.value;

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Check token expiration
  bool _isTokenExpired() {
    try {
      final authService = Get.find<AuthService>();
      final expiration = authService.tokenExpiration.value;

      if (expiration.isEmpty) return false;

      final expirationTime = int.parse(expiration);
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(
        expirationTime * 1000,
      );

      // Consider expired if within 5 minutes
      final buffer = Duration(minutes: 5);
      return DateTime.now().isAfter(expirationDate.subtract(buffer));
    } catch (e) {
      return false;
    }
  }

  /// Validate token if needed
  Future<void> _validateTokenIfNeeded() async {
    if (_isTokenExpired()) {
      final authService = Get.find<AuthService>();
      await authService.validateToken();
    }
  }
}
```

---

## Authentication Service

### Location: `lib/provider/auth_service.dart`

Handles authentication, token management, and user session.

```dart
class AuthService extends GetxController implements GetxService {
  // Reactive state
  final RxBool isAuthenticated = false.obs;
  final RxString token = ''.obs;
  final RxString tokenExpiration = ''.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isRefreshing = false.obs;

  /// Initialize service (load saved session)
  Future<AuthService> init() async {
    await loadToken();
    await loadUser();
    return this;
  }

  /// Login user
  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final json = jsonDecode(response.body);

    if (response.statusCode == 200 && json['status'] == 200) {
      final data = json['data'];
      await _saveSession(
        data['access_token'],
        data['token_expiration'],
        data['user'],
      );
      Get.offAllNamed(Routes.homepage);
    } else {
      throw Exception(json['message'] ?? 'Login failed');
    }
  }

  /// Validate and refresh token
  Future<bool> validateToken() async {
    if (isRefreshing.value) return true;
    if (token.value.isEmpty) return false;

    isRefreshing.value = true;

    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.validateToken),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token.value}',
        },
      );

      final json = jsonDecode(response.body);

      if (response.statusCode == 200 && json['status'] == 200) {
        final newExpiration = json['data']['token_expiration'];
        await updateTokenExpiration(newExpiration);
        return true;
      } else {
        await logout();
        return false;
      }
    } catch (e) {
      Get.log('Token validation error: $e');
      return false;
    } finally {
      isRefreshing.value = false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      if (token.value.isNotEmpty) {
        await http.post(
          Uri.parse(ApiEndpoints.logout),
          headers: {'Authorization': 'Bearer ${token.value}'},
        );
      }
    } catch (e) {
      // Ignore errors
    }

    await _clearSession();
    Get.offAllNamed(Routes.login);
  }

  // Convenience getters
  String getUserName() => currentUser.value?.name ?? '';
  String getUserEmail() => currentUser.value?.email ?? '';
  String getUserType() => _formatUserType(currentUser.value?.userType ?? '');
  String getRawUserType() => currentUser.value?.userType ?? '';
}
```

---

## Patient Service

### Location: `lib/provider/patient_service.dart`

Handles patient CRUD operations.

```dart
class PatientService extends GetxController {
  final HttpClient _http = HttpClient();

  /// Get patients with pagination and filters
  Future<Map<String, dynamic>> getPatientsWithPagination({
    int page = 1,
    int perPage = 12,
    String? search,
    String? gender,
    String? bloodGroup,
    String? dateFrom,
    String? dateTo,
    String sortBy = 'created_at',
    String sortDirection = 'desc',
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
      'sort_by': sortBy,
      'sort_direction': sortDirection,
    };

    if (search?.isNotEmpty ?? false) queryParams['search'] = search!;
    if (gender?.isNotEmpty ?? false) queryParams['gender'] = gender!;
    if (bloodGroup?.isNotEmpty ?? false) queryParams['blood_group'] = bloodGroup!;
    if (dateFrom?.isNotEmpty ?? false) queryParams['date_from'] = dateFrom!;
    if (dateTo?.isNotEmpty ?? false) queryParams['date_to'] = dateTo!;

    final url = Uri.parse(ApiEndpoints.patients)
        .replace(queryParameters: queryParams);

    final response = await _http.get(url.toString());
    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final data = json['data'];
      return {
        'patients': (data['data'] as List)
            .map((p) => PatientModel.fromJson(p))
            .toList(),
        'total': data['total'] ?? 0,
        'perPage': data['per_page'] ?? perPage,
        'currentPage': data['current_page'] ?? page,
        'lastPage': data['last_page'] ?? 1,
      };
    } else {
      throw Exception(json['message'] ?? 'Failed to load patients');
    }
  }

  /// Get single patient
  Future<PatientModel> getPatientById(String id) async {
    final response = await _http.get('${ApiEndpoints.patients}/$id');
    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return PatientModel.fromJson(json['data']);
    } else {
      throw Exception(json['message'] ?? 'Failed to load patient');
    }
  }

  /// Create patient
  Future<PatientModel> createPatient(Map<String, dynamic> data) async {
    final response = await _http.post(ApiEndpoints.patients, body: data);
    final json = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return PatientModel.fromJson(json['data']);
    } else {
      throw Exception(json['message'] ?? 'Failed to create patient');
    }
  }

  /// Update patient
  Future<PatientModel> updatePatient(String id, Map<String, dynamic> data) async {
    final response = await _http.put('${ApiEndpoints.patients}/$id', body: data);
    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return PatientModel.fromJson(json['data']);
    } else {
      throw Exception(json['message'] ?? 'Failed to update patient');
    }
  }

  /// Delete patient
  Future<void> deletePatient(String id) async {
    final response = await _http.delete('${ApiEndpoints.patients}/$id');

    if (response.statusCode != 200) {
      final json = jsonDecode(response.body);
      throw Exception(json['message'] ?? 'Failed to delete patient');
    }
  }
}
```

---

## Appointment Service

### Location: `lib/provider/appointment_service.dart`

Handles appointment management with reactive state.

```dart
class AppointmentService extends GetxController {
  final HttpClient _http = HttpClient();

  // Reactive state
  var appointments = <AppointmentModel>[].obs;
  var totalAppointments = 0.obs;
  var currentPage = 1.obs;
  var isLoading = false.obs;

  // Filters
  var searchQuery = ''.obs;
  var selectedDoctorId = ''.obs;
  var selectedPatientId = ''.obs;
  var selectedDepartmentId = ''.obs;
  var dateFrom = ''.obs;
  var dateTo = ''.obs;
  var filterCompleted = Rxn<bool>();
  var sortBy = 'appointment_date'.obs;
  var sortDirection = 'desc'.obs;

  /// Fetch appointments with current filters
  Future<void> fetchAppointments() async {
    isLoading.value = true;

    try {
      final queryParams = <String, String>{
        'page': currentPage.value.toString(),
        'per_page': '12',
        'sort_by': sortBy.value,
        'sort_direction': sortDirection.value,
      };

      if (searchQuery.value.isNotEmpty) {
        queryParams['search'] = searchQuery.value;
      }
      if (selectedDoctorId.value.isNotEmpty) {
        queryParams['doctor_id'] = selectedDoctorId.value;
      }
      if (selectedPatientId.value.isNotEmpty) {
        queryParams['patient_id'] = selectedPatientId.value;
      }
      if (dateFrom.value.isNotEmpty) {
        queryParams['date_from'] = dateFrom.value;
      }
      if (dateTo.value.isNotEmpty) {
        queryParams['date_to'] = dateTo.value;
      }
      if (filterCompleted.value != null) {
        queryParams['is_completed'] = filterCompleted.value.toString();
      }

      final url = Uri.parse(ApiEndpoints.appointments)
          .replace(queryParameters: queryParams);

      final response = await _http.get(url.toString());
      final json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final data = json['data'];
        appointments.value = (data['data'] as List)
            .map((a) => AppointmentModel.fromJson(a))
            .toList();
        totalAppointments.value = data['total'] ?? 0;
      }
    } catch (e) {
      Get.log('Error fetching appointments: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Create appointment
  Future<void> createAppointment(Map<String, dynamic> data) async {
    final response = await _http.post(ApiEndpoints.appointments, body: data);
    final json = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(json['message'] ?? 'Failed to create appointment');
    }

    await fetchAppointments();
  }

  /// Update appointment
  Future<void> updateAppointment(String id, Map<String, dynamic> data) async {
    final response = await _http.put(
      '${ApiEndpoints.appointments}/$id',
      body: data,
    );
    final json = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(json['message'] ?? 'Failed to update appointment');
    }

    await fetchAppointments();
  }

  /// Delete appointment
  Future<void> deleteAppointment(String id) async {
    final response = await _http.delete('${ApiEndpoints.appointments}/$id');

    if (response.statusCode != 200) {
      final json = jsonDecode(response.body);
      throw Exception(json['message'] ?? 'Failed to delete appointment');
    }

    await fetchAppointments();
  }

  /// Mark appointment as completed
  Future<void> markAsCompleted(String id) async {
    await updateAppointment(id, {'is_completed': true});
  }
}
```

---

## Consultation Service

### Location: `lib/provider/consultation_service.dart`

Handles live consultation operations.

```dart
class ConsultationService extends GetxController {
  final HttpClient _http = HttpClient();

  /// Get consultations with filters
  Future<List<LiveConsultation>> getConsultations({
    String? status,
    String? doctorId,
    String? patientId,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int perPage = 12,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    if (status?.isNotEmpty ?? false) queryParams['status'] = status!;
    if (doctorId?.isNotEmpty ?? false) queryParams['doctor_id'] = doctorId!;
    if (patientId?.isNotEmpty ?? false) queryParams['patient_id'] = patientId!;
    if (dateFrom?.isNotEmpty ?? false) queryParams['date_from'] = dateFrom!;
    if (dateTo?.isNotEmpty ?? false) queryParams['date_to'] = dateTo!;

    final url = Uri.parse(ApiEndpoints.liveConsultations)
        .replace(queryParameters: queryParams);

    final response = await _http.get(url.toString());
    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return (json['data']['data'] as List)
          .map((c) => LiveConsultation.fromJson(c))
          .toList();
    } else {
      throw Exception(json['message'] ?? 'Failed to load consultations');
    }
  }

  /// Get single consultation
  Future<LiveConsultation> getConsultationById(String id) async {
    final response = await _http.get('${ApiEndpoints.liveConsultations}/$id');
    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return LiveConsultation.fromJson(json['data']);
    } else {
      throw Exception(json['message'] ?? 'Failed to load consultation');
    }
  }

  /// Create consultation
  Future<LiveConsultation> createConsultation(Map<String, dynamic> data) async {
    final response = await _http.post(ApiEndpoints.liveConsultations, body: data);
    final json = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return LiveConsultation.fromJson(json['data']);
    } else {
      throw Exception(json['message'] ?? 'Failed to create consultation');
    }
  }

  /// Join consultation
  Future<Map<String, dynamic>> joinConsultation(String id) async {
    final response = await _http.post(
      '${ApiEndpoints.liveConsultations}/$id/join',
    );
    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return json['data'];
    } else {
      throw Exception(json['message'] ?? 'Failed to join consultation');
    }
  }

  /// Start consultation (doctor only)
  Future<Map<String, dynamic>> startConsultation(String id) async {
    final response = await _http.post(
      '${ApiEndpoints.liveConsultations}/$id/start',
    );
    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return json['data'];
    } else {
      throw Exception(json['message'] ?? 'Failed to start consultation');
    }
  }

  /// End consultation (doctor only)
  Future<void> endConsultation(String id) async {
    final response = await _http.post(
      '${ApiEndpoints.liveConsultations}/$id/end',
    );

    if (response.statusCode != 200) {
      final json = jsonDecode(response.body);
      throw Exception(json['message'] ?? 'Failed to end consultation');
    }
  }

  /// Get consultation statistics
  Future<ConsultationStatistics> getStatistics() async {
    final response = await _http.get(
      '${ApiEndpoints.liveConsultations}/statistics',
    );
    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return ConsultationStatistics.fromJson(json['data']);
    } else {
      throw Exception(json['message'] ?? 'Failed to load statistics');
    }
  }
}
```

---

## Vital Signs Service

### Location: `lib/provider/vital_signs_service.dart`

Handles patient vital signs tracking.

```dart
class VitalSignsService extends GetxController {
  final HttpClient _http = HttpClient();

  /// Get patient's vital signs
  Future<Map<String, dynamic>> getPatientVitalSigns(
    String patientId, {
    int page = 1,
    int perPage = 12,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    final url = Uri.parse(
      '${ApiEndpoints.patients}/$patientId/vital-signs/staff',
    ).replace(queryParameters: queryParams);

    final response = await _http.get(url.toString());
    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final data = json['data'];
      return {
        'vital_signs': (data['data'] as List)
            .map((v) => VitalSignModel.fromJson(v))
            .toList(),
        'total': data['total'] ?? 0,
        'per_page': data['per_page'] ?? perPage,
        'current_page': data['current_page'] ?? page,
        'last_page': data['last_page'] ?? 1,
      };
    } else {
      throw Exception(json['message'] ?? 'Failed to load vital signs');
    }
  }

  /// Create vital signs record
  Future<VitalSignModel> createVitalSigns(Map<String, dynamic> data) async {
    final response = await _http.post(ApiEndpoints.vitalSigns, body: data);
    final json = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return VitalSignModel.fromJson(json['data']);
    } else {
      throw Exception(json['message'] ?? 'Failed to record vital signs');
    }
  }

  /// Update vital signs record
  Future<VitalSignModel> updateVitalSigns(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _http.put(
      '${ApiEndpoints.vitalSigns}/$id',
      body: data,
    );
    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return VitalSignModel.fromJson(json['data']);
    } else {
      throw Exception(json['message'] ?? 'Failed to update vital signs');
    }
  }

  /// Delete vital signs record
  Future<void> deleteVitalSigns(String id) async {
    final response = await _http.delete('${ApiEndpoints.vitalSigns}/$id');

    if (response.statusCode != 200) {
      final json = jsonDecode(response.body);
      throw Exception(json['message'] ?? 'Failed to delete vital signs');
    }
  }
}
```

---

## Dashboard Service

### Location: `lib/provider/dashboard_service.dart`

Provides dashboard statistics.

```dart
class DashboardService extends GetxController implements GetxService {
  final HttpClient _http = HttpClient();

  // Reactive state
  var doctorCount = 0.obs;
  var patientCount = 0.obs;
  var receptionistCount = 0.obs;
  var adminCount = 0.obs;
  var recentAppointments = <AppointmentData>[].obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  /// Initialize service
  Future<DashboardService> init() async {
    await fetchDashboardData();
    return this;
  }

  /// Fetch dashboard data
  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final response = await _http.post(ApiEndpoints.adminDashboard);
      final json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final data = json['data'];
        doctorCount.value = data['doctor_count'] ?? 0;
        patientCount.value = data['patient_count'] ?? 0;
        receptionistCount.value = data['receptionist_count'] ?? 0;
        adminCount.value = data['admin_count'] ?? 0;

        recentAppointments.value = (data['recent_appointments'] as List?)
            ?.map((a) => AppointmentData.fromJson(a))
            .toList() ?? [];
      } else {
        hasError.value = true;
        errorMessage.value = json['message'] ?? 'Failed to load dashboard';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
```

---

## Accounting Service

### Location: `lib/provider/accounting_service.dart`

Handles all accounting operations.

```dart
class AccountingService extends GetxController {
  final HttpClient _http = HttpClient();

  // === ACCOUNTS ===

  Future<List<Account>> getAccounts({
    String? status,
    String? type,
  }) async {
    final queryParams = <String, String>{};
    if (status?.isNotEmpty ?? false) queryParams['status'] = status!;
    if (type?.isNotEmpty ?? false) queryParams['type'] = type!;

    final url = Uri.parse(ApiEndpoints.accountingAccounts)
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await _http.get(url.toString());
    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return (json['data']['data'] as List)
          .map((a) => Account.fromJson(a))
          .toList();
    }
    throw Exception(json['message'] ?? 'Failed to load accounts');
  }

  Future<Account> createAccount(Map<String, dynamic> data) async {
    final response = await _http.post(
      ApiEndpoints.accountingAccounts,
      body: data,
    );
    final json = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Account.fromJson(json['data']);
    }
    throw Exception(json['message'] ?? 'Failed to create account');
  }

  Future<void> toggleAccountStatus(String id) async {
    final response = await _http.patch(
      '${ApiEndpoints.accountingAccounts}/$id/toggle-status',
    );

    if (response.statusCode != 200) {
      final json = jsonDecode(response.body);
      throw Exception(json['message'] ?? 'Failed to toggle status');
    }
  }

  // === PAYMENTS ===

  Future<List<Payment>> getPayments({
    String? accountId,
    String? dateFrom,
    String? dateTo,
  }) async {
    final queryParams = <String, String>{};
    if (accountId?.isNotEmpty ?? false) queryParams['account_id'] = accountId!;
    if (dateFrom?.isNotEmpty ?? false) queryParams['date_from'] = dateFrom!;
    if (dateTo?.isNotEmpty ?? false) queryParams['date_to'] = dateTo!;

    final url = Uri.parse(ApiEndpoints.accountingPayments)
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await _http.get(url.toString());
    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return (json['data']['data'] as List)
          .map((p) => Payment.fromJson(p))
          .toList();
    }
    throw Exception(json['message'] ?? 'Failed to load payments');
  }

  Future<Payment> createPayment(Map<String, dynamic> data) async {
    final response = await _http.post(
      ApiEndpoints.accountingPayments,
      body: data,
    );
    final json = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Payment.fromJson(json['data']);
    }
    throw Exception(json['message'] ?? 'Failed to record payment');
  }

  // === BILLS ===

  Future<List<Bill>> getBills({
    String? status,
    String? patientId,
  }) async {
    final queryParams = <String, String>{};
    if (status?.isNotEmpty ?? false) queryParams['status'] = status!;
    if (patientId?.isNotEmpty ?? false) queryParams['patient_id'] = patientId!;

    final url = Uri.parse(ApiEndpoints.accountingBills)
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await _http.get(url.toString());
    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return (json['data']['data'] as List)
          .map((b) => Bill.fromJson(b))
          .toList();
    }
    throw Exception(json['message'] ?? 'Failed to load bills');
  }

  Future<void> updateBillStatus(String id, String status) async {
    final response = await _http.patch(
      '${ApiEndpoints.accountingBills}/$id/status',
      body: {'status': status},
    );

    if (response.statusCode != 200) {
      final json = jsonDecode(response.body);
      throw Exception(json['message'] ?? 'Failed to update bill status');
    }
  }

  // === DASHBOARD ===

  Future<Map<String, dynamic>> getAccountingDashboard() async {
    final response = await _http.get(ApiEndpoints.accountingDashboard);
    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return json['data'];
    }
    throw Exception(json['message'] ?? 'Failed to load dashboard');
  }
}
```

---

## Permission Service

### Location: `lib/provider/permission_service.dart`

Handles RBAC permission checks.

```dart
class PermissionService extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  /// Get current user role
  String get currentUserRole {
    final userType = _authService.currentUser.value?.userType ?? '';
    return UserRoles.normalizeRole(userType);
  }

  /// Get current user ID
  String get currentUserId {
    return _authService.currentUser.value?.id ?? '';
  }

  /// Check single permission
  bool hasPermission(String permission) {
    return RolePermissions.hasPermission(currentUserRole, permission);
  }

  /// Check any of permissions
  bool hasAnyPermission(List<String> permissions) {
    return RolePermissions.hasAnyPermission(currentUserRole, permissions);
  }

  /// Check all permissions
  bool hasAllPermissions(List<String> permissions) {
    return RolePermissions.hasAllPermissions(currentUserRole, permissions);
  }

  /// Check page access
  bool canAccessPage(String pageKey) {
    switch (pageKey) {
      case '':
      case 'overview':
        return hasPermission(Permissions.viewDashboard);
      case 'patients':
        return hasAnyPermission([
          Permissions.viewPatients,
          Permissions.viewOwnProfile,
        ]);
      case 'appointments':
        return hasAnyPermission([
          Permissions.viewAppointments,
          Permissions.viewOwnAppointments,
        ]);
      // ... other pages
      default:
        return false;
    }
  }

  // Role checks
  bool get isAdmin => currentUserRole == UserRoles.admin;
  bool get isDoctor => currentUserRole == UserRoles.doctor;
  bool get isReceptionist => currentUserRole == UserRoles.receptionist;
  bool get isPatient => currentUserRole == UserRoles.patient;
}
```

---

## Best Practices

### 1. Error Handling

```dart
Future<void> someServiceMethod() async {
  try {
    final response = await _http.get(url);
    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Success handling
    } else {
      throw Exception(json['message'] ?? 'Operation failed');
    }
  } catch (e) {
    Get.log('Error in someServiceMethod: $e');
    rethrow; // Let controller handle
  }
}
```

### 2. Response Parsing

```dart
// Parse with null safety
final data = json['data'];
final list = (data['items'] as List?)
    ?.map((item) => Model.fromJson(item))
    .toList() ?? [];
```

### 3. Query Parameters

```dart
// Build query params conditionally
final params = <String, String>{};
if (filter != null && filter.isNotEmpty) {
  params['filter'] = filter;
}

final url = Uri.parse(baseUrl).replace(
  queryParameters: params.isEmpty ? null : params,
);
```
