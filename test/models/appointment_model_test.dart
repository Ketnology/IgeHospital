import 'package:flutter_test/flutter_test.dart';
import 'package:ige_hospital/models/appointment_model.dart';

void main() {
  group('AppointmentModel', () {
    group('fromJson', () {
      test('should parse valid JSON correctly', () {
        final json = {
          'id': 'apt1',
          'patient_id': 'p1',
          'doctor_id': 'd1',
          'department_id': 'dept1',
          'opd_date': '2024-01-15',
          'problem': 'Chest pain and shortness of breath',
          'is_completed': false,
          'custom_field': 'custom value',
          'appointment_date': '2024-01-15',
          'appointment_time': '10:00',
          'date': 'Jan 15, 2024',
          'time': '10:00 AM',
          'doctor': 'd1',
          'doctor_name': 'Dr. Smith',
          'doctor_image': 'https://example.com/doctor.jpg',
          'doctor_department': 'Cardiology',
          'patient': 'p1',
          'patient_name': 'John Doe',
          'patient_image': 'https://example.com/patient.jpg',
          'created_at': '2024-01-10 00:00:00',
          'updated_at': '2024-01-12 00:00:00'
        };

        final appointment = AppointmentModel.fromJson(json);

        expect(appointment.id, equals('apt1'));
        expect(appointment.patientId, equals('p1'));
        expect(appointment.doctorId, equals('d1'));
        expect(appointment.departmentId, equals('dept1'));
        expect(appointment.opdDate, equals('2024-01-15'));
        expect(appointment.problem, equals('Chest pain and shortness of breath'));
        expect(appointment.isCompleted, isFalse);
        expect(appointment.customField, equals('custom value'));
        expect(appointment.appointmentDate, equals('2024-01-15'));
        expect(appointment.appointmentTime, equals('10:00'));
        expect(appointment.date, equals('Jan 15, 2024'));
        expect(appointment.time, equals('10:00 AM'));
        expect(appointment.doctor, equals('d1'));
        expect(appointment.doctorName, equals('Dr. Smith'));
        expect(appointment.doctorImage, equals('https://example.com/doctor.jpg'));
        expect(appointment.doctorDepartment, equals('Cardiology'));
        expect(appointment.patient, equals('p1'));
        expect(appointment.patientName, equals('John Doe'));
        expect(appointment.patientImage, equals('https://example.com/patient.jpg'));
        expect(appointment.createdAt, equals('2024-01-10 00:00:00'));
        expect(appointment.updatedAt, equals('2024-01-12 00:00:00'));
      });

      test('should handle completed appointment', () {
        final json = {
          'id': 'apt1',
          'is_completed': true
        };

        final appointment = AppointmentModel.fromJson(json);

        expect(appointment.isCompleted, isTrue);
      });

      test('should handle null and missing fields', () {
        final json = <String, dynamic>{};

        final appointment = AppointmentModel.fromJson(json);

        expect(appointment.id, equals(''));
        expect(appointment.patientId, equals(''));
        expect(appointment.doctorId, equals(''));
        expect(appointment.departmentId, equals(''));
        expect(appointment.opdDate, equals(''));
        expect(appointment.problem, equals(''));
        expect(appointment.isCompleted, isFalse);
        expect(appointment.customField, equals(''));
        expect(appointment.doctorImage, isNull);
        expect(appointment.patientImage, isNull);
      });

      test('should convert custom_field to string', () {
        final json = {
          'id': 'apt1',
          'custom_field': 12345
        };

        final appointment = AppointmentModel.fromJson(json);

        expect(appointment.customField, equals('12345'));
      });

      test('should handle null custom_field', () {
        final json = {
          'id': 'apt1',
          'custom_field': null
        };

        final appointment = AppointmentModel.fromJson(json);

        expect(appointment.customField, equals(''));
      });
    });

    group('toJson', () {
      test('should convert model to JSON correctly', () {
        final appointment = AppointmentModel(
          id: 'apt1',
          patientId: 'p1',
          doctorId: 'd1',
          departmentId: 'dept1',
          opdDate: '2024-01-15',
          problem: 'Headache',
          isCompleted: true,
          customField: 'custom',
          appointmentDate: '2024-01-15',
          appointmentTime: '14:00',
          date: 'Jan 15, 2024',
          time: '2:00 PM',
          doctor: 'd1',
          doctorName: 'Dr. Jane',
          doctorImage: 'https://example.com/doctor.jpg',
          doctorDepartment: 'Neurology',
          patient: 'p1',
          patientName: 'Jane Doe',
          patientImage: 'https://example.com/patient.jpg',
          createdAt: '2024-01-10',
          updatedAt: '2024-01-12',
        );

        final json = appointment.toJson();

        expect(json['id'], equals('apt1'));
        expect(json['patient_id'], equals('p1'));
        expect(json['doctor_id'], equals('d1'));
        expect(json['department_id'], equals('dept1'));
        expect(json['opd_date'], equals('2024-01-15'));
        expect(json['problem'], equals('Headache'));
        expect(json['is_completed'], isTrue);
        expect(json['custom_field'], equals('custom'));
        expect(json['appointment_date'], equals('2024-01-15'));
        expect(json['appointment_time'], equals('14:00'));
        expect(json['date'], equals('Jan 15, 2024'));
        expect(json['time'], equals('2:00 PM'));
        expect(json['doctor'], equals('d1'));
        expect(json['doctor_name'], equals('Dr. Jane'));
        expect(json['doctor_image'], equals('https://example.com/doctor.jpg'));
        expect(json['doctor_department'], equals('Neurology'));
        expect(json['patient'], equals('p1'));
        expect(json['patient_name'], equals('Jane Doe'));
        expect(json['patient_image'], equals('https://example.com/patient.jpg'));
        expect(json['created_at'], equals('2024-01-10'));
        expect(json['updated_at'], equals('2024-01-12'));
      });

      test('should handle null images in toJson', () {
        final appointment = AppointmentModel(
          id: 'apt1',
          patientId: 'p1',
          doctorId: 'd1',
          departmentId: 'dept1',
          opdDate: '2024-01-15',
          problem: 'Headache',
          isCompleted: false,
          customField: '',
          appointmentDate: '2024-01-15',
          appointmentTime: '14:00',
          date: 'Jan 15, 2024',
          time: '2:00 PM',
          doctor: 'd1',
          doctorName: 'Dr. Jane',
          doctorImage: null,
          doctorDepartment: 'Neurology',
          patient: 'p1',
          patientName: 'Jane Doe',
          patientImage: null,
          createdAt: '2024-01-10',
          updatedAt: '2024-01-12',
        );

        final json = appointment.toJson();

        expect(json['doctor_image'], isNull);
        expect(json['patient_image'], isNull);
      });
    });

    group('Roundtrip', () {
      test('should maintain data through fromJson -> toJson cycle', () {
        final originalJson = {
          'id': 'apt1',
          'patient_id': 'p1',
          'doctor_id': 'd1',
          'department_id': 'dept1',
          'opd_date': '2024-01-15',
          'problem': 'Test problem',
          'is_completed': true,
          'custom_field': 'test',
          'appointment_date': '2024-01-15',
          'appointment_time': '10:00',
          'date': 'Jan 15, 2024',
          'time': '10:00 AM',
          'doctor': 'd1',
          'doctor_name': 'Dr. Test',
          'doctor_image': null,
          'doctor_department': 'Test Dept',
          'patient': 'p1',
          'patient_name': 'Test Patient',
          'patient_image': null,
          'created_at': '2024-01-01',
          'updated_at': '2024-01-02'
        };

        final appointment = AppointmentModel.fromJson(originalJson);
        final resultJson = appointment.toJson();

        expect(resultJson['id'], equals(originalJson['id']));
        expect(resultJson['patient_id'], equals(originalJson['patient_id']));
        expect(resultJson['doctor_id'], equals(originalJson['doctor_id']));
        expect(resultJson['problem'], equals(originalJson['problem']));
        expect(resultJson['is_completed'], equals(originalJson['is_completed']));
      });
    });
  });
}
