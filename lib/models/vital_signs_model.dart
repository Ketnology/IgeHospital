class VitalSignModel {
  final String id;
  final String patientId;
  final String bloodPressure;
  final int systolicPressure;
  final int diastolicPressure;
  final String heartRate;
  final String temperature;
  final String respiratoryRate;
  final String oxygenSaturation;
  final String weight;
  final String height;
  final String bmi;
  final String notes;
  final String recordedAt;
  final String recordedAtHuman;
  final String recordedDate;
  final String recordedTime;
  final RecordedBy recordedBy;
  final VitalPatient patient;

  VitalSignModel({
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

  factory VitalSignModel.fromJson(Map<String, dynamic> json) {
    return VitalSignModel(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id'] ?? '',
      bloodPressure: json['blood_pressure'] ?? '',
      systolicPressure: json['systolic_pressure'] is int
          ? json['systolic_pressure']
          : int.tryParse(json['systolic_pressure']?.toString() ?? '0') ?? 0,
      diastolicPressure: json['diastolic_pressure'] is int
          ? json['diastolic_pressure']
          : int.tryParse(json['diastolic_pressure']?.toString() ?? '0') ?? 0,
      heartRate: json['heart_rate'] ?? '',
      temperature: json['temperature'] ?? '',
      respiratoryRate: json['respiratory_rate'] ?? '',
      oxygenSaturation: json['oxygen_saturation'] ?? '',
      weight: json['weight'] ?? '',
      height: json['height'] ?? '',
      bmi: json['bmi'] ?? '',
      notes: json['notes'] ?? '',
      recordedAt: json['recorded_at'] ?? '',
      recordedAtHuman: json['recorded_at_human'] ?? '',
      recordedDate: json['recorded_date'] ?? '',
      recordedTime: json['recorded_time'] ?? '',
      recordedBy: RecordedBy.fromJson(json['recorded_by'] ?? {}),
      patient: VitalPatient.fromJson(json['patient'] ?? {}),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'patient_id': patientId,
      'systolic_pressure': systolicPressure,
      'diastolic_pressure': diastolicPressure,
      'heart_rate': int.tryParse(heartRate.replaceAll(' bpm', '')) ?? 0,
      'temperature': double.tryParse(temperature.replaceAll('°C', '')) ?? 0.0,
      'temperature_unit': 'celsius',
      'respiratory_rate': int.tryParse(respiratoryRate.replaceAll(' /min', '')) ?? 0,
      'oxygen_saturation': int.tryParse(oxygenSaturation.replaceAll('%', '')) ?? 0,
      'weight': double.tryParse(weight.replaceAll(' kg', '')) ?? 0.0,
      'weight_unit': 'kg',
      'height': int.tryParse(height.replaceAll(' cm', '')) ?? 0,
      'height_unit': 'cm',
      'notes': notes,
      'recorded_at': recordedAt,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'systolic_pressure': systolicPressure,
      'diastolic_pressure': diastolicPressure,
      'heart_rate': int.tryParse(heartRate.replaceAll(' bpm', '')) ?? 0,
      'temperature': double.tryParse(temperature.replaceAll('°C', '')) ?? 0.0,
      'temperature_unit': 'celsius',
      'respiratory_rate': int.tryParse(respiratoryRate.replaceAll(' /min', '')) ?? 0,
      'oxygen_saturation': int.tryParse(oxygenSaturation.replaceAll('%', '')) ?? 0,
      'weight': double.tryParse(weight.replaceAll(' kg', '')) ?? 0.0,
      'weight_unit': 'kg',
      'height': int.tryParse(height.replaceAll(' cm', '')) ?? 0,
      'height_unit': 'cm',
      'notes': notes,
    };
  }

  // Helper methods for data analysis
  bool get isBloodPressureNormal {
    return systolicPressure >= 90 && systolicPressure <= 120 &&
        diastolicPressure >= 60 && diastolicPressure <= 80;
  }

  bool get isHeartRateNormal {
    final rate = int.tryParse(heartRate.replaceAll(' bpm', '')) ?? 0;
    return rate >= 60 && rate <= 100;
  }

  bool get isTemperatureNormal {
    final temp = double.tryParse(temperature.replaceAll('°C', '')) ?? 0.0;
    return temp >= 36.1 && temp <= 37.2;
  }

  String get overallStatus {
    if (isBloodPressureNormal && isHeartRateNormal && isTemperatureNormal) {
      return 'Normal';
    } else if (!isBloodPressureNormal || !isHeartRateNormal || !isTemperatureNormal) {
      return 'Attention';
    }
    return 'Critical';
  }
}

class RecordedBy {
  final String? id;
  final String name;
  final String type;

  RecordedBy({
    this.id,
    required this.name,
    required this.type,
  });

  factory RecordedBy.fromJson(Map<String, dynamic> json) {
    return RecordedBy(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
      type: json['type'] ?? 'Unknown',
    );
  }
}

class VitalPatient {
  final String id;
  final String name;
  final String patientUniqueId;

  VitalPatient({
    required this.id,
    required this.name,
    required this.patientUniqueId,
  });

  factory VitalPatient.fromJson(Map<String, dynamic> json) {
    return VitalPatient(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      patientUniqueId: json['patient_unique_id'] ?? '',
    );
  }
}