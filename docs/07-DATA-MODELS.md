# Data Models Documentation

> **Document Version:** 1.0.0
> **Last Updated:** November 2024

## Overview

Data models in IGE Hospital follow a consistent pattern with JSON serialization support. All models are located in `lib/models/` and follow the `*_model.dart` naming convention.

---

## Model Design Patterns

### Standard Model Structure

```dart
class ExampleModel {
  // 1. Properties (final for immutability)
  final String id;
  final String name;
  final DateTime createdAt;

  // 2. Constructor
  const ExampleModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  // 3. Factory constructor for JSON deserialization
  factory ExampleModel.fromJson(Map<String, dynamic> json) {
    return ExampleModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  // 4. Method for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // 5. Optional: copyWith for immutable updates
  ExampleModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return ExampleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

---

## User Model

### Location: `lib/provider/auth_service.dart`

```dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String designation;
  final String gender;
  final String userType;           // Normalized role
  final String? profileImage;
  final Map<String, dynamic>? additionalData;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.designation,
    required this.gender,
    required this.userType,
    this.profileImage,
    this.additionalData,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id']?.toString() ?? '',
      name: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      userType: UserRoles.normalizeRole(json['user_type']?.toString() ?? ''),
      profileImage: json['profile_image'],
      additionalData: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'full_name': name,
      'email': email,
      'phone': phone,
      'designation': designation,
      'gender': gender,
      'user_type': userType,
      'profile_image': profileImage,
      ...?additionalData,
    };
  }
}
```

### Field Mapping

| Model Field | API Field | Notes |
|-------------|-----------|-------|
| `id` | `user_id` | Unique identifier |
| `name` | `full_name` | Display name |
| `userType` | `user_type` | Normalized via `UserRoles.normalizeRole()` |

---

## Patient Model

### Location: `lib/models/patient_model.dart`

```dart
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
  final List<dynamic> vitalSigns;
  final Map<String, dynamic>? vitalSignsSummary;

  const PatientModel({
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
    required this.vitalSigns,
    this.vitalSignsSummary,
  });

  // Convenience getters
  String get name => user['full_name']?.toString() ?? '';
  String get email => user['email']?.toString() ?? '';
  String get phone => user['phone']?.toString() ?? '';
  String get gender => user['gender']?.toString() ?? '';
  String? get profileImage => user['profile_image'];

  // Vital signs helpers
  bool get hasVitalSigns => vitalSigns.isNotEmpty;

  String? get lastVitalSignsDate {
    if (vitalSigns.isEmpty) return null;
    return vitalSigns.first['recorded_at']?.toString();
  }

  String? get latestBloodPressure =>
    vitalSignsSummary?['latest_blood_pressure']?.toString();

  String? get latestHeartRate =>
    vitalSignsSummary?['latest_heart_rate']?.toString();

  String? get latestTemperature =>
    vitalSignsSummary?['latest_temperature']?.toString();

  int get vitalSignsCount => vitalSigns.length;

  // Statistics
  int get appointmentsCount =>
    int.tryParse(stats['appointments_count']?.toString() ?? '0') ?? 0;

  int get documentsCount =>
    int.tryParse(stats['documents_count']?.toString() ?? '0') ?? 0;

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id']?.toString() ?? '',
      patientUniqueId: json['patient_unique_id']?.toString() ?? '',
      customField: json['custom_field']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      user: json['user'] ?? {},
      address: json['address'],
      template: json['template'],
      stats: json['stats'] ?? {},
      appointments: json['appointments'] ?? [],
      documents: json['documents'] ?? [],
      vitalSigns: json['vital_signs'] ?? [],
      vitalSignsSummary: json['vital_signs_summary'],
    );
  }
}
```

### Related Models

```dart
// Address structure (nested in PatientModel)
{
  "street": "123 Main St",
  "city": "New York",
  "state": "NY",
  "country": "USA",
  "zip_code": "10001"
}

// Stats structure (nested in PatientModel)
{
  "appointments_count": 5,
  "documents_count": 3
}

// Vital signs summary (nested in PatientModel)
{
  "latest_blood_pressure": "120/80",
  "latest_heart_rate": "72 bpm",
  "latest_temperature": "37.0°C",
  "latest_recorded_at": "2024-01-20T10:30:00Z"
}
```

---

## Doctor Model

### Location: `lib/models/doctor_model.dart`

```dart
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
  final String status;           // active, blocked, pending
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

  const Doctora({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    // ... other required fields
  });

  // Convenience getters
  String get fullName => '$firstName $lastName';
  bool get isActive => status == 'active';
  bool get isBlocked => status == 'blocked';
  bool get isPending => status == 'pending';

  factory Doctora.fromJson(Map<String, dynamic> json) {
    return Doctora(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      departmentId: json['department_id']?.toString() ?? '',
      specialty: json['specialty']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      profileImage: json['profile_image']?.toString() ?? '',
      qualification: json['qualification']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      bloodGroup: json['blood_group']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      user: json['user'] ?? {},
      departmentData: json['department_data'] ?? {},
      stats: DoctorStats.fromJson(json['stats'] ?? {}),
      appointments: (json['appointments'] as List?)
          ?.map((a) => AppointmentShort.fromJson(a))
          .toList() ?? [],
      schedules: (json['schedules'] as List?)
          ?.map((s) => Schedule.fromJson(s))
          .toList() ?? [],
    );
  }
}

class DoctorStats {
  final int appointmentsCount;
  final int schedulesCount;

  const DoctorStats({
    required this.appointmentsCount,
    required this.schedulesCount,
  });

  factory DoctorStats.fromJson(Map<String, dynamic> json) {
    return DoctorStats(
      appointmentsCount: int.tryParse(json['appointments_count']?.toString() ?? '0') ?? 0,
      schedulesCount: int.tryParse(json['schedules_count']?.toString() ?? '0') ?? 0,
    );
  }
}

class Schedule {
  final String id;
  final String perPatientTime;
  final List<ScheduleDay> days;

  const Schedule({
    required this.id,
    required this.perPatientTime,
    required this.days,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id']?.toString() ?? '',
      perPatientTime: json['per_patient_time']?.toString() ?? '30',
      days: (json['days'] as List?)
          ?.map((d) => ScheduleDay.fromJson(d))
          .toList() ?? [],
    );
  }
}

class ScheduleDay {
  final String day;
  final String timeFrom;
  final String timeTo;

  const ScheduleDay({
    required this.day,
    required this.timeFrom,
    required this.timeTo,
  });

  factory ScheduleDay.fromJson(Map<String, dynamic> json) {
    return ScheduleDay(
      day: json['day']?.toString() ?? '',
      timeFrom: json['time_from']?.toString() ?? '',
      timeTo: json['time_to']?.toString() ?? '',
    );
  }
}
```

---

## Appointment Model

### Location: `lib/models/appointment_model.dart`

```dart
class AppointmentModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String departmentId;
  final String opdDate;
  final String problem;
  final bool isCompleted;
  final String customField;
  final String appointmentDate;
  final String appointmentTime;
  final String date;              // Formatted date
  final String time;              // Formatted time
  final String doctor;            // Doctor ID reference
  final String doctorName;
  final String? doctorImage;
  final String doctorDepartment;
  final String patient;           // Patient ID reference
  final String patientName;
  final String? patientImage;
  final String createdAt;
  final String updatedAt;

  const AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.departmentId,
    required this.opdDate,
    required this.problem,
    required this.isCompleted,
    required this.customField,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.date,
    required this.time,
    required this.doctor,
    required this.doctorName,
    this.doctorImage,
    required this.doctorDepartment,
    required this.patient,
    required this.patientName,
    this.patientImage,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convenience getters
  String get statusText => isCompleted ? 'Completed' : 'Scheduled';

  DateTime? get appointmentDateTime {
    try {
      return DateTime.parse('$appointmentDate $appointmentTime');
    } catch (_) {
      return null;
    }
  }

  bool get isPast {
    final dt = appointmentDateTime;
    if (dt == null) return false;
    return dt.isBefore(DateTime.now());
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? '',
      doctorId: json['doctor_id']?.toString() ?? '',
      departmentId: json['department_id']?.toString() ?? '',
      opdDate: json['opd_date']?.toString() ?? '',
      problem: json['problem']?.toString() ?? '',
      isCompleted: json['is_completed'] == true || json['is_completed'] == 1,
      customField: json['custom_field']?.toString() ?? '',
      appointmentDate: json['appointment_date']?.toString() ?? '',
      appointmentTime: json['appointment_time']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      doctor: json['doctor']?.toString() ?? '',
      doctorName: json['doctor_name']?.toString() ?? '',
      doctorImage: json['doctor_image'],
      doctorDepartment: json['doctor_department']?.toString() ?? '',
      patient: json['patient']?.toString() ?? '',
      patientName: json['patient_name']?.toString() ?? '',
      patientImage: json['patient_image'],
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}
```

---

## Consultation Model

### Location: `lib/models/consultation_model.dart`

```dart
class LiveConsultation {
  final String id;
  final String consultationTitle;
  final DateTime consultationDate;
  final int consultationDurationMinutes;
  final bool hostVideo;
  final bool participantVideo;
  final String type;              // zoom, teams, meet
  final String typeNumber;
  final String createdBy;
  final String? description;
  final String meetingId;
  final String timeZone;
  final String password;
  final String status;            // scheduled, ongoing, completed, cancelled
  final Map<String, dynamic> meta;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ConsultationStatusInfo statusInfo;
  final ConsultationPermissions permissions;
  final ConsultationDoctor doctor;
  final ConsultationPatient patient;
  final ConsultationJoinInfo? joinInfo;
  final DateTime endTime;

  const LiveConsultation({
    required this.id,
    required this.consultationTitle,
    required this.consultationDate,
    required this.consultationDurationMinutes,
    required this.hostVideo,
    required this.participantVideo,
    required this.type,
    required this.typeNumber,
    required this.createdBy,
    this.description,
    required this.meetingId,
    required this.timeZone,
    required this.password,
    required this.status,
    required this.meta,
    required this.createdAt,
    required this.updatedAt,
    required this.statusInfo,
    required this.permissions,
    required this.doctor,
    required this.patient,
    this.joinInfo,
    required this.endTime,
  });

  // Convenience getters
  bool get isScheduled => status == 'scheduled';
  bool get isOngoing => status == 'ongoing';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  bool get canJoin => permissions.canJoin && (joinInfo?.canJoinNow ?? false);
  bool get canStart => permissions.canStart;
  bool get canEnd => permissions.canEnd;

  Duration get duration => Duration(minutes: consultationDurationMinutes);

  factory LiveConsultation.fromJson(Map<String, dynamic> json) {
    return LiveConsultation(
      id: json['id']?.toString() ?? '',
      consultationTitle: json['consultation_title']?.toString() ?? '',
      consultationDate: DateTime.parse(
        json['consultation_date'] ?? DateTime.now().toIso8601String(),
      ),
      consultationDurationMinutes: int.tryParse(
        json['consultation_duration_minutes']?.toString() ?? '30',
      ) ?? 30,
      hostVideo: json['host_video'] == true,
      participantVideo: json['participant_video'] == true,
      type: json['type']?.toString() ?? 'zoom',
      typeNumber: json['type_number']?.toString() ?? '1',
      createdBy: json['created_by']?.toString() ?? '',
      description: json['description'],
      meetingId: json['meeting_id']?.toString() ?? '',
      timeZone: json['time_zone']?.toString() ?? 'UTC',
      password: json['password']?.toString() ?? '',
      status: json['status']?.toString() ?? 'scheduled',
      meta: json['meta'] ?? {},
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      statusInfo: ConsultationStatusInfo.fromJson(json['status_info'] ?? {}),
      permissions: ConsultationPermissions.fromJson(json['permissions'] ?? {}),
      doctor: ConsultationDoctor.fromJson(json['doctor'] ?? {}),
      patient: ConsultationPatient.fromJson(json['patient'] ?? {}),
      joinInfo: json['join_info'] != null
          ? ConsultationJoinInfo.fromJson(json['join_info'])
          : null,
      endTime: DateTime.parse(
        json['end_time'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class ConsultationStatusInfo {
  final String status;
  final String label;
  final String color;
  final bool isActive;
  final bool isUpcoming;
  final bool isPast;

  const ConsultationStatusInfo({
    required this.status,
    required this.label,
    required this.color,
    required this.isActive,
    required this.isUpcoming,
    required this.isPast,
  });

  factory ConsultationStatusInfo.fromJson(Map<String, dynamic> json) {
    return ConsultationStatusInfo(
      status: json['status']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      color: json['color']?.toString() ?? '#000000',
      isActive: json['is_active'] == true,
      isUpcoming: json['is_upcoming'] == true,
      isPast: json['is_past'] == true,
    );
  }
}

class ConsultationPermissions {
  final bool canJoin;
  final bool canStart;
  final bool canEnd;
  final bool canEdit;
  final bool canDelete;

  const ConsultationPermissions({
    required this.canJoin,
    required this.canStart,
    required this.canEnd,
    required this.canEdit,
    required this.canDelete,
  });

  factory ConsultationPermissions.fromJson(Map<String, dynamic> json) {
    return ConsultationPermissions(
      canJoin: json['can_join'] == true,
      canStart: json['can_start'] == true,
      canEnd: json['can_end'] == true,
      canEdit: json['can_edit'] == true,
      canDelete: json['can_delete'] == true,
    );
  }
}

class ConsultationStatistics {
  final int totalConsultations;
  final int completedConsultations;
  final int cancelledConsultations;
  final int ongoingConsultations;
  final int scheduledConsultations;
  final double completionRate;
  final int consultationsWithRecordings;
  final double recordingRate;
  final double? averageDurationMinutes;
  final List<DailyStatistic> dailyStatistics;

  const ConsultationStatistics({
    required this.totalConsultations,
    required this.completedConsultations,
    required this.cancelledConsultations,
    required this.ongoingConsultations,
    required this.scheduledConsultations,
    required this.completionRate,
    required this.consultationsWithRecordings,
    required this.recordingRate,
    this.averageDurationMinutes,
    required this.dailyStatistics,
  });

  factory ConsultationStatistics.fromJson(Map<String, dynamic> json) {
    return ConsultationStatistics(
      totalConsultations: json['total_consultations'] ?? 0,
      completedConsultations: json['completed_consultations'] ?? 0,
      cancelledConsultations: json['cancelled_consultations'] ?? 0,
      ongoingConsultations: json['ongoing_consultations'] ?? 0,
      scheduledConsultations: json['scheduled_consultations'] ?? 0,
      completionRate: (json['completion_rate'] ?? 0).toDouble(),
      consultationsWithRecordings: json['consultations_with_recordings'] ?? 0,
      recordingRate: (json['recording_rate'] ?? 0).toDouble(),
      averageDurationMinutes: json['average_duration_minutes']?.toDouble(),
      dailyStatistics: (json['daily_statistics'] as List?)
          ?.map((d) => DailyStatistic.fromJson(d))
          .toList() ?? [],
    );
  }
}
```

---

## Vital Signs Model

### Location: `lib/models/vital_signs_model.dart`

```dart
class VitalSignModel {
  final String id;
  final String patientId;
  final String bloodPressure;      // "120/80"
  final int systolicPressure;
  final int diastolicPressure;
  final String heartRate;          // "72 bpm"
  final String temperature;        // "37.0°C"
  final String respiratoryRate;    // "16 /min"
  final String oxygenSaturation;   // "98%"
  final String weight;             // "70 kg"
  final String height;             // "175 cm"
  final String bmi;
  final String notes;
  final String recordedAt;
  final String recordedAtHuman;
  final String recordedDate;
  final String recordedTime;
  final RecordedBy recordedBy;
  final VitalPatient patient;

  const VitalSignModel({
    required this.id,
    required this.patientId,
    required this.bloodPressure,
    required this.systolicPressure,
    required this.diastolicPressure,
    required this.heartRate,
    required this.temperature,
    required this.respiratoryRate,
    required this.oxygenSaturation,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.notes,
    required this.recordedAt,
    required this.recordedAtHuman,
    required this.recordedDate,
    required this.recordedTime,
    required this.recordedBy,
    required this.patient,
  });

  // Validation helpers
  bool get isBloodPressureNormal {
    return systolicPressure >= 90 && systolicPressure <= 140 &&
           diastolicPressure >= 60 && diastolicPressure <= 90;
  }

  bool get isHeartRateNormal {
    final rate = int.tryParse(heartRate.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return rate >= 60 && rate <= 100;
  }

  bool get isTemperatureNormal {
    final temp = double.tryParse(
      temperature.replaceAll(RegExp(r'[^0-9.]'), ''),
    ) ?? 0;
    return temp >= 36.1 && temp <= 37.5;
  }

  String get overallStatus {
    if (!isBloodPressureNormal || !isHeartRateNormal || !isTemperatureNormal) {
      return 'Attention';
    }
    return 'Normal';
  }

  factory VitalSignModel.fromJson(Map<String, dynamic> json) {
    return VitalSignModel(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? '',
      bloodPressure: json['blood_pressure']?.toString() ?? '',
      systolicPressure: int.tryParse(json['systolic_pressure']?.toString() ?? '0') ?? 0,
      diastolicPressure: int.tryParse(json['diastolic_pressure']?.toString() ?? '0') ?? 0,
      heartRate: json['heart_rate']?.toString() ?? '',
      temperature: json['temperature']?.toString() ?? '',
      respiratoryRate: json['respiratory_rate']?.toString() ?? '',
      oxygenSaturation: json['oxygen_saturation']?.toString() ?? '',
      weight: json['weight']?.toString() ?? '',
      height: json['height']?.toString() ?? '',
      bmi: json['bmi']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      recordedAt: json['recorded_at']?.toString() ?? '',
      recordedAtHuman: json['recorded_at_human']?.toString() ?? '',
      recordedDate: json['recorded_date']?.toString() ?? '',
      recordedTime: json['recorded_time']?.toString() ?? '',
      recordedBy: RecordedBy.fromJson(json['recorded_by'] ?? {}),
      patient: VitalPatient.fromJson(json['patient'] ?? {}),
    );
  }
}

class RecordedBy {
  final String? id;
  final String name;
  final String type;

  const RecordedBy({
    this.id,
    required this.name,
    required this.type,
  });

  factory RecordedBy.fromJson(Map<String, dynamic> json) {
    return RecordedBy(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? 'Unknown',
      type: json['type']?.toString() ?? 'staff',
    );
  }
}
```

---

## Accounting Models

### Location: `lib/models/account_model.dart` & `lib/models/bill_model.dart`

```dart
// Account Model
class Account {
  final String id;
  final String name;
  final String type;
  final String description;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String typeDisplay;
  final String statusDisplay;
  final bool isActive;
  final double totalPaymentsAmount;
  final List<Payment> payments;

  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.typeDisplay,
    required this.statusDisplay,
    required this.isActive,
    required this.totalPaymentsAmount,
    required this.payments,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      typeDisplay: json['type_display']?.toString() ?? '',
      statusDisplay: json['status_display']?.toString() ?? '',
      isActive: json['is_active'] == true || json['status'] == 'active',
      totalPaymentsAmount: (json['total_payments_amount'] ?? 0).toDouble(),
      payments: (json['payments'] as List?)
          ?.map((p) => Payment.fromJson(p))
          .toList() ?? [],
    );
  }
}

// Payment Model
class Payment {
  final String id;
  final String paymentDate;
  final String payTo;
  final String amount;
  final String description;
  final String createdAt;
  final String updatedAt;
  final Account? account;
  final String paymentDateFormatted;
  final String amountFormatted;
  final String amountCurrency;

  const Payment({
    required this.id,
    required this.paymentDate,
    required this.payTo,
    required this.amount,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.account,
    required this.paymentDateFormatted,
    required this.amountFormatted,
    required this.amountCurrency,
  });

  double get amountValue => double.tryParse(amount) ?? 0;

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id']?.toString() ?? '',
      paymentDate: json['payment_date']?.toString() ?? '',
      payTo: json['pay_to']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0',
      description: json['description']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      account: json['account'] != null ? Account.fromJson(json['account']) : null,
      paymentDateFormatted: json['payment_date_formatted']?.toString() ?? '',
      amountFormatted: json['amount_formatted']?.toString() ?? '',
      amountCurrency: json['amount_currency']?.toString() ?? 'USD',
    );
  }
}

// Bill Model
class Bill {
  final String id;
  final String reference;
  final String billDate;
  final String amount;
  final String patientAdmissionId;
  final String status;           // paid, pending, overdue
  final String paymentMode;
  final String createdAt;
  final String updatedAt;
  final Patient? patient;
  final List<BillItem> billItems;
  final bool isPaid;
  final bool isPending;
  final bool isOverdue;

  const Bill({
    required this.id,
    required this.reference,
    required this.billDate,
    required this.amount,
    required this.patientAdmissionId,
    required this.status,
    required this.paymentMode,
    required this.createdAt,
    required this.updatedAt,
    this.patient,
    required this.billItems,
    required this.isPaid,
    required this.isPending,
    required this.isOverdue,
  });

  double get totalAmount => double.tryParse(amount) ?? 0;

  factory Bill.fromJson(Map<String, dynamic> json) {
    final status = json['status']?.toString() ?? 'pending';
    return Bill(
      id: json['id']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      billDate: json['bill_date']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0',
      patientAdmissionId: json['patient_admission_id']?.toString() ?? '',
      status: status,
      paymentMode: json['payment_mode']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      patient: json['patient'] != null ? Patient.fromJson(json['patient']) : null,
      billItems: (json['bill_items'] as List?)
          ?.map((i) => BillItem.fromJson(i))
          .toList() ?? [],
      isPaid: status == 'paid' || json['is_paid'] == true,
      isPending: status == 'pending' || json['is_pending'] == true,
      isOverdue: status == 'overdue' || json['is_overdue'] == true,
    );
  }
}

class BillItem {
  final String id;
  final String itemName;
  final int qty;
  final String price;
  final String amount;
  final double unitTotal;

  const BillItem({
    required this.id,
    required this.itemName,
    required this.qty,
    required this.price,
    required this.amount,
    required this.unitTotal,
  });

  factory BillItem.fromJson(Map<String, dynamic> json) {
    final qty = int.tryParse(json['qty']?.toString() ?? '1') ?? 1;
    final price = double.tryParse(json['price']?.toString() ?? '0') ?? 0;

    return BillItem(
      id: json['id']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? '',
      qty: qty,
      price: json['price']?.toString() ?? '0',
      amount: json['amount']?.toString() ?? '0',
      unitTotal: qty * price,
    );
  }
}
```

---

## Nurse Model

### Location: `lib/models/nurse_model.dart`

```dart
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

  const Nurse({
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

  String get fullName => '$firstName $lastName';
  bool get isActive => status == 'active';

  factory Nurse.fromJson(Map<String, dynamic> json) {
    return Nurse(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      profileImage: json['profile_image']?.toString() ?? '',
      qualification: json['qualification']?.toString() ?? '',
      bloodGroup: json['blood_group']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      user: json['user'] ?? {},
    );
  }
}
```

---

## Best Practices

### 1. Null Safety

```dart
// ✓ Always provide default values
factory Model.fromJson(Map<String, dynamic> json) {
  return Model(
    id: json['id']?.toString() ?? '',  // Default to empty string
    count: int.tryParse(json['count']?.toString() ?? '0') ?? 0,  // Default to 0
    isActive: json['is_active'] == true,  // Default to false
  );
}
```

### 2. Type Parsing

```dart
// ✓ Safe parsing with fallbacks
int.tryParse(json['value']?.toString() ?? '0') ?? 0;
double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0;
DateTime.tryParse(json['date'] ?? '') ?? DateTime.now();
```

### 3. Immutability

```dart
// ✓ Use final fields and copyWith for updates
class Model {
  final String id;
  final String name;

  Model copyWith({String? id, String? name}) {
    return Model(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
```

### 4. Nested Models

```dart
// ✓ Parse nested objects properly
factory Parent.fromJson(Map<String, dynamic> json) {
  return Parent(
    child: json['child'] != null
        ? Child.fromJson(json['child'])
        : null,
    children: (json['children'] as List?)
        ?.map((c) => Child.fromJson(c))
        .toList() ?? [],
  );
}
```
