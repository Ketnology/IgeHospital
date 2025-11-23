import 'package:flutter_test/flutter_test.dart';
import 'package:ige_hospital/utils/role_permissions.dart';
import 'package:ige_hospital/constants/permissions.dart';
import 'package:ige_hospital/constants/user_roles.dart';

void main() {
  group('RolePermissions', () {
    group('getPermissionsForRole', () {
      test('admin should have all permissions', () {
        final permissions = RolePermissions.getPermissionsForRole(UserRoles.admin);

        // Dashboard
        expect(permissions, contains(Permissions.viewDashboard));
        expect(permissions, contains(Permissions.viewAnalytics));

        // Patients
        expect(permissions, contains(Permissions.viewPatients));
        expect(permissions, contains(Permissions.createPatients));
        expect(permissions, contains(Permissions.editPatients));
        expect(permissions, contains(Permissions.deletePatients));

        // Doctors
        expect(permissions, contains(Permissions.viewDoctors));
        expect(permissions, contains(Permissions.createDoctors));
        expect(permissions, contains(Permissions.editDoctors));
        expect(permissions, contains(Permissions.deleteDoctors));

        // Nurses
        expect(permissions, contains(Permissions.viewNurses));
        expect(permissions, contains(Permissions.createNurses));
        expect(permissions, contains(Permissions.editNurses));
        expect(permissions, contains(Permissions.deleteNurses));

        // Admins
        expect(permissions, contains(Permissions.viewAdmins));
        expect(permissions, contains(Permissions.createAdmins));
        expect(permissions, contains(Permissions.editAdmins));
        expect(permissions, contains(Permissions.deleteAdmins));

        // Appointments
        expect(permissions, contains(Permissions.viewAppointments));
        expect(permissions, contains(Permissions.createAppointments));
        expect(permissions, contains(Permissions.editAppointments));
        expect(permissions, contains(Permissions.deleteAppointments));

        // Consultations
        expect(permissions, contains(Permissions.viewConsultations));
        expect(permissions, contains(Permissions.createConsultations));
        expect(permissions, contains(Permissions.editConsultations));
        expect(permissions, contains(Permissions.deleteConsultations));
        expect(permissions, contains(Permissions.joinConsultations));
        expect(permissions, contains(Permissions.startConsultations));
        expect(permissions, contains(Permissions.endConsultations));

        // Accounting
        expect(permissions, contains(Permissions.viewAccounting));
        expect(permissions, contains(Permissions.createAccounting));
        expect(permissions, contains(Permissions.editAccounting));
        expect(permissions, contains(Permissions.deleteAccounting));

        // System
        expect(permissions, contains(Permissions.viewSystemSettings));
        expect(permissions, contains(Permissions.editSystemSettings));

        // Profile
        expect(permissions, contains(Permissions.viewOwnProfile));
        expect(permissions, contains(Permissions.viewOwnAppointments));
      });

      test('doctor should have appropriate permissions', () {
        final permissions = RolePermissions.getPermissionsForRole(UserRoles.doctor);

        // Should have
        expect(permissions, contains(Permissions.viewDashboard));
        expect(permissions, contains(Permissions.viewPatients));
        expect(permissions, contains(Permissions.editPatients));
        expect(permissions, contains(Permissions.viewAppointments));
        expect(permissions, contains(Permissions.createAppointments));
        expect(permissions, contains(Permissions.editAppointments));
        expect(permissions, contains(Permissions.viewOwnAppointments));
        expect(permissions, contains(Permissions.viewConsultations));
        expect(permissions, contains(Permissions.createConsultations));
        expect(permissions, contains(Permissions.editConsultations));
        expect(permissions, contains(Permissions.joinConsultations));
        expect(permissions, contains(Permissions.startConsultations));
        expect(permissions, contains(Permissions.endConsultations));
        expect(permissions, contains(Permissions.viewOwnProfile));

        // Should NOT have
        expect(permissions, isNot(contains(Permissions.deletePatients)));
        expect(permissions, isNot(contains(Permissions.createPatients)));
        expect(permissions, isNot(contains(Permissions.viewDoctors)));
        expect(permissions, isNot(contains(Permissions.viewNurses)));
        expect(permissions, isNot(contains(Permissions.viewAdmins)));
        expect(permissions, isNot(contains(Permissions.viewAccounting)));
        expect(permissions, isNot(contains(Permissions.deleteConsultations)));
        expect(permissions, isNot(contains(Permissions.viewSystemSettings)));
      });

      test('receptionist should have appropriate permissions', () {
        final permissions = RolePermissions.getPermissionsForRole(UserRoles.receptionist);

        // Should have
        expect(permissions, contains(Permissions.viewDashboard));
        expect(permissions, contains(Permissions.viewPatients));
        expect(permissions, contains(Permissions.createPatients));
        expect(permissions, contains(Permissions.editPatients));
        expect(permissions, contains(Permissions.viewConsultations));
        expect(permissions, contains(Permissions.joinConsultations));
        expect(permissions, contains(Permissions.viewOwnProfile));

        // Should NOT have
        expect(permissions, isNot(contains(Permissions.deletePatients)));
        expect(permissions, isNot(contains(Permissions.viewAppointments)));
        expect(permissions, isNot(contains(Permissions.createAppointments)));
        expect(permissions, isNot(contains(Permissions.viewDoctors)));
        expect(permissions, isNot(contains(Permissions.viewNurses)));
        expect(permissions, isNot(contains(Permissions.viewAdmins)));
        expect(permissions, isNot(contains(Permissions.viewAccounting)));
        expect(permissions, isNot(contains(Permissions.startConsultations)));
        expect(permissions, isNot(contains(Permissions.endConsultations)));
      });

      test('nurse role should be normalized to receptionist', () {
        final nursePermissions = RolePermissions.getPermissionsForRole('nurse');
        final receptionistPermissions = RolePermissions.getPermissionsForRole(UserRoles.receptionist);

        expect(nursePermissions, equals(receptionistPermissions));
      });

      test('patient should have limited permissions', () {
        final permissions = RolePermissions.getPermissionsForRole(UserRoles.patient);

        // Should have
        expect(permissions, contains(Permissions.viewDashboard));
        expect(permissions, contains(Permissions.viewOwnProfile));
        expect(permissions, contains(Permissions.viewOwnAppointments));
        expect(permissions, contains(Permissions.createAppointments));
        expect(permissions, contains(Permissions.joinConsultations));

        // Should NOT have
        expect(permissions, isNot(contains(Permissions.viewPatients)));
        expect(permissions, isNot(contains(Permissions.viewDoctors)));
        expect(permissions, isNot(contains(Permissions.viewNurses)));
        expect(permissions, isNot(contains(Permissions.viewAdmins)));
        expect(permissions, isNot(contains(Permissions.viewAccounting)));
        expect(permissions, isNot(contains(Permissions.viewConsultations)));
        expect(permissions, isNot(contains(Permissions.startConsultations)));
        expect(permissions, isNot(contains(Permissions.endConsultations)));
        expect(permissions, isNot(contains(Permissions.editPatients)));
        expect(permissions, isNot(contains(Permissions.deletePatients)));
      });

      test('unknown role should return empty permissions', () {
        final permissions = RolePermissions.getPermissionsForRole('unknown_role');

        expect(permissions, isEmpty);
      });

      test('should handle case-insensitive role names', () {
        final adminLower = RolePermissions.getPermissionsForRole('admin');
        final adminUpper = RolePermissions.getPermissionsForRole('ADMIN');
        final adminMixed = RolePermissions.getPermissionsForRole('Admin');

        expect(adminLower, equals(adminUpper));
        expect(adminLower, equals(adminMixed));
      });
    });

    group('hasPermission', () {
      test('admin should have all permissions', () {
        expect(RolePermissions.hasPermission(UserRoles.admin, Permissions.viewDashboard), isTrue);
        expect(RolePermissions.hasPermission(UserRoles.admin, Permissions.deletePatients), isTrue);
        expect(RolePermissions.hasPermission(UserRoles.admin, Permissions.viewAccounting), isTrue);
        expect(RolePermissions.hasPermission(UserRoles.admin, Permissions.editSystemSettings), isTrue);
      });

      test('doctor should have correct permissions', () {
        expect(RolePermissions.hasPermission(UserRoles.doctor, Permissions.viewPatients), isTrue);
        expect(RolePermissions.hasPermission(UserRoles.doctor, Permissions.startConsultations), isTrue);
        expect(RolePermissions.hasPermission(UserRoles.doctor, Permissions.deletePatients), isFalse);
        expect(RolePermissions.hasPermission(UserRoles.doctor, Permissions.viewAccounting), isFalse);
      });

      test('receptionist should have correct permissions', () {
        expect(RolePermissions.hasPermission(UserRoles.receptionist, Permissions.viewPatients), isTrue);
        expect(RolePermissions.hasPermission(UserRoles.receptionist, Permissions.createPatients), isTrue);
        expect(RolePermissions.hasPermission(UserRoles.receptionist, Permissions.viewAppointments), isFalse);
        expect(RolePermissions.hasPermission(UserRoles.receptionist, Permissions.startConsultations), isFalse);
      });

      test('patient should have correct permissions', () {
        expect(RolePermissions.hasPermission(UserRoles.patient, Permissions.viewOwnProfile), isTrue);
        expect(RolePermissions.hasPermission(UserRoles.patient, Permissions.createAppointments), isTrue);
        expect(RolePermissions.hasPermission(UserRoles.patient, Permissions.joinConsultations), isTrue);
        expect(RolePermissions.hasPermission(UserRoles.patient, Permissions.viewPatients), isFalse);
        expect(RolePermissions.hasPermission(UserRoles.patient, Permissions.editPatients), isFalse);
      });

      test('unknown role should have no permissions', () {
        expect(RolePermissions.hasPermission('unknown', Permissions.viewDashboard), isFalse);
        expect(RolePermissions.hasPermission('unknown', Permissions.viewPatients), isFalse);
      });
    });

    group('hasAnyPermission', () {
      test('should return true when user has at least one permission', () {
        expect(
          RolePermissions.hasAnyPermission(
            UserRoles.doctor,
            [Permissions.viewPatients, Permissions.viewDoctors],
          ),
          isTrue,
        );

        expect(
          RolePermissions.hasAnyPermission(
            UserRoles.patient,
            [Permissions.viewPatients, Permissions.joinConsultations],
          ),
          isTrue,
        );
      });

      test('should return false when user has none of the permissions', () {
        expect(
          RolePermissions.hasAnyPermission(
            UserRoles.patient,
            [Permissions.viewPatients, Permissions.editPatients],
          ),
          isFalse,
        );

        expect(
          RolePermissions.hasAnyPermission(
            UserRoles.receptionist,
            [Permissions.viewAccounting, Permissions.startConsultations],
          ),
          isFalse,
        );
      });

      test('should return false for empty permissions list', () {
        expect(
          RolePermissions.hasAnyPermission(UserRoles.admin, []),
          isFalse,
        );
      });
    });

    group('hasAllPermissions', () {
      test('should return true when user has all permissions', () {
        expect(
          RolePermissions.hasAllPermissions(
            UserRoles.admin,
            [Permissions.viewPatients, Permissions.editPatients, Permissions.deletePatients],
          ),
          isTrue,
        );

        expect(
          RolePermissions.hasAllPermissions(
            UserRoles.doctor,
            [Permissions.viewPatients, Permissions.editPatients],
          ),
          isTrue,
        );
      });

      test('should return false when user is missing any permission', () {
        expect(
          RolePermissions.hasAllPermissions(
            UserRoles.doctor,
            [Permissions.viewPatients, Permissions.deletePatients],
          ),
          isFalse,
        );

        expect(
          RolePermissions.hasAllPermissions(
            UserRoles.patient,
            [Permissions.viewOwnProfile, Permissions.viewPatients],
          ),
          isFalse,
        );
      });

      test('should return true for empty permissions list', () {
        expect(
          RolePermissions.hasAllPermissions(UserRoles.patient, []),
          isTrue,
        );
      });

      test('receptionist should have all patient management permissions except delete', () {
        expect(
          RolePermissions.hasAllPermissions(
            UserRoles.receptionist,
            [Permissions.viewPatients, Permissions.createPatients, Permissions.editPatients],
          ),
          isTrue,
        );

        expect(
          RolePermissions.hasAllPermissions(
            UserRoles.receptionist,
            [Permissions.viewPatients, Permissions.createPatients, Permissions.deletePatients],
          ),
          isFalse,
        );
      });
    });

    group('Role-specific permission tests', () {
      test('only admin should have system settings permissions', () {
        for (final role in UserRoles.allRoles) {
          if (role == UserRoles.admin) {
            expect(RolePermissions.hasPermission(role, Permissions.viewSystemSettings), isTrue);
            expect(RolePermissions.hasPermission(role, Permissions.editSystemSettings), isTrue);
          } else {
            expect(RolePermissions.hasPermission(role, Permissions.viewSystemSettings), isFalse);
            expect(RolePermissions.hasPermission(role, Permissions.editSystemSettings), isFalse);
          }
        }
      });

      test('only admin should have accounting permissions', () {
        for (final role in UserRoles.allRoles) {
          if (role == UserRoles.admin) {
            expect(RolePermissions.hasPermission(role, Permissions.viewAccounting), isTrue);
          } else {
            expect(RolePermissions.hasPermission(role, Permissions.viewAccounting), isFalse);
          }
        }
      });

      test('only admin and doctor should be able to start consultations', () {
        expect(RolePermissions.hasPermission(UserRoles.admin, Permissions.startConsultations), isTrue);
        expect(RolePermissions.hasPermission(UserRoles.doctor, Permissions.startConsultations), isTrue);
        expect(RolePermissions.hasPermission(UserRoles.receptionist, Permissions.startConsultations), isFalse);
        expect(RolePermissions.hasPermission(UserRoles.patient, Permissions.startConsultations), isFalse);
      });

      test('all roles should have viewDashboard permission', () {
        for (final role in UserRoles.allRoles) {
          expect(RolePermissions.hasPermission(role, Permissions.viewDashboard), isTrue);
        }
      });

      test('all roles should have viewOwnProfile permission', () {
        for (final role in UserRoles.allRoles) {
          expect(RolePermissions.hasPermission(role, Permissions.viewOwnProfile), isTrue);
        }
      });
    });
  });
}
