import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ige_hospital/models/nurse_model.dart';

void main() {
  group('Nurse', () {
    group('fromJson', () {
      test('should parse valid JSON correctly', () {
        final json = {
          'id': 'n1',
          'user_id': 'u1',
          'created_at': '2024-01-01 00:00:00',
          'updated_at': '2024-01-02 00:00:00',
          'user': {
            'first_name': 'Sarah',
            'last_name': 'Johnson',
            'email': 'sarah@hospital.com',
            'phone': '1234567890',
            'gender': 'female',
            'status': 'active',
            'profile_image': 'https://example.com/nurse.jpg',
            'qualification': 'RN, BSN',
            'blood_group': 'A+'
          }
        };

        final nurse = Nurse.fromJson(json);

        expect(nurse.id, equals('n1'));
        expect(nurse.userId, equals('u1'));
        expect(nurse.firstName, equals('Sarah'));
        expect(nurse.lastName, equals('Johnson'));
        expect(nurse.fullName, equals('Sarah Johnson'));
        expect(nurse.email, equals('sarah@hospital.com'));
        expect(nurse.phone, equals('1234567890'));
        expect(nurse.gender, equals('female'));
        expect(nurse.status, equals('active'));
        expect(nurse.profileImage, equals('https://example.com/nurse.jpg'));
        expect(nurse.qualification, equals('RN, BSN'));
        expect(nurse.bloodGroup, equals('A+'));
        expect(nurse.createdAt, equals('2024-01-01 00:00:00'));
        expect(nurse.updatedAt, equals('2024-01-02 00:00:00'));
      });

      test('should handle null user', () {
        final json = {
          'id': 'n1',
          'user_id': 'u1',
          'user': null
        };

        final nurse = Nurse.fromJson(json);

        expect(nurse.firstName, equals(''));
        expect(nurse.lastName, equals(''));
        expect(nurse.email, equals(''));
        expect(nurse.status, equals('active'));
      });

      test('should handle missing fields in user', () {
        final json = {
          'id': 'n1',
          'user_id': 'u1',
          'user': {}
        };

        final nurse = Nurse.fromJson(json);

        expect(nurse.firstName, equals(''));
        expect(nurse.lastName, equals(''));
        expect(nurse.fullName, equals(' '));
        expect(nurse.email, equals(''));
        expect(nurse.phone, equals(''));
        expect(nurse.gender, equals(''));
        expect(nurse.status, equals('active'));
        expect(nurse.profileImage, equals(''));
        expect(nurse.qualification, equals(''));
        expect(nurse.bloodGroup, equals(''));
      });

      test('should handle missing root fields', () {
        final json = <String, dynamic>{};

        final nurse = Nurse.fromJson(json);

        expect(nurse.id, equals(''));
        expect(nurse.userId, equals(''));
        expect(nurse.createdAt, equals(''));
        expect(nurse.updatedAt, equals(''));
      });
    });

    group('fullName getter', () {
      test('should combine first and last name', () {
        final nurse = Nurse(
          id: '1',
          userId: 'u1',
          firstName: 'Mary',
          lastName: 'Williams',
          email: 'mary@example.com',
          phone: '1234567890',
          gender: 'female',
          status: 'active',
          profileImage: '',
          qualification: 'RN',
          bloodGroup: 'O+',
          createdAt: '',
          updatedAt: '',
          user: {},
        );

        expect(nurse.fullName, equals('Mary Williams'));
      });

      test('should handle empty names', () {
        final nurse = Nurse(
          id: '1',
          userId: 'u1',
          firstName: '',
          lastName: '',
          email: '',
          phone: '',
          gender: '',
          status: 'active',
          profileImage: '',
          qualification: '',
          bloodGroup: '',
          createdAt: '',
          updatedAt: '',
          user: {},
        );

        expect(nurse.fullName, equals(' '));
      });
    });

    group('toUpdateJson', () {
      test('should create correct JSON for update', () {
        final nurse = Nurse(
          id: '1',
          userId: 'u1',
          firstName: 'Jane',
          lastName: 'Doe',
          email: 'jane@hospital.com',
          phone: '9876543210',
          gender: 'female',
          status: 'active',
          profileImage: '',
          qualification: 'RN, MSN',
          bloodGroup: 'B+',
          createdAt: '',
          updatedAt: '',
          user: {},
        );

        final json = nurse.toUpdateJson();

        expect(json['first_name'], equals('Jane'));
        expect(json['last_name'], equals('Doe'));
        expect(json['email'], equals('jane@hospital.com'));
        expect(json['phone'], equals('9876543210'));
        expect(json['gender'], equals('female'));
        expect(json['qualification'], equals('RN, MSN'));
        expect(json['status'], equals('active'));
        expect(json['blood_group'], equals('B+'));
        // Should not include id or user_id
        expect(json.containsKey('id'), isFalse);
        expect(json.containsKey('user_id'), isFalse);
      });
    });

    group('getStatusColor', () {
      test('should return green for active status', () {
        expect(Nurse.getStatusColor('active'), equals(Colors.green));
        expect(Nurse.getStatusColor('Active'), equals(Colors.green));
        expect(Nurse.getStatusColor('ACTIVE'), equals(Colors.green));
      });

      test('should return red for blocked status', () {
        expect(Nurse.getStatusColor('blocked'), equals(Colors.red));
        expect(Nurse.getStatusColor('Blocked'), equals(Colors.red));
        expect(Nurse.getStatusColor('BLOCKED'), equals(Colors.red));
      });

      test('should return orange for pending status', () {
        expect(Nurse.getStatusColor('pending'), equals(Colors.orange));
        expect(Nurse.getStatusColor('Pending'), equals(Colors.orange));
        expect(Nurse.getStatusColor('PENDING'), equals(Colors.orange));
      });

      test('should return blue for unknown status', () {
        expect(Nurse.getStatusColor('unknown'), equals(Colors.blue));
        expect(Nurse.getStatusColor('inactive'), equals(Colors.blue));
        expect(Nurse.getStatusColor(''), equals(Colors.blue));
        expect(Nurse.getStatusColor('other'), equals(Colors.blue));
      });
    });

    group('Roundtrip', () {
      test('should maintain data through parse and update', () {
        final originalJson = {
          'id': 'n1',
          'user_id': 'u1',
          'created_at': '2024-01-01',
          'updated_at': '2024-01-02',
          'user': {
            'first_name': 'Test',
            'last_name': 'Nurse',
            'email': 'test@example.com',
            'phone': '5555555555',
            'gender': 'male',
            'status': 'active',
            'profile_image': '',
            'qualification': 'LPN',
            'blood_group': 'AB-'
          }
        };

        final nurse = Nurse.fromJson(originalJson);
        final updateJson = nurse.toUpdateJson();

        expect(updateJson['first_name'], equals('Test'));
        expect(updateJson['last_name'], equals('Nurse'));
        expect(updateJson['email'], equals('test@example.com'));
        expect(updateJson['phone'], equals('5555555555'));
        expect(updateJson['gender'], equals('male'));
        expect(updateJson['status'], equals('active'));
        expect(updateJson['qualification'], equals('LPN'));
        expect(updateJson['blood_group'], equals('AB-'));
      });
    });
  });
}
