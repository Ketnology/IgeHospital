import 'package:flutter_test/flutter_test.dart';
import 'package:ige_hospital/constants/permissions.dart';

void main() {
  group('Permissions', () {
    group('Dashboard permissions', () {
      test('should have correct dashboard permission values', () {
        expect(Permissions.viewDashboard, equals('view_dashboard'));
        expect(Permissions.viewAnalytics, equals('view_analytics'));
      });
    });

    group('Patient permissions', () {
      test('should have correct patient permission values', () {
        expect(Permissions.viewPatients, equals('view_patients'));
        expect(Permissions.createPatients, equals('create_patients'));
        expect(Permissions.editPatients, equals('edit_patients'));
        expect(Permissions.deletePatients, equals('delete_patients'));
        expect(Permissions.viewOwnProfile, equals('view_own_profile'));
      });
    });

    group('Doctor permissions', () {
      test('should have correct doctor permission values', () {
        expect(Permissions.viewDoctors, equals('view_doctors'));
        expect(Permissions.createDoctors, equals('create_doctors'));
        expect(Permissions.editDoctors, equals('edit_doctors'));
        expect(Permissions.deleteDoctors, equals('delete_doctors'));
      });
    });

    group('Nurse permissions', () {
      test('should have correct nurse permission values', () {
        expect(Permissions.viewNurses, equals('view_nurses'));
        expect(Permissions.createNurses, equals('create_nurses'));
        expect(Permissions.editNurses, equals('edit_nurses'));
        expect(Permissions.deleteNurses, equals('delete_nurses'));
      });
    });

    group('Admin permissions', () {
      test('should have correct admin permission values', () {
        expect(Permissions.viewAdmins, equals('view_admins'));
        expect(Permissions.createAdmins, equals('create_admins'));
        expect(Permissions.editAdmins, equals('edit_admins'));
        expect(Permissions.deleteAdmins, equals('delete_admins'));
      });
    });

    group('Appointment permissions', () {
      test('should have correct appointment permission values', () {
        expect(Permissions.viewAppointments, equals('view_appointments'));
        expect(Permissions.createAppointments, equals('create_appointments'));
        expect(Permissions.editAppointments, equals('edit_appointments'));
        expect(Permissions.deleteAppointments, equals('delete_appointments'));
        expect(Permissions.viewOwnAppointments, equals('view_own_appointments'));
      });
    });

    group('Consultation permissions', () {
      test('should have correct consultation permission values', () {
        expect(Permissions.viewConsultations, equals('view_consultations'));
        expect(Permissions.createConsultations, equals('create_consultations'));
        expect(Permissions.editConsultations, equals('edit_consultations'));
        expect(Permissions.deleteConsultations, equals('delete_consultations'));
        expect(Permissions.joinConsultations, equals('join_consultations'));
        expect(Permissions.startConsultations, equals('start_consultations'));
        expect(Permissions.endConsultations, equals('end_consultations'));
      });
    });

    group('Accounting permissions', () {
      test('should have correct accounting permission values', () {
        expect(Permissions.viewAccounting, equals('view_accounting'));
        expect(Permissions.createAccounting, equals('create_accounting'));
        expect(Permissions.editAccounting, equals('edit_accounting'));
        expect(Permissions.deleteAccounting, equals('delete_accounting'));
      });
    });

    group('System permissions', () {
      test('should have correct system permission values', () {
        expect(Permissions.viewSystemSettings, equals('view_system_settings'));
        expect(Permissions.editSystemSettings, equals('edit_system_settings'));
      });
    });

    group('Vital Signs permissions', () {
      test('should have correct vital signs permission values', () {
        expect(Permissions.viewVitalSigns, equals('view_vital_signs'));
        expect(Permissions.createVitalSigns, equals('create_vital_signs'));
        expect(Permissions.editVitalSigns, equals('edit_vital_signs'));
        expect(Permissions.deleteVitalSigns, equals('delete_vital_signs'));
      });
    });

    group('Permission naming conventions', () {
      test('all permissions should follow snake_case naming convention', () {
        final allPermissions = [
          Permissions.viewDashboard,
          Permissions.viewAnalytics,
          Permissions.viewPatients,
          Permissions.createPatients,
          Permissions.editPatients,
          Permissions.deletePatients,
          Permissions.viewOwnProfile,
          Permissions.viewDoctors,
          Permissions.createDoctors,
          Permissions.editDoctors,
          Permissions.deleteDoctors,
          Permissions.viewNurses,
          Permissions.createNurses,
          Permissions.editNurses,
          Permissions.deleteNurses,
          Permissions.viewAdmins,
          Permissions.createAdmins,
          Permissions.editAdmins,
          Permissions.deleteAdmins,
          Permissions.viewAppointments,
          Permissions.createAppointments,
          Permissions.editAppointments,
          Permissions.deleteAppointments,
          Permissions.viewOwnAppointments,
          Permissions.viewConsultations,
          Permissions.createConsultations,
          Permissions.editConsultations,
          Permissions.deleteConsultations,
          Permissions.joinConsultations,
          Permissions.startConsultations,
          Permissions.endConsultations,
          Permissions.viewAccounting,
          Permissions.createAccounting,
          Permissions.editAccounting,
          Permissions.deleteAccounting,
          Permissions.viewSystemSettings,
          Permissions.editSystemSettings,
          Permissions.viewVitalSigns,
          Permissions.createVitalSigns,
          Permissions.editVitalSigns,
          Permissions.deleteVitalSigns,
        ];

        for (final permission in allPermissions) {
          // Check snake_case: only lowercase letters and underscores
          expect(
            RegExp(r'^[a-z_]+$').hasMatch(permission),
            isTrue,
            reason: 'Permission "$permission" should be in snake_case',
          );
        }
      });

      test('all permissions should be unique', () {
        final allPermissions = [
          Permissions.viewDashboard,
          Permissions.viewAnalytics,
          Permissions.viewPatients,
          Permissions.createPatients,
          Permissions.editPatients,
          Permissions.deletePatients,
          Permissions.viewOwnProfile,
          Permissions.viewDoctors,
          Permissions.createDoctors,
          Permissions.editDoctors,
          Permissions.deleteDoctors,
          Permissions.viewNurses,
          Permissions.createNurses,
          Permissions.editNurses,
          Permissions.deleteNurses,
          Permissions.viewAdmins,
          Permissions.createAdmins,
          Permissions.editAdmins,
          Permissions.deleteAdmins,
          Permissions.viewAppointments,
          Permissions.createAppointments,
          Permissions.editAppointments,
          Permissions.deleteAppointments,
          Permissions.viewOwnAppointments,
          Permissions.viewConsultations,
          Permissions.createConsultations,
          Permissions.editConsultations,
          Permissions.deleteConsultations,
          Permissions.joinConsultations,
          Permissions.startConsultations,
          Permissions.endConsultations,
          Permissions.viewAccounting,
          Permissions.createAccounting,
          Permissions.editAccounting,
          Permissions.deleteAccounting,
          Permissions.viewSystemSettings,
          Permissions.editSystemSettings,
          Permissions.viewVitalSigns,
          Permissions.createVitalSigns,
          Permissions.editVitalSigns,
          Permissions.deleteVitalSigns,
        ];

        final uniquePermissions = allPermissions.toSet();
        expect(
          uniquePermissions.length,
          equals(allPermissions.length),
          reason: 'All permissions should be unique',
        );
      });
    });
  });
}
