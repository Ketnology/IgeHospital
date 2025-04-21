
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
  final String date;
  final String time;
  final String doctor;
  final String doctorName;
  final String? doctorImage;
  final String doctorDepartment;
  final String patient;
  final String patientName;
  final String? patientImage;
  final String createdAt;
  final String updatedAt;

  AppointmentModel({
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

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? '',
      patientId: json['patient_id'] ?? '',
      doctorId: json['doctor_id'] ?? '',
      departmentId: json['department_id'] ?? '',
      opdDate: json['opd_date'] ?? '',
      problem: json['problem'] ?? '',
      isCompleted: json['is_completed'] ?? false,
      customField: json['custom_field']?.toString() ?? '',
      appointmentDate: json['appointment_date'] ?? '',
      appointmentTime: json['appointment_time'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      doctor: json['doctor'] ?? '',
      doctorName: json['doctor_name'] ?? '',
      doctorImage: json['doctor_image'],
      doctorDepartment: json['doctor_department'] ?? '',
      patient: json['patient'] ?? '',
      patientName: json['patient_name'] ?? '',
      patientImage: json['patient_image'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'patient_id': patientId,
    'doctor_id': doctorId,
    'department_id': departmentId,
    'opd_date': opdDate,
    'problem': problem,
    'is_completed': isCompleted,
    'custom_field': customField,
    'appointment_date': appointmentDate,
    'appointment_time': appointmentTime,
    'date': date,
    'time': time,
    'doctor': doctor,
    'doctor_name': doctorName,
    'doctor_image': doctorImage,
    'doctor_department': doctorDepartment,
    'patient': patient,
    'patient_name': patientName,
    'patient_image': patientImage,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
