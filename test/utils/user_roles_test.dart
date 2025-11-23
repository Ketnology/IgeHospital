import 'package:flutter_test/flutter_test.dart';
import 'package:ige_hospital/constants/user_roles.dart';

void main() {
  group('UserRoles', () {
    group('Constants', () {
      test('should have correct role values', () {
        expect(UserRoles.admin, equals('admin'));
        expect(UserRoles.doctor, equals('doctor'));
        expect(UserRoles.receptionist, equals('receptionist'));
        expect(UserRoles.nurse, equals('receptionist')); // Alias
        expect(UserRoles.patient, equals('patient'));
      });

      test('allRoles should contain all unique roles', () {
        expect(UserRoles.allRoles, contains('admin'));
        expect(UserRoles.allRoles, contains('doctor'));
        expect(UserRoles.allRoles, contains('receptionist'));
        expect(UserRoles.allRoles, contains('patient'));
        expect(UserRoles.allRoles.length, equals(4));
      });

      test('nurse should be alias for receptionist', () {
        expect(UserRoles.nurse, equals(UserRoles.receptionist));
      });
    });

    group('normalizeRole', () {
      test('should normalize admin role', () {
        expect(UserRoles.normalizeRole('admin'), equals('admin'));
        expect(UserRoles.normalizeRole('Admin'), equals('admin'));
        expect(UserRoles.normalizeRole('ADMIN'), equals('admin'));
      });

      test('should normalize doctor role', () {
        expect(UserRoles.normalizeRole('doctor'), equals('doctor'));
        expect(UserRoles.normalizeRole('Doctor'), equals('doctor'));
        expect(UserRoles.normalizeRole('DOCTOR'), equals('doctor'));
      });

      test('should normalize receptionist role', () {
        expect(UserRoles.normalizeRole('receptionist'), equals('receptionist'));
        expect(UserRoles.normalizeRole('Receptionist'), equals('receptionist'));
        expect(UserRoles.normalizeRole('RECEPTIONIST'), equals('receptionist'));
      });

      test('should normalize nurse to receptionist', () {
        expect(UserRoles.normalizeRole('nurse'), equals('receptionist'));
        expect(UserRoles.normalizeRole('Nurse'), equals('receptionist'));
        expect(UserRoles.normalizeRole('NURSE'), equals('receptionist'));
      });

      test('should normalize patient role', () {
        expect(UserRoles.normalizeRole('patient'), equals('patient'));
        expect(UserRoles.normalizeRole('Patient'), equals('patient'));
        expect(UserRoles.normalizeRole('PATIENT'), equals('patient'));
      });

      test('should return lowercase for unknown roles', () {
        expect(UserRoles.normalizeRole('unknown'), equals('unknown'));
        expect(UserRoles.normalizeRole('Unknown'), equals('unknown'));
        expect(UserRoles.normalizeRole('UNKNOWN'), equals('unknown'));
        expect(UserRoles.normalizeRole('Manager'), equals('manager'));
      });

      test('should handle empty string', () {
        expect(UserRoles.normalizeRole(''), equals(''));
      });

      test('should handle roles with whitespace', () {
        // Note: This tests actual behavior - whitespace is not trimmed
        expect(UserRoles.normalizeRole(' admin'), equals(' admin'));
        expect(UserRoles.normalizeRole('admin '), equals('admin '));
      });
    });
  });
}
