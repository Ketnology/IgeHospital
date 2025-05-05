import 'package:flutter/material.dart';

class Nurse {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String gender;
  final String status;
  final String profileImage;
  final String qualification;
  final String bloodGroup;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic> user;

  Nurse({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.status,
    required this.profileImage,
    required this.qualification,
    required this.bloodGroup,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  String get fullName => "$firstName $lastName";

  factory Nurse.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};

    return Nurse(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      firstName: user['first_name'] ?? '',
      lastName: user['last_name'] ?? '',
      email: user['email'] ?? '',
      phone: user['phone'] ?? '',
      gender: user['gender'] ?? '',
      status: user['status'] ?? 'active',
      profileImage: user['profile_image'] ?? '',
      qualification: user['qualification'] ?? '',
      bloodGroup: user['blood_group'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      user: user,
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "phone": phone,
      "gender": gender,
      "qualification": qualification,
      "status": status,
      "blood_group": bloodGroup,
    };
  }

  static Color getStatusColor(String status) {
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
}
