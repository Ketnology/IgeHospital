import 'package:flutter_test/flutter_test.dart';
import 'package:ige_hospital/models/vital_signs_model.dart';

void main() {
  group('VitalSignModel', () {
    group('fromJson', () {
      test('should parse valid JSON correctly', () {
        final json = {
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
        };

        final vitalSign = VitalSignModel.fromJson(json);

        expect(vitalSign.id, equals('1'));
        expect(vitalSign.patientId, equals('p1'));
        expect(vitalSign.bloodPressure, equals('120/80'));
        expect(vitalSign.systolicPressure, equals(120));
        expect(vitalSign.diastolicPressure, equals(80));
        expect(vitalSign.heartRate, equals('72 bpm'));
        expect(vitalSign.temperature, equals('36.5°C'));
        expect(vitalSign.respiratoryRate, equals('16 /min'));
        expect(vitalSign.oxygenSaturation, equals('98%'));
        expect(vitalSign.weight, equals('70 kg'));
        expect(vitalSign.height, equals('175 cm'));
        expect(vitalSign.bmi, equals('22.9'));
        expect(vitalSign.notes, equals('Normal vitals'));
        expect(vitalSign.recordedBy.name, equals('Nurse Jane'));
        expect(vitalSign.patient.name, equals('John Doe'));
      });

      test('should handle string numeric values', () {
        final json = {
          'id': '1',
          'patient_id': 'p1',
          'systolic_pressure': '130',
          'diastolic_pressure': '85',
          'recorded_by': {},
          'patient': {}
        };

        final vitalSign = VitalSignModel.fromJson(json);

        expect(vitalSign.systolicPressure, equals(130));
        expect(vitalSign.diastolicPressure, equals(85));
      });

      test('should handle null and missing fields', () {
        final json = <String, dynamic>{};

        final vitalSign = VitalSignModel.fromJson(json);

        expect(vitalSign.id, equals(''));
        expect(vitalSign.patientId, equals(''));
        expect(vitalSign.bloodPressure, equals(''));
        expect(vitalSign.systolicPressure, equals(0));
        expect(vitalSign.diastolicPressure, equals(0));
        expect(vitalSign.heartRate, equals(''));
        expect(vitalSign.temperature, equals(''));
        expect(vitalSign.recordedBy.name, equals('Unknown'));
        expect(vitalSign.patient.name, equals(''));
      });
    });

    group('toCreateJson', () {
      test('should create correct JSON for API', () {
        final vitalSign = VitalSignModel(
          id: '1',
          patientId: 'p1',
          bloodPressure: '120/80',
          systolicPressure: 120,
          diastolicPressure: 80,
          heartRate: '72 bpm',
          temperature: '36.5°C',
          respiratoryRate: '16 /min',
          oxygenSaturation: '98%',
          weight: '70 kg',
          height: '175 cm',
          bmi: '22.9',
          notes: 'Test notes',
          recordedAt: '2024-01-15T10:00:00.000Z',
          recordedAtHuman: '',
          recordedDate: '',
          recordedTime: '',
          recordedBy: RecordedBy(name: 'Test', type: 'nurse'),
          patient: VitalPatient(id: 'p1', name: 'John', patientUniqueId: 'PAT001'),
        );

        final json = vitalSign.toCreateJson();

        expect(json['patient_id'], equals('p1'));
        expect(json['systolic_pressure'], equals(120));
        expect(json['diastolic_pressure'], equals(80));
        expect(json['heart_rate'], equals(72));
        expect(json['temperature'], equals(36.5));
        expect(json['temperature_unit'], equals('celsius'));
        expect(json['respiratory_rate'], equals(16));
        expect(json['oxygen_saturation'], equals(98));
        expect(json['weight'], equals(70.0));
        expect(json['weight_unit'], equals('kg'));
        expect(json['height'], equals(175));
        expect(json['height_unit'], equals('cm'));
        expect(json['notes'], equals('Test notes'));
      });
    });

    group('toUpdateJson', () {
      test('should create correct JSON for update', () {
        final vitalSign = VitalSignModel(
          id: '1',
          patientId: 'p1',
          bloodPressure: '130/85',
          systolicPressure: 130,
          diastolicPressure: 85,
          heartRate: '80 bpm',
          temperature: '37.0°C',
          respiratoryRate: '18 /min',
          oxygenSaturation: '97%',
          weight: '72 kg',
          height: '175 cm',
          bmi: '23.5',
          notes: 'Updated notes',
          recordedAt: '2024-01-15T10:00:00.000Z',
          recordedAtHuman: '',
          recordedDate: '',
          recordedTime: '',
          recordedBy: RecordedBy(name: 'Test', type: 'nurse'),
          patient: VitalPatient(id: 'p1', name: 'John', patientUniqueId: 'PAT001'),
        );

        final json = vitalSign.toUpdateJson();

        expect(json['systolic_pressure'], equals(130));
        expect(json['diastolic_pressure'], equals(85));
        expect(json['heart_rate'], equals(80));
        expect(json['temperature'], equals(37.0));
        expect(json['notes'], equals('Updated notes'));
        expect(json.containsKey('patient_id'), isFalse);
      });
    });

    group('Health status helpers', () {
      test('isBloodPressureNormal should return true for normal values', () {
        final vitalSign = _createVitalSign(
          systolicPressure: 115,
          diastolicPressure: 75,
        );

        expect(vitalSign.isBloodPressureNormal, isTrue);
      });

      test('isBloodPressureNormal should return false for high systolic', () {
        final vitalSign = _createVitalSign(
          systolicPressure: 140,
          diastolicPressure: 75,
        );

        expect(vitalSign.isBloodPressureNormal, isFalse);
      });

      test('isBloodPressureNormal should return false for low systolic', () {
        final vitalSign = _createVitalSign(
          systolicPressure: 85,
          diastolicPressure: 75,
        );

        expect(vitalSign.isBloodPressureNormal, isFalse);
      });

      test('isBloodPressureNormal should return false for high diastolic', () {
        final vitalSign = _createVitalSign(
          systolicPressure: 115,
          diastolicPressure: 90,
        );

        expect(vitalSign.isBloodPressureNormal, isFalse);
      });

      test('isBloodPressureNormal should return false for low diastolic', () {
        final vitalSign = _createVitalSign(
          systolicPressure: 115,
          diastolicPressure: 55,
        );

        expect(vitalSign.isBloodPressureNormal, isFalse);
      });

      test('isHeartRateNormal should return true for normal rate', () {
        final vitalSign = _createVitalSign(heartRate: '75 bpm');

        expect(vitalSign.isHeartRateNormal, isTrue);
      });

      test('isHeartRateNormal should return true for boundary values', () {
        expect(_createVitalSign(heartRate: '60 bpm').isHeartRateNormal, isTrue);
        expect(_createVitalSign(heartRate: '100 bpm').isHeartRateNormal, isTrue);
      });

      test('isHeartRateNormal should return false for high rate', () {
        final vitalSign = _createVitalSign(heartRate: '110 bpm');

        expect(vitalSign.isHeartRateNormal, isFalse);
      });

      test('isHeartRateNormal should return false for low rate', () {
        final vitalSign = _createVitalSign(heartRate: '50 bpm');

        expect(vitalSign.isHeartRateNormal, isFalse);
      });

      test('isTemperatureNormal should return true for normal temperature', () {
        final vitalSign = _createVitalSign(temperature: '36.8°C');

        expect(vitalSign.isTemperatureNormal, isTrue);
      });

      test('isTemperatureNormal should return true for boundary values', () {
        expect(_createVitalSign(temperature: '36.1°C').isTemperatureNormal, isTrue);
        expect(_createVitalSign(temperature: '37.2°C').isTemperatureNormal, isTrue);
      });

      test('isTemperatureNormal should return false for fever', () {
        final vitalSign = _createVitalSign(temperature: '38.5°C');

        expect(vitalSign.isTemperatureNormal, isFalse);
      });

      test('isTemperatureNormal should return false for hypothermia', () {
        final vitalSign = _createVitalSign(temperature: '35.5°C');

        expect(vitalSign.isTemperatureNormal, isFalse);
      });

      test('overallStatus should return Normal when all vitals are normal', () {
        final vitalSign = _createVitalSign(
          systolicPressure: 115,
          diastolicPressure: 75,
          heartRate: '72 bpm',
          temperature: '36.5°C',
        );

        expect(vitalSign.overallStatus, equals('Normal'));
      });

      test('overallStatus should return Attention when blood pressure is abnormal', () {
        final vitalSign = _createVitalSign(
          systolicPressure: 150,
          diastolicPressure: 95,
          heartRate: '72 bpm',
          temperature: '36.5°C',
        );

        expect(vitalSign.overallStatus, equals('Attention'));
      });

      test('overallStatus should return Attention when heart rate is abnormal', () {
        final vitalSign = _createVitalSign(
          systolicPressure: 115,
          diastolicPressure: 75,
          heartRate: '120 bpm',
          temperature: '36.5°C',
        );

        expect(vitalSign.overallStatus, equals('Attention'));
      });

      test('overallStatus should return Attention when temperature is abnormal', () {
        final vitalSign = _createVitalSign(
          systolicPressure: 115,
          diastolicPressure: 75,
          heartRate: '72 bpm',
          temperature: '39.0°C',
        );

        expect(vitalSign.overallStatus, equals('Attention'));
      });
    });
  });

  group('RecordedBy', () {
    test('fromJson should parse correctly', () {
      final json = {'id': 'n1', 'name': 'Nurse Jane', 'type': 'nurse'};

      final recordedBy = RecordedBy.fromJson(json);

      expect(recordedBy.id, equals('n1'));
      expect(recordedBy.name, equals('Nurse Jane'));
      expect(recordedBy.type, equals('nurse'));
    });

    test('fromJson should handle missing fields', () {
      final json = <String, dynamic>{};

      final recordedBy = RecordedBy.fromJson(json);

      expect(recordedBy.id, isNull);
      expect(recordedBy.name, equals('Unknown'));
      expect(recordedBy.type, equals('Unknown'));
    });
  });

  group('VitalPatient', () {
    test('fromJson should parse correctly', () {
      final json = {
        'id': 'p1',
        'name': 'John Doe',
        'patient_unique_id': 'PAT001'
      };

      final patient = VitalPatient.fromJson(json);

      expect(patient.id, equals('p1'));
      expect(patient.name, equals('John Doe'));
      expect(patient.patientUniqueId, equals('PAT001'));
    });

    test('fromJson should handle missing fields', () {
      final json = <String, dynamic>{};

      final patient = VitalPatient.fromJson(json);

      expect(patient.id, equals(''));
      expect(patient.name, equals(''));
      expect(patient.patientUniqueId, equals(''));
    });
  });
}

VitalSignModel _createVitalSign({
  int systolicPressure = 120,
  int diastolicPressure = 80,
  String heartRate = '72 bpm',
  String temperature = '36.5°C',
}) {
  return VitalSignModel(
    id: '1',
    patientId: 'p1',
    bloodPressure: '$systolicPressure/$diastolicPressure',
    systolicPressure: systolicPressure,
    diastolicPressure: diastolicPressure,
    heartRate: heartRate,
    temperature: temperature,
    respiratoryRate: '16 /min',
    oxygenSaturation: '98%',
    weight: '70 kg',
    height: '175 cm',
    bmi: '22.9',
    notes: '',
    recordedAt: '2024-01-15T10:00:00.000Z',
    recordedAtHuman: '',
    recordedDate: '',
    recordedTime: '',
    recordedBy: RecordedBy(name: 'Test', type: 'nurse'),
    patient: VitalPatient(id: 'p1', name: 'John', patientUniqueId: 'PAT001'),
  );
}
