import 'package:flutter/material.dart';

class PatientModel {
  final String id;
  final String patientUniqueId;
  final String customField;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic> user;
  final Map<String, dynamic>? address;
  final Map<String, dynamic>? template;
  final Map<String, dynamic> stats;
  final List<dynamic> appointments;
  final List<dynamic> documents;

  PatientModel({
    required this.id,
    required this.patientUniqueId,
    required this.customField,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    this.address,
    this.template,
    required this.stats,
    required this.appointments,
    required this.documents,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] ?? '',
      patientUniqueId: json['patient_unique_id'] ?? '',
      customField: json['custom_field'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      user: json['user'] ?? {},
      address: json['address'],
      template: json['template'],
      stats: json['stats'] ?? {},
      appointments: json['appointments'] ?? [],
      documents: json['documents'] ?? [],
    );
  }
}