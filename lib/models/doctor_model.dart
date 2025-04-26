import 'package:flutter/material.dart';

class DoctorModel {
  final String id;
  final String userId;
  final String departmentId;
  final String specialist;
  final String description;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic> user;
  final Map<String, dynamic> department;
  final List<dynamic> appointments;
  final List<dynamic> schedules;
  final Map<String, dynamic> stats;

  DoctorModel({
    required this.id,
    required this.userId,
    required this.departmentId,
    required this.specialist,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.department,
    required this.appointments,
    required this.schedules,
    required this.stats,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      departmentId: json['department_id'] ?? '',
      specialist: json['specialist'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      user: json['user'] is Map ? Map<String, dynamic>.from(json['user']) : {},
      department: json['department'] is Map ? Map<String, dynamic>.from(json['department']) : {},
      appointments: json['appointments'] is List ? List.from(json['appointments']) : [],
      schedules: json['schedules'] is List ? List.from(json['schedules']) : [],
      stats: json['stats'] is Map ? Map<String, dynamic>.from(json['stats']) : {},
    );
  }

  // Getters for convenience
  String get fullName => "${user['first_name'] ?? ''} ${user['last_name'] ?? ''}";
  String get email => user['email'] ?? '';
  String get phone => user['phone'] ?? '';
  String get gender => user['gender'] ?? '';
  String get bloodGroup => user['blood_group'] ?? '';
  String get qualification => user['qualification'] ?? '';
  String get status => user['status'] ?? '';
  String get profileImage => user['profile_image'] ?? '';
  String get departmentName => department['title'] ?? '';

  // Stats getters
  int get appointmentsCount => int.tryParse(stats['appointments_count']?.toString() ?? '0') ?? 0;
  int get schedulesCount => int.tryParse(stats['schedules_count']?.toString() ?? '0') ?? 0;
}