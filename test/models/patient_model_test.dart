import 'package:flutter_test/flutter_test.dart';
import 'package:ige_hospital/models/patient_model.dart';

void main() {
  group('PatientModel', () {
    group('fromJson', () {
      test('should parse valid JSON correctly', () {
        final json = {
          'id': '1',
          'patient_unique_id': 'PAT001',
          'custom_field': 'custom value',
          'created_at': '2024-01-01 00:00:00',
          'updated_at': '2024-01-02 00:00:00',
          'user': {
            'first_name': 'John',
            'last_name': 'Doe',
            'email': 'john@example.com',
            'phone': '1234567890'
          },
          'address': {
            'address1': '123 Main St',
            'city': 'New York'
          },
          'template': {
            'template_id': 't1'
          },
          'stats': {
            'appointments_count': '5',
            'documents_count': '2',
            'vital_signs_count': 10
          },
          'appointments': [
            {'id': 'apt1', 'date': '2024-01-15'}
          ],
          'documents': [
            {'id': 'doc1', 'name': 'report.pdf'}
          ],
          'vital_signs': [
            {'id': 'vs1', 'blood_pressure': '120/80'}
          ],
          'vital_signs_summary': {
            'total_records': 10,
            'last_recorded': '2024-01-15',
            'blood_pressure': '120/80',
            'heart_rate': '72 bpm',
            'temperature': '36.5°C'
          }
        };

        final patient = PatientModel.fromJson(json);

        expect(patient.id, equals('1'));
        expect(patient.patientUniqueId, equals('PAT001'));
        expect(patient.customField, equals('custom value'));
        expect(patient.createdAt, equals('2024-01-01 00:00:00'));
        expect(patient.updatedAt, equals('2024-01-02 00:00:00'));
        expect(patient.user['first_name'], equals('John'));
        expect(patient.user['last_name'], equals('Doe'));
        expect(patient.address?['city'], equals('New York'));
        expect(patient.template?['template_id'], equals('t1'));
        expect(patient.stats['appointments_count'], equals('5'));
        expect(patient.appointments.length, equals(1));
        expect(patient.documents.length, equals(1));
        expect(patient.vitalSigns.length, equals(1));
        expect(patient.vitalSignsSummary?['total_records'], equals(10));
      });

      test('should handle null and missing fields gracefully', () {
        final json = <String, dynamic>{};

        final patient = PatientModel.fromJson(json);

        expect(patient.id, equals(''));
        expect(patient.patientUniqueId, equals(''));
        expect(patient.customField, equals(''));
        expect(patient.user, equals({}));
        expect(patient.address, isNull);
        expect(patient.template, isNull);
        expect(patient.appointments, isEmpty);
        expect(patient.documents, isEmpty);
        expect(patient.vitalSigns, isEmpty);
        expect(patient.vitalSignsSummary, isNull);
      });

      test('should handle empty list for stats', () {
        final json = {
          'id': '1',
          'stats': [], // Empty list instead of map
          'appointments': null,
          'documents': null,
          'vital_signs': null,
        };

        final patient = PatientModel.fromJson(json);

        expect(patient.stats['appointments_count'], equals('0'));
        expect(patient.stats['documents_count'], equals('0'));
        expect(patient.stats['vital_signs_count'], equals(0));
      });

      test('should handle non-list types for lists', () {
        final json = {
          'id': '1',
          'appointments': 'invalid',
          'documents': 123,
          'vital_signs': {'key': 'value'},
        };

        final patient = PatientModel.fromJson(json);

        expect(patient.appointments, isEmpty);
        expect(patient.documents, isEmpty);
        expect(patient.vitalSigns, isEmpty);
      });
    });

    group('toJson', () {
      test('should convert model to JSON correctly', () {
        final patient = PatientModel(
          id: '1',
          patientUniqueId: 'PAT001',
          customField: 'custom',
          createdAt: '2024-01-01',
          updatedAt: '2024-01-02',
          user: {'first_name': 'John', 'last_name': 'Doe'},
          address: {'city': 'New York'},
          template: {'id': 't1'},
          stats: {'appointments_count': '5'},
          appointments: [{'id': 'apt1'}],
          documents: [{'id': 'doc1'}],
          vitalSigns: [{'id': 'vs1'}],
          vitalSignsSummary: {'total_records': 10},
        );

        final json = patient.toJson();

        expect(json['id'], equals('1'));
        expect(json['patient_unique_id'], equals('PAT001'));
        expect(json['custom_field'], equals('custom'));
        expect(json['user']['first_name'], equals('John'));
        expect(json['address']['city'], equals('New York'));
        expect(json['appointments'].length, equals(1));
        expect(json['vital_signs_summary']['total_records'], equals(10));
      });
    });

    group('Helper getters', () {
      test('hasVitalSigns should return true when vitalSigns is not empty', () {
        final patient = PatientModel(
          id: '1',
          patientUniqueId: 'PAT001',
          customField: '',
          createdAt: '',
          updatedAt: '',
          user: {},
          stats: {},
          appointments: [],
          documents: [],
          vitalSigns: [{'id': 'vs1'}],
        );

        expect(patient.hasVitalSigns, isTrue);
      });

      test('hasVitalSigns should return false when vitalSigns is empty', () {
        final patient = PatientModel(
          id: '1',
          patientUniqueId: 'PAT001',
          customField: '',
          createdAt: '',
          updatedAt: '',
          user: {},
          stats: {},
          appointments: [],
          documents: [],
          vitalSigns: [],
        );

        expect(patient.hasVitalSigns, isFalse);
      });

      test('lastVitalSignsDate should return date from summary', () {
        final patient = PatientModel(
          id: '1',
          patientUniqueId: 'PAT001',
          customField: '',
          createdAt: '',
          updatedAt: '',
          user: {},
          stats: {},
          appointments: [],
          documents: [],
          vitalSigns: [],
          vitalSignsSummary: {'last_recorded': '2024-01-15'},
        );

        expect(patient.lastVitalSignsDate, equals('2024-01-15'));
      });

      test('lastVitalSignsDate should return "No records" when no summary', () {
        final patient = PatientModel(
          id: '1',
          patientUniqueId: 'PAT001',
          customField: '',
          createdAt: '',
          updatedAt: '',
          user: {},
          stats: {},
          appointments: [],
          documents: [],
          vitalSigns: [],
        );

        expect(patient.lastVitalSignsDate, equals('No records'));
      });

      test('latestBloodPressure should return value from summary', () {
        final patient = PatientModel(
          id: '1',
          patientUniqueId: 'PAT001',
          customField: '',
          createdAt: '',
          updatedAt: '',
          user: {},
          stats: {},
          appointments: [],
          documents: [],
          vitalSigns: [],
          vitalSignsSummary: {'blood_pressure': '120/80'},
        );

        expect(patient.latestBloodPressure, equals('120/80'));
      });

      test('latestBloodPressure should return N/A when no summary', () {
        final patient = PatientModel(
          id: '1',
          patientUniqueId: 'PAT001',
          customField: '',
          createdAt: '',
          updatedAt: '',
          user: {},
          stats: {},
          appointments: [],
          documents: [],
          vitalSigns: [],
        );

        expect(patient.latestBloodPressure, equals('N/A'));
      });

      test('latestHeartRate should return value from summary', () {
        final patient = PatientModel(
          id: '1',
          patientUniqueId: 'PAT001',
          customField: '',
          createdAt: '',
          updatedAt: '',
          user: {},
          stats: {},
          appointments: [],
          documents: [],
          vitalSigns: [],
          vitalSignsSummary: {'heart_rate': '72 bpm'},
        );

        expect(patient.latestHeartRate, equals('72 bpm'));
      });

      test('latestTemperature should return value from summary', () {
        final patient = PatientModel(
          id: '1',
          patientUniqueId: 'PAT001',
          customField: '',
          createdAt: '',
          updatedAt: '',
          user: {},
          stats: {},
          appointments: [],
          documents: [],
          vitalSigns: [],
          vitalSignsSummary: {'temperature': '36.5°C'},
        );

        expect(patient.latestTemperature, equals('36.5°C'));
      });

      test('vitalSignsCount should return total_records from summary', () {
        final patient = PatientModel(
          id: '1',
          patientUniqueId: 'PAT001',
          customField: '',
          createdAt: '',
          updatedAt: '',
          user: {},
          stats: {},
          appointments: [],
          documents: [],
          vitalSigns: [{'id': '1'}, {'id': '2'}],
          vitalSignsSummary: {'total_records': 10},
        );

        expect(patient.vitalSignsCount, equals(10));
      });

      test('vitalSignsCount should return vitalSigns.length when no summary', () {
        final patient = PatientModel(
          id: '1',
          patientUniqueId: 'PAT001',
          customField: '',
          createdAt: '',
          updatedAt: '',
          user: {},
          stats: {},
          appointments: [],
          documents: [],
          vitalSigns: [{'id': '1'}, {'id': '2'}, {'id': '3'}],
        );

        expect(patient.vitalSignsCount, equals(3));
      });
    });
  });
}
