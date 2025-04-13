import 'dart:convert';
import 'package:get/get.dart';
import 'package:ige_hospital/constants/api_endpoints.dart';
import 'package:ige_hospital/models/patient_model.dart';
import 'package:ige_hospital/utils/http_client.dart';
import 'package:ige_hospital/utils/snack_bar_utils.dart';

class PatientsService extends GetxService {
  final HttpClient _httpClient = HttpClient();

  // Reactive variables
  final RxList<PatientModel> patients = <PatientModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Pagination
  final RxInt totalPatients = 0.obs;
  final RxInt currentPage = 1.obs;
  final RxInt perPage = 1000.obs;

  // Filters
  final RxString searchQuery = ''.obs;
  final RxString selectedGender = ''.obs;
  final RxString selectedBloodGroup = ''.obs;
  final RxString dateFrom = ''.obs;
  final RxString dateTo = ''.obs;
  final RxString sortBy = 'created_at'.obs;
  final RxString sortDirection = 'desc'.obs;

  // Cache of all patients for local operations
  final List<PatientModel> _allPatients = [];

  @override
  void onInit() {
    super.onInit();
    fetchAllPatients();
  }

  // Parse API response safely, handling both array and object responses
  List<dynamic> _safelyParseResponse(dynamic result) {
    try {
      // Case 1: Response is a Map with data.patients field
      if (result is Map<String, dynamic>) {
        if (result['data'] != null && result['data']['patients'] != null) {
          return result['data']['patients'] as List<dynamic>;
        } else if (result['data'] != null && result['data'] is List) {
          return result['data'] as List<dynamic>;
        } else if (result['patients'] != null) {
          return result['patients'] as List<dynamic>;
        }
      }

      // Case 2: Response is a direct array of patients
      if (result is List) {
        return result;
      }

      // Default empty list if no pattern matches
      return [];
    } catch (e) {
      errorMessage.value = 'Error parsing response: $e';
      return [];
    }
  }

  // Fetch all patients once to populate _allPatients (for caching)
  Future<void> fetchAllPatients() async {
    try {
      isLoading.value = true;

      final Map<String, String> queryParams = {
        'per_page': '1000', // Get a larger number of patients
        'sort_by': 'created_at',
        'sort_direction': 'desc',
      };

      final Uri uri = Uri.parse(ApiEndpoints.patientEndpoint).replace(queryParameters: queryParams);

      final dynamic result = await _httpClient.get(uri.toString());

      // Parse the response to get the list of patients
      final patientsList = _safelyParseResponse(result);

      if (patientsList.isNotEmpty) {
        _allPatients.clear();
        _allPatients.addAll(patientsList.map((json) => PatientModel.fromJson(json)).toList());

        // After populating _allPatients, fetch with filters for UI
        fetchPatients();
      } else {
        // Try alternative approach for fetching data
        Get.log("No patients found in main response, trying alternative approach");
        if (result is Map<String, dynamic> && result['status'] == 200) {
          // Look for patients in different locations in the response
          if (result['data'] != null) {
            dynamic dataContent = result['data'];
            if (dataContent is Map && dataContent.containsKey('patients')) {
              final List<dynamic> altPatientsList = dataContent['patients'];
              _allPatients.clear();
              _allPatients.addAll(altPatientsList.map((json) => PatientModel.fromJson(json)).toList());
              fetchPatients();
              return;
            }
          }
        }

        // If we get here, we couldn't find patients data
        hasError.value = true;
        errorMessage.value = 'No patients data found in the response';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to connect to server: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPatients() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      // If we have applied filters, use the API
      if (searchQuery.value.isNotEmpty ||
          selectedGender.value.isNotEmpty ||
          selectedBloodGroup.value.isNotEmpty ||
          dateFrom.value.isNotEmpty ||
          dateTo.value.isNotEmpty) {

        await _fetchPatientsFromApi();
      } else {
        // If no filters, use the local cache with pagination
        _applyLocalPagination();
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error processing patients: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch patients from API with filters
  Future<void> _fetchPatientsFromApi() async {
    try {
      final Map<String, String> queryParams = {
        if (searchQuery.value.isNotEmpty) 'search': searchQuery.value,
        if (selectedGender.value.isNotEmpty) 'gender': selectedGender.value,
        if (selectedBloodGroup.value.isNotEmpty) 'blood_group': selectedBloodGroup.value,
        if (dateFrom.value.isNotEmpty) 'date_from': dateFrom.value,
        if (dateTo.value.isNotEmpty) 'date_to': dateTo.value,
        'sort_by': sortBy.value,
        'sort_direction': sortDirection.value,
        'page': currentPage.value.toString(),
        'per_page': perPage.value.toString(),
      };

      final Uri uri = Uri.parse(ApiEndpoints.patientEndpoint).replace(queryParameters: queryParams);

      final dynamic result = await _httpClient.get(uri.toString());

      // Parse the response
      final patientsList = _safelyParseResponse(result);

      if (patientsList.isNotEmpty) {
        patients.value = patientsList.map((json) => PatientModel.fromJson(json)).toList();

        // Get total count for pagination
        int total = patientsList.length;

        // Try to get total from response if available
        if (result is Map<String, dynamic>) {
          if (result['meta'] != null && result['meta']['total'] != null) {
            total = result['meta']['total'];
          } else if (result['data'] is Map && result['data']['total'] != null) {
            total = result['data']['total'] is int
                ? result['data']['total']
                : int.tryParse(result['data']['total'].toString()) ?? patientsList.length;
          }
        }

        totalPatients.value = total;
      } else {
        patients.value = [];
        if (currentPage.value > 1) {
          currentPage.value = 1;
          fetchPatients();
        }
      }
    } catch (e) {
      throw 'API fetch error: $e';
    }
  }

  // Apply pagination to local cache
  void _applyLocalPagination() {
    try {
      // Apply filtering locally
      var filteredPatients = List<PatientModel>.from(_allPatients);

      // Apply search filter if needed
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        filteredPatients = filteredPatients.where((patient) {
          final name = patient.user['full_name']?.toLowerCase() ?? '';
          final email = patient.user['email']?.toLowerCase() ?? '';
          final phone = patient.user['phone']?.toLowerCase() ?? '';
          final id = patient.patientUniqueId.toLowerCase();
          return name.contains(query) || email.contains(query) || phone.contains(query) || id.contains(query);
        }).toList();
      }

      // Apply gender filter if needed
      if (selectedGender.value.isNotEmpty) {
        filteredPatients = filteredPatients.where((patient) {
          return patient.user['gender']?.toLowerCase() == selectedGender.value.toLowerCase();
        }).toList();
      }

      // Apply blood group filter if needed
      if (selectedBloodGroup.value.isNotEmpty) {
        filteredPatients = filteredPatients.where((patient) {
          return patient.user['blood_group'] == selectedBloodGroup.value;
        }).toList();
      }

      // Apply date filters if needed
      if (dateFrom.value.isNotEmpty && dateTo.value.isNotEmpty) {
        final fromDate = DateTime.parse(dateFrom.value);
        final toDate = DateTime.parse(dateTo.value).add(const Duration(days: 1));

        filteredPatients = filteredPatients.where((patient) {
          if (patient.createdAt.isEmpty) return false;
          final createdDate = DateTime.parse(patient.createdAt);
          return createdDate.isAfter(fromDate) && createdDate.isBefore(toDate);
        }).toList();
      }

      // Apply sorting
      filteredPatients.sort((a, b) {
        int compareResult;

        switch (sortBy.value) {
          case 'created_at':
            compareResult = a.createdAt.compareTo(b.createdAt);
            break;
          case 'first_name':
            compareResult = (a.user['first_name'] ?? '').compareTo(b.user['first_name'] ?? '');
            break;
          case 'last_name':
            compareResult = (a.user['last_name'] ?? '').compareTo(b.user['last_name'] ?? '');
            break;
          case 'email':
            compareResult = (a.user['email'] ?? '').compareTo(b.user['email'] ?? '');
            break;
          case 'patient_unique_id':
            compareResult = a.patientUniqueId.compareTo(b.patientUniqueId);
            break;
          default:
            compareResult = a.createdAt.compareTo(b.createdAt);
        }

        return sortDirection.value == 'asc' ? compareResult : -compareResult;
      });

      // Update total count
      totalPatients.value = filteredPatients.length;

      // Apply pagination
      final startIndex = (currentPage.value - 1) * perPage.value;
      final endIndex = startIndex + perPage.value;

      if (startIndex < filteredPatients.length) {
        final paginatedPatients = filteredPatients.sublist(
            startIndex,
            endIndex > filteredPatients.length ? filteredPatients.length : endIndex
        );
        patients.value = paginatedPatients;
      } else {
        patients.value = [];
        if (currentPage.value > 1) {
          currentPage.value = 1;
          _applyLocalPagination();
        }
      }
    } catch (e) {
      throw 'Local pagination error: $e';
    }
  }

  Future<PatientModel?> getPatientDetails(String id) async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      // First check if we have it in our local cache
      final cachedPatient = _allPatients.firstWhereOrNull((patient) => patient.id == id);
      if (cachedPatient != null) {
        return cachedPatient;
      }

      // If not in cache, fetch from API
      final dynamic result = await _httpClient.get('${ApiEndpoints.patientEndpoint}/$id');

      PatientModel? patient;

      if (result is Map<String, dynamic>) {
        // Try to find patient data in various places in the response
        if (result['data'] != null) {
          patient = PatientModel.fromJson(result['data']);
        } else if (result['patient'] != null) {
          patient = PatientModel.fromJson(result['patient']);
        }
      } else if (result is List && result.isNotEmpty) {
        // In case the API returns a list with one patient
        patient = PatientModel.fromJson(result[0]);
      }

      if (patient != null) {
        // Update cache
        final index = _allPatients.indexWhere((p) => p.id == id);
        if (index != -1) {
          _allPatients[index] = patient;
        } else {
          _allPatients.add(patient);
        }

        return patient;
      } else {
        hasError.value = true;
        errorMessage.value = 'Could not find patient data in the response';
        return null;
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to get patient details: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createPatient(Map<String, dynamic> patientData) async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final dynamic result = await _httpClient.post(
        ApiEndpoints.patientEndpoint,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(patientData),
      );

      bool success = false;
      PatientModel? newPatient;

      if (result is Map<String, dynamic>) {
        // Check various success indicators
        if (result['status'] == 201 || result['status'] == 200) {
          success = true;

          // Try to get patient data from response
          if (result['data'] != null) {
            newPatient = PatientModel.fromJson(result['data']);
          } else if (result['patient'] != null) {
            newPatient = PatientModel.fromJson(result['patient']);
          }
        }
      }

      if (success) {
        // Add to local cache if we have patient data
        if (newPatient != null) {
          final existingIndex = _allPatients.indexWhere((p) => p.id == newPatient!.id);
          if (existingIndex != -1) {
            _allPatients[existingIndex] = newPatient;
          } else {
            _allPatients.add(newPatient);
          }
        } else {
          // If patient data is not returned, refresh the whole cache
          await fetchAllPatients();
        }

        SnackBarUtils.showSuccessSnackBar('Patient created successfully');
        fetchPatients();
      } else {
        // Handle error
        hasError.value = true;
        if (result is Map<String, dynamic> && result['message'] != null) {
          errorMessage.value = result['message'];
        } else {
          errorMessage.value = 'Failed to create patient';
        }
        SnackBarUtils.showErrorSnackBar(errorMessage.value);
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to connect to server: $e';
      SnackBarUtils.showErrorSnackBar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePatient(String id, Map<String, dynamic> patientData) async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final dynamic result = await _httpClient.put(
        '${ApiEndpoints.patientEndpoint}/$id',
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(patientData),
      );

      bool success = false;
      PatientModel? updatedPatient;

      if (result is Map<String, dynamic>) {
        // Check for success
        if (result['status'] == 200 || result['status'] == 201) {
          success = true;

          // Try to extract patient data
          if (result['data'] != null) {
            updatedPatient = PatientModel.fromJson(result['data']);
          } else if (result['patient'] != null) {
            updatedPatient = PatientModel.fromJson(result['patient']);
          }
        }
      }

      if (success) {
        // Update local cache
        if (updatedPatient != null) {
          final index = _allPatients.indexWhere((p) => p.id == id);
          if (index != -1) {
            _allPatients[index] = updatedPatient;
          } else {
            _allPatients.add(updatedPatient);
          }
        } else {
          // Update in-memory cache with partial data
          final index = _allPatients.indexWhere((patient) => patient.id == id);
          if (index != -1) {
            final currentPatient = _allPatients[index];

            // Update user data
            if (patientData['first_name'] != null || patientData['last_name'] != null) {
              final firstName = patientData['first_name'] ?? currentPatient.user['first_name'];
              final lastName = patientData['last_name'] ?? currentPatient.user['last_name'];
              currentPatient.user['first_name'] = firstName;
              currentPatient.user['last_name'] = lastName;
              currentPatient.user['full_name'] = '$firstName $lastName';
            }

            if (patientData['email'] != null) {
              currentPatient.user['email'] = patientData['email'];
            }

            if (patientData['phone'] != null) {
              currentPatient.user['phone'] = patientData['phone'];
            }

            if (patientData['gender'] != null) {
              currentPatient.user['gender'] = patientData['gender'];
            }

            if (patientData['blood_group'] != null) {
              currentPatient.user['blood_group'] = patientData['blood_group'];
            }

            if (patientData['dob'] != null) {
              currentPatient.user['dob'] = patientData['dob'];
            }

            if (patientData['status'] != null) {
              currentPatient.user['status'] = patientData['status'];
            }

            // Update address if provided
            if (patientData['address1'] != null && currentPatient.address != null) {
              currentPatient.address!['address1'] = patientData['address1'];
            }

            // Update updatedAt timestamp
            _allPatients[index] = PatientModel(
              id: currentPatient.id,
              patientUniqueId: currentPatient.patientUniqueId,
              customField: currentPatient.customField,
              createdAt: currentPatient.createdAt,
              updatedAt: DateTime.now().toIso8601String(),
              user: currentPatient.user,
              address: currentPatient.address,
              template: currentPatient.template,
              stats: currentPatient.stats,
              appointments: currentPatient.appointments,
              documents: currentPatient.documents,
            );
          }
        }

        SnackBarUtils.showSuccessSnackBar('Patient updated successfully');
        fetchPatients();
      } else {
        // Handle error
        hasError.value = true;
        if (result is Map<String, dynamic> && result['message'] != null) {
          errorMessage.value = result['message'];
        } else {
          errorMessage.value = 'Failed to update patient';
        }
        SnackBarUtils.showErrorSnackBar(errorMessage.value);
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to connect to server: $e';
      SnackBarUtils.showErrorSnackBar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePatient(String id) async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final dynamic result = await _httpClient.delete(
        '${ApiEndpoints.patientEndpoint}/$id',
      );

      bool success = false;

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200 || result['status'] == 204) {
          success = true;
        }
      }

      if (success) {
        // Remove from local cache
        _allPatients.removeWhere((patient) => patient.id == id);

        SnackBarUtils.showSuccessSnackBar('Patient deleted successfully');
        fetchPatients();
      } else {
        hasError.value = true;
        if (result is Map<String, dynamic> && result['message'] != null) {
          errorMessage.value = result['message'];
        } else {
          errorMessage.value = 'Failed to delete patient';
        }
        SnackBarUtils.showErrorSnackBar(errorMessage.value);
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
    selectedGender.value = '';
    selectedBloodGroup.value = '';
    dateFrom.value = '';
    dateTo.value = '';
    sortBy.value = 'created_at';
    sortDirection.value = 'desc';
    currentPage.value = 1;
    fetchPatients();
  }

  void setPage(int page) {
    if (page < 1) page = 1;
    int maxPage = (totalPatients.value / perPage.value).ceil();
    if (maxPage < 1) maxPage = 1;
    if (page > maxPage) page = maxPage;
    currentPage.value = page;
    fetchPatients();
  }

  void nextPage() {
    int maxPages = (totalPatients.value / perPage.value).ceil();
    if (maxPages < 1) maxPages = 1;
    if (currentPage.value < maxPages) {
      currentPage.value++;
      fetchPatients();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchPatients();
    }
  }
}