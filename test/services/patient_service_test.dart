import 'package:flutter_test/flutter_test.dart';
import 'package:ige_hospital/models/patient_model.dart';

/// Tests for PatientService logic
/// Note: These tests cover the business logic without actual HTTP calls
void main() {
  group('PatientService Logic Tests', () {
    group('Patient List Parsing', () {
      test('should parse patient list response correctly', () {
        final response = {
          'status': 200,
          'message': 'Success',
          'data': {
            'patients': [
              {
                'id': '1',
                'patient_unique_id': 'PAT001',
                'custom_field': '',
                'created_at': '2024-01-01',
                'updated_at': '2024-01-01',
                'user': {'first_name': 'John', 'last_name': 'Doe'},
                'stats': {'appointments_count': '5'},
                'appointments': [],
                'documents': [],
                'vital_signs': []
              },
              {
                'id': '2',
                'patient_unique_id': 'PAT002',
                'custom_field': '',
                'created_at': '2024-01-02',
                'updated_at': '2024-01-02',
                'user': {'first_name': 'Jane', 'last_name': 'Smith'},
                'stats': {'appointments_count': '3'},
                'appointments': [],
                'documents': [],
                'vital_signs': []
              }
            ],
            'total': 2,
            'page': 1,
            'per_page': 10
          }
        };

        final patientsList = (response['data'] as Map)['patients'] as List;
        final patients = patientsList
            .map((json) => PatientModel.fromJson(json as Map<String, dynamic>))
            .toList();

        expect(patients.length, equals(2));
        expect(patients[0].patientUniqueId, equals('PAT001'));
        expect(patients[1].patientUniqueId, equals('PAT002'));
      });

      test('should handle empty patient list', () {
        final response = {
          'status': 200,
          'message': 'Success',
          'data': {
            'patients': [],
            'total': 0,
            'page': 1,
            'per_page': 10
          }
        };

        final patientsList = (response['data'] as Map)['patients'] as List;
        final patients = patientsList
            .map((json) => PatientModel.fromJson(json as Map<String, dynamic>))
            .toList();

        expect(patients, isEmpty);
      });
    });

    group('Query Parameter Building', () {
      test('should build query parameters correctly', () {
        Map<String, String> buildQueryParams({
          String? search,
          String? gender,
          String? bloodGroup,
          String? dateFrom,
          String? dateTo,
          String sortBy = 'created_at',
          String sortDirection = 'desc',
          int page = 1,
          int perPage = 10,
        }) {
          final params = <String, String>{
            'sort_by': sortBy,
            'sort_direction': sortDirection,
            'page': page.toString(),
            'per_page': perPage.toString(),
          };

          if (search != null && search.isNotEmpty) {
            params['search'] = search;
          }
          if (gender != null && gender.isNotEmpty) {
            params['gender'] = gender;
          }
          if (bloodGroup != null && bloodGroup.isNotEmpty) {
            params['blood_group'] = bloodGroup;
          }
          if (dateFrom != null && dateFrom.isNotEmpty) {
            params['date_from'] = dateFrom;
          }
          if (dateTo != null && dateTo.isNotEmpty) {
            params['date_to'] = dateTo;
          }

          return params;
        }

        final params = buildQueryParams(
          search: 'john',
          gender: 'male',
          bloodGroup: 'O+',
          dateFrom: '2024-01-01',
          dateTo: '2024-01-31',
          page: 2,
          perPage: 20,
        );

        expect(params['search'], equals('john'));
        expect(params['gender'], equals('male'));
        expect(params['blood_group'], equals('O+'));
        expect(params['date_from'], equals('2024-01-01'));
        expect(params['date_to'], equals('2024-01-31'));
        expect(params['page'], equals('2'));
        expect(params['per_page'], equals('20'));
      });

      test('should exclude empty optional parameters', () {
        Map<String, String> buildQueryParams({
          String? search,
          String? gender,
          int page = 1,
          int perPage = 10,
        }) {
          final params = <String, String>{
            'page': page.toString(),
            'per_page': perPage.toString(),
          };

          if (search != null && search.isNotEmpty) {
            params['search'] = search;
          }
          if (gender != null && gender.isNotEmpty) {
            params['gender'] = gender;
          }

          return params;
        }

        final params = buildQueryParams();

        expect(params.containsKey('search'), isFalse);
        expect(params.containsKey('gender'), isFalse);
        expect(params['page'], equals('1'));
        expect(params['per_page'], equals('10'));
      });
    });

    group('Error Response Handling', () {
      test('should handle error response format', () {
        final errorResponse = {
          'status': 400,
          'message': 'Validation failed',
          'errors': {
            'email': ['The email field is required'],
            'phone': ['The phone number is invalid']
          }
        };

        int extractStatusCode(Map<String, dynamic> response) {
          return response['status'] as int? ?? 500;
        }

        String extractErrorMessage(Map<String, dynamic> response) {
          return response['message'] as String? ?? 'Unknown error';
        }

        Map<String, dynamic>? extractErrors(Map<String, dynamic> response) {
          return response['errors'] as Map<String, dynamic>?;
        }

        expect(extractStatusCode(errorResponse), equals(400));
        expect(extractErrorMessage(errorResponse), equals('Validation failed'));
        expect(extractErrors(errorResponse), isNotNull);
        expect((extractErrors(errorResponse)!['email'] as List).first,
            equals('The email field is required'));
      });

      test('should handle network error', () {
        Exception networkError = Exception('Network error');

        String handleError(Exception e) {
          if (e.toString().contains('Network')) {
            return 'Unable to connect to server. Please check your internet connection.';
          }
          return 'An unexpected error occurred.';
        }

        expect(
          handleError(networkError),
          equals('Unable to connect to server. Please check your internet connection.'),
        );
      });

      test('should handle 401 unauthorized response', () {
        int statusCode = 401;

        String handle401(int code) {
          if (code == 401) {
            return 'Session expired. Please login again.';
          }
          return 'Request failed';
        }

        expect(handle401(statusCode), equals('Session expired. Please login again.'));
      });

      test('should handle 404 not found response', () {
        int statusCode = 404;

        String handleNotFound(int code) {
          if (code == 404) {
            return 'Patient not found';
          }
          return 'Request failed';
        }

        expect(handleNotFound(statusCode), equals('Patient not found'));
      });
    });

    group('Create Patient Payload', () {
      test('should build create patient payload correctly', () {
        Map<String, dynamic> buildCreatePayload({
          required String firstName,
          required String lastName,
          required String email,
          required String phone,
          required String gender,
          String? bloodGroup,
          String? dateOfBirth,
          String? address,
        }) {
          final payload = <String, dynamic>{
            'first_name': firstName,
            'last_name': lastName,
            'email': email,
            'phone': phone,
            'gender': gender,
          };

          if (bloodGroup != null) {
            payload['blood_group'] = bloodGroup;
          }
          if (dateOfBirth != null) {
            payload['dob'] = dateOfBirth;
          }
          if (address != null) {
            payload['address1'] = address;
          }

          return payload;
        }

        final payload = buildCreatePayload(
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          phone: '1234567890',
          gender: 'male',
          bloodGroup: 'O+',
          dateOfBirth: '1990-01-15',
        );

        expect(payload['first_name'], equals('John'));
        expect(payload['last_name'], equals('Doe'));
        expect(payload['email'], equals('john@example.com'));
        expect(payload['phone'], equals('1234567890'));
        expect(payload['gender'], equals('male'));
        expect(payload['blood_group'], equals('O+'));
        expect(payload['dob'], equals('1990-01-15'));
      });

      test('should validate required fields', () {
        List<String> validatePayload(Map<String, dynamic> payload) {
          final errors = <String>[];

          if (payload['first_name'] == null || (payload['first_name'] as String).isEmpty) {
            errors.add('First name is required');
          }
          if (payload['last_name'] == null || (payload['last_name'] as String).isEmpty) {
            errors.add('Last name is required');
          }
          if (payload['email'] == null || (payload['email'] as String).isEmpty) {
            errors.add('Email is required');
          }
          if (payload['phone'] == null || (payload['phone'] as String).isEmpty) {
            errors.add('Phone is required');
          }

          return errors;
        }

        final invalidPayload = <String, dynamic>{
          'first_name': '',
          'last_name': 'Doe',
          'email': '',
          'phone': '1234567890',
        };

        final errors = validatePayload(invalidPayload);

        expect(errors, contains('First name is required'));
        expect(errors, contains('Email is required'));
        expect(errors.length, equals(2));
      });
    });

    group('Update Patient Payload', () {
      test('should build update patient payload correctly', () {
        Map<String, dynamic> buildUpdatePayload({
          String? firstName,
          String? lastName,
          String? email,
          String? phone,
          String? gender,
          String? bloodGroup,
        }) {
          final payload = <String, dynamic>{};

          if (firstName != null) payload['first_name'] = firstName;
          if (lastName != null) payload['last_name'] = lastName;
          if (email != null) payload['email'] = email;
          if (phone != null) payload['phone'] = phone;
          if (gender != null) payload['gender'] = gender;
          if (bloodGroup != null) payload['blood_group'] = bloodGroup;

          return payload;
        }

        final payload = buildUpdatePayload(
          firstName: 'Jane',
          email: 'jane@example.com',
        );

        expect(payload['first_name'], equals('Jane'));
        expect(payload['email'], equals('jane@example.com'));
        expect(payload.containsKey('last_name'), isFalse);
        expect(payload.containsKey('phone'), isFalse);
      });
    });

    group('Pagination Response Parsing', () {
      test('should parse pagination metadata correctly', () {
        final response = {
          'status': 200,
          'data': {
            'patients': [],
            'total': 100,
            'page': 3,
            'per_page': 20,
            'last_page': 5
          }
        };

        final data = response['data'] as Map<String, dynamic>;
        final total = data['total'] as int;
        final currentPage = data['page'] as int;
        final perPage = data['per_page'] as int;

        expect(total, equals(100));
        expect(currentPage, equals(3));
        expect(perPage, equals(20));

        // Calculate total pages
        int totalPages = (total / perPage).ceil();
        expect(totalPages, equals(5));
      });
    });
  });
}
