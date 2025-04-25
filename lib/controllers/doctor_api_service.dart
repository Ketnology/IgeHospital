import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'doctor_controller.dart';

class DoctorApiService {
  // Base URL for the API - replace with your actual API endpoint
  static const String baseUrl = "https://api.healthcentre.ng/api";
  static const String doctorEndpoint = "$baseUrl/doctor";

  // Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ${_getToken()}', // Implement token retrieval method
  };

  // Get auth token - implement your own token retrieval mechanism
  String _getToken() {
    // For demo purposes - replace with your actual auth token retrieval
    // e.g., Get.find<AuthController>().token
    return "your_auth_token_here";
  }

  // Get all doctors
  Future<List<Doctor>> getAllDoctors() async {
    try {
      final response = await http.get(
        Uri.parse(doctorEndpoint),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 200) {
          final doctorsList = data['data']['doctors'] as List;
          return doctorsList.map((json) => _doctorFromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch doctors');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch doctors: $e');
    }
  }

  // Get doctor details by ID
  Future<Doctor> getDoctorById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$doctorEndpoint/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 200) {
          return _doctorFromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to get doctor details');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get doctor details: $e');
    }
  }

  // Create a new doctor
  Future<Doctor> createDoctor(Map<String, dynamic> doctorData) async {
    try {
      final response = await http.post(
        Uri.parse(doctorEndpoint),
        headers: _headers,
        body: jsonEncode(doctorData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['status'] == 200 || data['status'] == 201) {
          return _doctorFromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to create doctor');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create doctor: $e');
    }
  }

  // Update an existing doctor
  Future<Doctor> updateDoctor(String id, Map<String, dynamic> doctorData) async {
    try {
      final response = await http.put(
        Uri.parse('$doctorEndpoint/$id'),
        headers: _headers,
        body: jsonEncode(doctorData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 200) {
          return _doctorFromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to update doctor');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update doctor: $e');
    }
  }

  // Delete a doctor
  Future<bool> deleteDoctor(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$doctorEndpoint/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 200) {
          return true;
        } else {
          throw Exception(data['message'] ?? 'Failed to delete doctor');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete doctor: $e');
    }
  }

  // Helper method to convert API response to Doctor model
  Doctor _doctorFromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    final department = json['department'] ?? {};

    return Doctor(
      id: json['id'] ?? '',
      firstName: user['first_name'] ?? '',
      lastName: user['last_name'] ?? '',
      email: user['email'] ?? '',
      phone: user['phone'] ?? '',
      gender: user['gender'] ?? '',
      department: department['title'] ?? '',
      specialty: json['specialist'] ?? '',
      status: user['status'] ?? 'active',
      profileImage: user['profile_image'] ?? '',
      qualification: user['qualification'] ?? '',
      description: json['description'] ?? '',
      bloodGroup: user['blood_group'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  // Helper method to convert Doctor model to API request format
  Map<String, dynamic> _doctorToJson(Doctor doctor) {
    return {
      'first_name': doctor.firstName,
      'last_name': doctor.lastName,
      'email': doctor.email,
      'phone': doctor.phone,
      'gender': doctor.gender,
      'doctor_department_id': doctor.department, // This might need adjustment based on your API
      'specialist': doctor.specialty,
      'description': doctor.description,
      'qualification': doctor.qualification,
      'blood_group': doctor.bloodGroup,
      'status': doctor.status,
    };
  }
}