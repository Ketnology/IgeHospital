import 'package:flutter/material.dart';

class DoctorStats {
  final int appointmentsCount;
  final int schedulesCount;

  DoctorStats({
    this.appointmentsCount = 0,
    this.schedulesCount = 0,
  });

  factory DoctorStats.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DoctorStats();

    return DoctorStats(
      appointmentsCount: int.tryParse(json['appointments_count']?.toString() ?? '0') ?? 0,
      schedulesCount: int.tryParse(json['schedules_count']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'appointments_count': appointmentsCount,
    'schedules_count': schedulesCount,
  };
}

class AppointmentShort {
  final String id;
  final String patientName;
  final String date;
  final String time;
  final String problem;
  final bool isCompleted;

  AppointmentShort({
    required this.id,
    required this.patientName,
    required this.date,
    required this.time,
    required this.problem,
    required this.isCompleted,
  });

  factory AppointmentShort.fromJson(Map<String, dynamic> json) {
    return AppointmentShort(
      id: json['id'] ?? '',
      patientName: json['patient_name'] ?? 'Unknown Patient',
      date: json['appointment_date'] ?? json['date'] ?? 'No date',
      time: json['appointment_time'] ?? json['time'] ?? 'No time',
      problem: json['problem'] ?? '',
      isCompleted: json['is_completed'] == true,
    );
  }
}

class ScheduleDay {
  final String day;
  final String timeFrom;
  final String timeTo;

  ScheduleDay({
    required this.day,
    required this.timeFrom,
    required this.timeTo,
  });

  factory ScheduleDay.fromJson(Map<String, dynamic> json) {
    return ScheduleDay(
      day: json['available_on'] ?? '',
      timeFrom: json['available_from'] ?? '',
      timeTo: json['available_to'] ?? '',
    );
  }
}

class Schedule {
  final String id;
  final String perPatientTime;
  final List<ScheduleDay> days;

  Schedule({
    required this.id,
    required this.perPatientTime,
    required this.days,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    List<ScheduleDay> scheduleDays = [];
    if (json['schedule_days'] != null && json['schedule_days'] is List) {
      scheduleDays = (json['schedule_days'] as List)
          .map((day) => ScheduleDay.fromJson(day))
          .toList();
    }

    return Schedule(
      id: json['id'] ?? '',
      perPatientTime: json['per_patient_time'] ?? '',
      days: scheduleDays,
    );
  }
}

class Doctora {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String gender;
  final String department;
  final String departmentId;
  final String specialty;
  final String status;
  final String profileImage;
  final String qualification;
  final String description;
  final String bloodGroup;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic> user;
  final Map<String, dynamic> departmentData;
  final DoctorStats stats;
  final List<AppointmentShort> appointments;
  final List<Schedule> schedules;

  Doctora({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.department,
    required this.departmentId,
    required this.specialty,
    required this.status,
    required this.profileImage,
    required this.qualification,
    required this.description,
    required this.bloodGroup,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.departmentData,
    required this.stats,
    required this.appointments,
    required this.schedules,
  });

  String get fullName => "$firstName $lastName";

  factory Doctora.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    final department = json['department'] ?? {};

    // Parse appointments
    List<AppointmentShort> appointmentsList = [];
    if (json['appointments'] != null && json['appointments'] is List) {
      appointmentsList = (json['appointments'] as List)
          .map((app) => AppointmentShort.fromJson(app))
          .toList();
    }

    // Parse schedules
    List<Schedule> schedulesList = [];
    if (json['schedules'] != null && json['schedules'] is List) {
      schedulesList = (json['schedules'] as List)
          .map((schedule) => Schedule.fromJson(schedule))
          .toList();
    }

    return Doctora(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      firstName: user['first_name'] ?? '',
      lastName: user['last_name'] ?? '',
      email: user['email'] ?? '',
      phone: user['phone'] ?? '',
      gender: user['gender'] ?? '',
      department: department['title'] ?? '',
      departmentId: json['department_id'] ?? '',
      specialty: json['specialist'] ?? '',
      status: user['status'] ?? 'active',
      profileImage: user['profile_image'] ?? '',
      qualification: user['qualification'] ?? '',
      description: json['description'] ?? '',
      bloodGroup: user['blood_group'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      user: user,
      departmentData: department,
      stats: DoctorStats.fromJson(json['stats']),
      appointments: appointmentsList,
      schedules: schedulesList,
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "phone": phone,
      "gender": gender,
      "doctor_department_id": departmentId,
      "specialist": specialty,
      "qualification": qualification,
      "description": description,
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