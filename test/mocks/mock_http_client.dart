import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Mock HTTP client for testing API calls
class MockHttpClientFactory {
  /// Creates a mock client that returns successful responses
  static http.Client createSuccessClient(Map<String, dynamic> responseData) {
    return MockClient((request) async {
      return http.Response(
        jsonEncode(responseData),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
  }

  /// Creates a mock client that returns an error response
  static http.Client createErrorClient(int statusCode, String message) {
    return MockClient((request) async {
      return http.Response(
        jsonEncode({'message': message, 'status': statusCode}),
        statusCode,
        headers: {'content-type': 'application/json'},
      );
    });
  }

  /// Creates a mock client that returns 401 Unauthorized
  static http.Client createUnauthorizedClient() {
    return MockClient((request) async {
      return http.Response(
        jsonEncode({'message': 'Unauthorized', 'status': 401}),
        401,
        headers: {'content-type': 'application/json'},
      );
    });
  }

  /// Creates a mock client that simulates network error
  static http.Client createNetworkErrorClient() {
    return MockClient((request) async {
      throw Exception('Network error');
    });
  }

  /// Creates a mock client with custom request handler
  static http.Client createCustomClient(
      Future<http.Response> Function(http.Request) handler) {
    return MockClient(handler);
  }
}

/// Sample API response data for testing
class MockApiResponses {
  // Dashboard response
  static Map<String, dynamic> dashboardResponse = {
    'status': 200,
    'message': 'Success',
    'data': {
      'doctor_count': 10,
      'patient_count': 100,
      'receptionist_count': 5,
      'admin_count': 2,
      'appointments': [
        {
          'id': '1',
          'doctor': 'Dr. Smith',
          'patient': 'John Doe',
          'date_time': '2024-01-15 10:00:00',
          'status': 'scheduled'
        }
      ]
    }
  };

  // Login response
  static Map<String, dynamic> loginSuccessResponse = {
    'status': 200,
    'message': 'Login successful',
    'data': {
      'token': 'test_token_12345',
      'token_expiration': '2024-12-31 23:59:59',
      'user': {
        'id': '1',
        'name': 'Test User',
        'email': 'test@example.com',
        'phone': '1234567890',
        'designation': 'Doctor',
        'gender': 'male',
        'user_type': 'doctor',
        'profile_image': 'https://example.com/image.png'
      }
    }
  };

  // Patient list response
  static Map<String, dynamic> patientsListResponse = {
    'status': 200,
    'message': 'Success',
    'data': {
      'patients': [
        {
          'id': '1',
          'patient_unique_id': 'PAT001',
          'custom_field': '',
          'created_at': '2024-01-01 00:00:00',
          'updated_at': '2024-01-01 00:00:00',
          'user': {
            'first_name': 'John',
            'last_name': 'Doe',
            'email': 'john@example.com',
            'phone': '1234567890'
          },
          'stats': {'appointments_count': '5', 'documents_count': '2'},
          'appointments': [],
          'documents': [],
          'vital_signs': []
        }
      ],
      'total': 1,
      'page': 1,
      'per_page': 10
    }
  };

  // Single patient response
  static Map<String, dynamic> patientDetailResponse = {
    'status': 200,
    'message': 'Success',
    'data': {
      'id': '1',
      'patient_unique_id': 'PAT001',
      'custom_field': '',
      'created_at': '2024-01-01 00:00:00',
      'updated_at': '2024-01-01 00:00:00',
      'user': {
        'first_name': 'John',
        'last_name': 'Doe',
        'email': 'john@example.com',
        'phone': '1234567890',
        'gender': 'male'
      },
      'address': {'address1': '123 Main St', 'city': 'New York'},
      'stats': {
        'appointments_count': '5',
        'documents_count': '2',
        'vital_signs_count': 10
      },
      'appointments': [],
      'documents': [],
      'vital_signs': [],
      'vital_signs_summary': {
        'total_records': 10,
        'last_recorded': '2024-01-15',
        'blood_pressure': '120/80',
        'heart_rate': '72 bpm',
        'temperature': '36.5°C'
      }
    }
  };

  // Doctor list response
  static Map<String, dynamic> doctorsListResponse = {
    'status': 200,
    'message': 'Success',
    'data': {
      'doctors': [
        {
          'id': '1',
          'user_id': 'u1',
          'department_id': 'd1',
          'specialist': 'Cardiology',
          'description': 'Heart specialist',
          'created_at': '2024-01-01 00:00:00',
          'updated_at': '2024-01-01 00:00:00',
          'user': {
            'first_name': 'Jane',
            'last_name': 'Smith',
            'email': 'jane@example.com',
            'phone': '9876543210',
            'gender': 'female',
            'status': 'active',
            'profile_image': '',
            'qualification': 'MD',
            'blood_group': 'O+'
          },
          'department': {'title': 'Cardiology'},
          'stats': {'appointments_count': '20', 'schedules_count': '5'},
          'appointments': [],
          'schedules': []
        }
      ],
      'total': 1,
      'page': 1,
      'per_page': 10
    }
  };

  // Consultation response
  static Map<String, dynamic> consultationResponse = {
    'status': 200,
    'message': 'Success',
    'data': {
      'id': '1',
      'consultation_title': 'Follow-up Consultation',
      'consultation_date': '2024-01-20T10:00:00.000Z',
      'consultation_duration_minutes': 30,
      'host_video': true,
      'participant_video': true,
      'type': 'video',
      'type_number': '1',
      'created_by': 'doctor',
      'description': 'Regular follow-up',
      'meeting_id': 'meet123',
      'time_zone': 'UTC',
      'password': 'pass123',
      'status': 'scheduled',
      'meta': {},
      'created_at': '2024-01-15T00:00:00.000Z',
      'updated_at': '2024-01-15T00:00:00.000Z',
      'consultation_date_formatted': 'Jan 20, 2024',
      'consultation_time_formatted': '10:00 AM',
      'date_human': 'in 5 days',
      'time_until_consultation': '5 days',
      'end_time': '2024-01-20T10:30:00.000Z',
      'duration_formatted': '30 minutes',
      'status_info': {
        'status': 'scheduled',
        'label': 'Scheduled',
        'color': 'blue',
        'is_active': false,
        'is_upcoming': true,
        'is_past': false
      },
      'doctor': {
        'id': 'd1',
        'name': 'Dr. Smith',
        'email': 'smith@hospital.com',
        'phone': '1234567890',
        'specialist': 'Cardiology',
        'department': 'Heart Care'
      },
      'patient': {
        'id': 'p1',
        'name': 'John Doe',
        'email': 'john@example.com',
        'phone': '9876543210',
        'patient_unique_id': 'PAT001'
      }
    }
  };

  // Vital signs response
  static Map<String, dynamic> vitalSignsResponse = {
    'status': 200,
    'message': 'Success',
    'data': {
      'vital_signs': [
        {
          'id': '1',
          'patient_id': 'p1',
          'blood_pressure': '120/80',
          'systolic_pressure': 120,
          'diastolic_pressure': 80,
          'heart_rate': '72 bpm',
          'temperature': '36.5°C',
          'respiratory_rate': '16 /min',
          'oxygen_saturation': '98%',
          'weight': '70 kg',
          'height': '175 cm',
          'bmi': '22.9',
          'notes': 'Normal vitals',
          'recorded_at': '2024-01-15T10:00:00.000Z',
          'recorded_at_human': 'Today at 10:00 AM',
          'recorded_date': '2024-01-15',
          'recorded_time': '10:00 AM',
          'recorded_by': {'id': 'n1', 'name': 'Nurse Jane', 'type': 'nurse'},
          'patient': {'id': 'p1', 'name': 'John Doe', 'patient_unique_id': 'PAT001'}
        }
      ],
      'total': 1,
      'per_page': 10,
      'current_page': 1,
      'last_page': 1
    }
  };

  // Appointment response
  static Map<String, dynamic> appointmentResponse = {
    'status': 200,
    'message': 'Success',
    'data': {
      'id': '1',
      'patient_id': 'p1',
      'doctor_id': 'd1',
      'department_id': 'dept1',
      'opd_date': '2024-01-20',
      'problem': 'Chest pain',
      'is_completed': false,
      'custom_field': '',
      'appointment_date': '2024-01-20',
      'appointment_time': '10:00',
      'date': 'Jan 20, 2024',
      'time': '10:00 AM',
      'doctor': 'd1',
      'doctor_name': 'Dr. Smith',
      'doctor_image': null,
      'doctor_department': 'Cardiology',
      'patient': 'p1',
      'patient_name': 'John Doe',
      'patient_image': null,
      'created_at': '2024-01-15 00:00:00',
      'updated_at': '2024-01-15 00:00:00'
    }
  };

  // Account response
  static Map<String, dynamic> accountResponse = {
    'status': 200,
    'message': 'Success',
    'data': {
      'accounts': [
        {
          'id': '1',
          'name': 'Operating Account',
          'type': 'operating',
          'description': 'Main operating account',
          'status': 'active',
          'created_at': '2024-01-01 00:00:00',
          'updated_at': '2024-01-01 00:00:00',
          'type_display': 'Operating',
          'status_display': 'Active',
          'is_active': true,
          'total_payments_amount': '5000.00',
          'payments': []
        }
      ]
    }
  };

  // Bill response
  static Map<String, dynamic> billResponse = {
    'status': 200,
    'message': 'Success',
    'data': {
      'bills': [
        {
          'id': '1',
          'reference': 'BILL-001',
          'bill_date': '2024-01-15',
          'amount': '500.00',
          'patient_admission_id': '',
          'status': 'paid',
          'payment_mode': 'cash',
          'created_at': '2024-01-15 00:00:00',
          'updated_at': '2024-01-15 00:00:00',
          'patient': {
            'id': 'p1',
            'patient_unique_id': 'PAT001',
            'full_name': 'John Doe',
            'email': 'john@example.com',
            'phone': '1234567890'
          },
          'bill_items': [
            {
              'id': 'bi1',
              'item_name': 'Consultation',
              'qty': 1,
              'price': '500.00',
              'amount': '500.00',
              'created_at': '2024-01-15 00:00:00',
              'updated_at': '2024-01-15 00:00:00',
              'price_formatted': '\$500.00',
              'amount_formatted': '\$500.00',
              'price_currency': 'USD',
              'amount_currency': 'USD',
              'unit_total': 500.0
            }
          ],
          'bill_date_formatted': 'Jan 15, 2024',
          'amount_formatted': '\$500.00',
          'amount_currency': 'USD',
          'status_display': 'Paid',
          'is_paid': true,
          'is_pending': false,
          'is_overdue': false
        }
      ],
      'total': 1,
      'current_page': 1,
      'last_page': 1,
      'per_page': 10
    }
  };
}
