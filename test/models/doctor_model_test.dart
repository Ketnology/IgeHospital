import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ige_hospital/models/doctor_model.dart';

void main() {
  group('DoctorStats', () {
    test('fromJson should parse correctly', () {
      final json = {
        'appointments_count': '15',
        'schedules_count': '5'
      };

      final stats = DoctorStats.fromJson(json);

      expect(stats.appointmentsCount, equals(15));
      expect(stats.schedulesCount, equals(5));
    });

    test('fromJson should handle integer values', () {
      final json = {
        'appointments_count': 20,
        'schedules_count': 10
      };

      final stats = DoctorStats.fromJson(json);

      expect(stats.appointmentsCount, equals(20));
      expect(stats.schedulesCount, equals(10));
    });

    test('fromJson should handle null', () {
      final stats = DoctorStats.fromJson(null);

      expect(stats.appointmentsCount, equals(0));
      expect(stats.schedulesCount, equals(0));
    });

    test('fromJson should handle missing fields', () {
      final json = <String, dynamic>{};

      final stats = DoctorStats.fromJson(json);

      expect(stats.appointmentsCount, equals(0));
      expect(stats.schedulesCount, equals(0));
    });

    test('toJson should convert correctly', () {
      final stats = DoctorStats(
        appointmentsCount: 25,
        schedulesCount: 7,
      );

      final json = stats.toJson();

      expect(json['appointments_count'], equals(25));
      expect(json['schedules_count'], equals(7));
    });
  });

  group('AppointmentShort', () {
    test('fromJson should parse correctly', () {
      final json = {
        'id': 'apt1',
        'patient_name': 'John Doe',
        'appointment_date': '2024-01-15',
        'appointment_time': '10:00',
        'problem': 'Chest pain',
        'is_completed': true
      };

      final appointment = AppointmentShort.fromJson(json);

      expect(appointment.id, equals('apt1'));
      expect(appointment.patientName, equals('John Doe'));
      expect(appointment.date, equals('2024-01-15'));
      expect(appointment.time, equals('10:00'));
      expect(appointment.problem, equals('Chest pain'));
      expect(appointment.isCompleted, isTrue);
    });

    test('fromJson should use fallback keys', () {
      final json = {
        'id': 'apt1',
        'patient_name': 'Jane Doe',
        'date': '2024-01-16',
        'time': '11:00',
        'problem': 'Headache',
        'is_completed': false
      };

      final appointment = AppointmentShort.fromJson(json);

      expect(appointment.date, equals('2024-01-16'));
      expect(appointment.time, equals('11:00'));
    });

    test('fromJson should handle missing fields', () {
      final json = <String, dynamic>{};

      final appointment = AppointmentShort.fromJson(json);

      expect(appointment.id, equals(''));
      expect(appointment.patientName, equals('Unknown Patient'));
      expect(appointment.date, equals('No date'));
      expect(appointment.time, equals('No time'));
      expect(appointment.problem, equals(''));
      expect(appointment.isCompleted, isFalse);
    });
  });

  group('ScheduleDay', () {
    test('fromJson should parse correctly', () {
      final json = {
        'available_on': 'Monday',
        'available_from': '09:00',
        'available_to': '17:00'
      };

      final scheduleDay = ScheduleDay.fromJson(json);

      expect(scheduleDay.day, equals('Monday'));
      expect(scheduleDay.timeFrom, equals('09:00'));
      expect(scheduleDay.timeTo, equals('17:00'));
    });

    test('fromJson should handle missing fields', () {
      final json = <String, dynamic>{};

      final scheduleDay = ScheduleDay.fromJson(json);

      expect(scheduleDay.day, equals(''));
      expect(scheduleDay.timeFrom, equals(''));
      expect(scheduleDay.timeTo, equals(''));
    });
  });

  group('Schedule', () {
    test('fromJson should parse correctly', () {
      final json = {
        'id': 'sch1',
        'per_patient_time': '30',
        'schedule_days': [
          {
            'available_on': 'Monday',
            'available_from': '09:00',
            'available_to': '17:00'
          },
          {
            'available_on': 'Wednesday',
            'available_from': '10:00',
            'available_to': '16:00'
          }
        ]
      };

      final schedule = Schedule.fromJson(json);

      expect(schedule.id, equals('sch1'));
      expect(schedule.perPatientTime, equals('30'));
      expect(schedule.days.length, equals(2));
      expect(schedule.days[0].day, equals('Monday'));
      expect(schedule.days[1].day, equals('Wednesday'));
    });

    test('fromJson should handle empty schedule days', () {
      final json = {
        'id': 'sch1',
        'per_patient_time': '30',
        'schedule_days': []
      };

      final schedule = Schedule.fromJson(json);

      expect(schedule.days, isEmpty);
    });

    test('fromJson should handle null schedule days', () {
      final json = {
        'id': 'sch1',
        'per_patient_time': '30',
        'schedule_days': null
      };

      final schedule = Schedule.fromJson(json);

      expect(schedule.days, isEmpty);
    });
  });

  group('Doctora', () {
    test('fromJson should parse correctly', () {
      final json = {
        'id': 'd1',
        'user_id': 'u1',
        'department_id': 'dept1',
        'specialist': 'Cardiology',
        'description': 'Experienced cardiologist',
        'created_at': '2024-01-01 00:00:00',
        'updated_at': '2024-01-02 00:00:00',
        'user': {
          'first_name': 'Jane',
          'last_name': 'Smith',
          'email': 'jane@hospital.com',
          'phone': '1234567890',
          'gender': 'female',
          'status': 'active',
          'profile_image': 'https://example.com/image.jpg',
          'qualification': 'MD, FACC',
          'blood_group': 'O+'
        },
        'department': {
          'title': 'Cardiology Department'
        },
        'stats': {
          'appointments_count': '50',
          'schedules_count': '10'
        },
        'appointments': [
          {
            'id': 'apt1',
            'patient_name': 'John Doe',
            'appointment_date': '2024-01-15',
            'appointment_time': '10:00',
            'problem': 'Check-up',
            'is_completed': false
          }
        ],
        'schedules': [
          {
            'id': 'sch1',
            'per_patient_time': '30',
            'schedule_days': [
              {'available_on': 'Monday', 'available_from': '09:00', 'available_to': '17:00'}
            ]
          }
        ]
      };

      final doctor = Doctora.fromJson(json);

      expect(doctor.id, equals('d1'));
      expect(doctor.userId, equals('u1'));
      expect(doctor.firstName, equals('Jane'));
      expect(doctor.lastName, equals('Smith'));
      expect(doctor.fullName, equals('Jane Smith'));
      expect(doctor.email, equals('jane@hospital.com'));
      expect(doctor.phone, equals('1234567890'));
      expect(doctor.gender, equals('female'));
      expect(doctor.department, equals('Cardiology Department'));
      expect(doctor.departmentId, equals('dept1'));
      expect(doctor.specialty, equals('Cardiology'));
      expect(doctor.status, equals('active'));
      expect(doctor.profileImage, equals('https://example.com/image.jpg'));
      expect(doctor.qualification, equals('MD, FACC'));
      expect(doctor.bloodGroup, equals('O+'));
      expect(doctor.stats.appointmentsCount, equals(50));
      expect(doctor.appointments.length, equals(1));
      expect(doctor.schedules.length, equals(1));
    });

    test('fromJson should handle missing user and department', () {
      final json = {
        'id': 'd1',
        'user': null,
        'department': null
      };

      final doctor = Doctora.fromJson(json);

      expect(doctor.id, equals('d1'));
      expect(doctor.firstName, equals(''));
      expect(doctor.lastName, equals(''));
      expect(doctor.fullName, equals(' '));
      expect(doctor.email, equals(''));
      expect(doctor.department, equals(''));
      expect(doctor.status, equals('active'));
    });

    test('fromJson should handle empty appointments and schedules', () {
      final json = {
        'id': 'd1',
        'appointments': null,
        'schedules': null
      };

      final doctor = Doctora.fromJson(json);

      expect(doctor.appointments, isEmpty);
      expect(doctor.schedules, isEmpty);
    });

    test('fullName getter should combine first and last name', () {
      final doctor = Doctora(
        id: '1',
        userId: 'u1',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
        phone: '1234567890',
        gender: 'male',
        department: 'Cardiology',
        departmentId: 'd1',
        specialty: 'Heart',
        status: 'active',
        profileImage: '',
        qualification: 'MD',
        description: '',
        bloodGroup: 'O+',
        createdAt: '',
        updatedAt: '',
        user: {},
        departmentData: {},
        stats: DoctorStats(),
        appointments: [],
        schedules: [],
      );

      expect(doctor.fullName, equals('John Doe'));
    });

    test('toUpdateJson should create correct JSON', () {
      final doctor = Doctora(
        id: '1',
        userId: 'u1',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
        phone: '1234567890',
        gender: 'male',
        department: 'Cardiology',
        departmentId: 'dept1',
        specialty: 'Heart',
        status: 'active',
        profileImage: '',
        qualification: 'MD',
        description: 'Test description',
        bloodGroup: 'O+',
        createdAt: '',
        updatedAt: '',
        user: {},
        departmentData: {},
        stats: DoctorStats(),
        appointments: [],
        schedules: [],
      );

      final json = doctor.toUpdateJson();

      expect(json['first_name'], equals('John'));
      expect(json['last_name'], equals('Doe'));
      expect(json['email'], equals('john@example.com'));
      expect(json['phone'], equals('1234567890'));
      expect(json['gender'], equals('male'));
      expect(json['doctor_department_id'], equals('dept1'));
      expect(json['specialist'], equals('Heart'));
      expect(json['qualification'], equals('MD'));
      expect(json['description'], equals('Test description'));
      expect(json['status'], equals('active'));
      expect(json['blood_group'], equals('O+'));
    });

    group('getStatusColor', () {
      test('should return green for active status', () {
        expect(Doctora.getStatusColor('active'), equals(Colors.green));
        expect(Doctora.getStatusColor('Active'), equals(Colors.green));
        expect(Doctora.getStatusColor('ACTIVE'), equals(Colors.green));
      });

      test('should return red for blocked status', () {
        expect(Doctora.getStatusColor('blocked'), equals(Colors.red));
        expect(Doctora.getStatusColor('Blocked'), equals(Colors.red));
      });

      test('should return orange for pending status', () {
        expect(Doctora.getStatusColor('pending'), equals(Colors.orange));
        expect(Doctora.getStatusColor('Pending'), equals(Colors.orange));
      });

      test('should return blue for unknown status', () {
        expect(Doctora.getStatusColor('unknown'), equals(Colors.blue));
        expect(Doctora.getStatusColor('other'), equals(Colors.blue));
      });
    });
  });
}
