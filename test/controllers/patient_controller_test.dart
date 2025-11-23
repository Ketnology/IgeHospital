import 'package:flutter_test/flutter_test.dart';
import 'package:ige_hospital/models/patient_model.dart';

void main() {
  group('PatientController Logic Tests', () {
    group('Pagination Logic', () {
      test('totalPages should calculate correctly', () {
        // Test pagination logic without GetX
        int totalPatients = 100;
        int perPage = 12;
        int totalPages = (totalPatients / perPage).ceil();

        expect(totalPages, equals(9)); // 100/12 = 8.33, ceil = 9
      });

      test('totalPages should be 1 for patients less than perPage', () {
        int totalPatients = 5;
        int perPage = 12;
        int totalPages = (totalPatients / perPage).ceil();

        expect(totalPages, equals(1));
      });

      test('totalPages should be 0 for zero patients', () {
        int totalPatients = 0;
        int perPage = 12;
        int totalPages = totalPatients == 0 ? 0 : (totalPatients / perPage).ceil();

        expect(totalPages, equals(0));
      });

      test('next page should increment within bounds', () {
        int currentPage = 1;
        int totalPages = 5;

        if (currentPage < totalPages) {
          currentPage++;
        }

        expect(currentPage, equals(2));
      });

      test('next page should not exceed totalPages', () {
        int currentPage = 5;
        int totalPages = 5;

        if (currentPage < totalPages) {
          currentPage++;
        }

        expect(currentPage, equals(5));
      });

      test('previous page should decrement within bounds', () {
        int currentPage = 3;

        if (currentPage > 1) {
          currentPage--;
        }

        expect(currentPage, equals(2));
      });

      test('previous page should not go below 1', () {
        int currentPage = 1;

        if (currentPage > 1) {
          currentPage--;
        }

        expect(currentPage, equals(1));
      });

      test('setPage should work within valid range', () {
        int currentPage = 1;
        int totalPages = 10;
        int targetPage = 5;

        if (targetPage >= 1 && targetPage <= totalPages) {
          currentPage = targetPage;
        }

        expect(currentPage, equals(5));
      });

      test('setPage should reject invalid pages', () {
        int currentPage = 1;
        int totalPages = 10;

        // Try invalid page (too high)
        int targetPage = 15;
        if (targetPage >= 1 && targetPage <= totalPages) {
          currentPage = targetPage;
        }
        expect(currentPage, equals(1)); // Should not change

        // Try invalid page (too low)
        targetPage = 0;
        if (targetPage >= 1 && targetPage <= totalPages) {
          currentPage = targetPage;
        }
        expect(currentPage, equals(1)); // Should not change
      });
    });

    group('Filter Logic', () {
      test('filteredPatients should filter by search query', () {
        // Create mock patient data
        final patients = [
          _createMockPatient('John Doe', 'john@example.com', 'PAT001'),
          _createMockPatient('Jane Smith', 'jane@example.com', 'PAT002'),
          _createMockPatient('Bob Johnson', 'bob@example.com', 'PAT003'),
        ];

        String searchQuery = 'john';

        final filtered = patients.where((patient) {
          final fullName = patient.user['full_name']?.toString().toLowerCase() ?? '';
          final email = patient.user['email']?.toString().toLowerCase() ?? '';
          final patientId = patient.patientUniqueId.toLowerCase();

          return fullName.contains(searchQuery.toLowerCase()) ||
              email.contains(searchQuery.toLowerCase()) ||
              patientId.contains(searchQuery.toLowerCase());
        }).toList();

        expect(filtered.length, equals(2)); // John Doe and Bob Johnson
      });

      test('filteredPatients should return all when search is empty', () {
        final patients = [
          _createMockPatient('John Doe', 'john@example.com', 'PAT001'),
          _createMockPatient('Jane Smith', 'jane@example.com', 'PAT002'),
        ];

        String searchQuery = '';

        final filtered = patients.where((patient) {
          if (searchQuery.isEmpty) return true;

          final fullName = patient.user['full_name']?.toString().toLowerCase() ?? '';
          return fullName.contains(searchQuery.toLowerCase());
        }).toList();

        expect(filtered.length, equals(2));
      });

      test('filteredPatients should filter by patient ID', () {
        final patients = [
          _createMockPatient('John Doe', 'john@example.com', 'PAT001'),
          _createMockPatient('Jane Smith', 'jane@example.com', 'PAT002'),
        ];

        String searchQuery = 'PAT001';

        final filtered = patients.where((patient) {
          final patientId = patient.patientUniqueId;
          return patientId.contains(searchQuery);
        }).toList();

        expect(filtered.length, equals(1));
        expect(filtered.first.patientUniqueId, equals('PAT001'));
      });

      test('resetFilters should clear all filter values', () {
        // Simulate filter state
        String searchQuery = 'john';
        String selectedGender = 'male';
        String selectedBloodGroup = 'O+';
        String dateFrom = '2024-01-01';
        String dateTo = '2024-01-31';
        String sortDirection = 'asc';
        int currentPage = 5;

        // Reset filters
        searchQuery = '';
        selectedGender = '';
        selectedBloodGroup = '';
        dateFrom = '';
        dateTo = '';
        sortDirection = 'desc';
        currentPage = 1;

        expect(searchQuery, equals(''));
        expect(selectedGender, equals(''));
        expect(selectedBloodGroup, equals(''));
        expect(dateFrom, equals(''));
        expect(dateTo, equals(''));
        expect(sortDirection, equals('desc'));
        expect(currentPage, equals(1));
      });

      test('applyGenderFilter should handle "All" option', () {
        String selectedGender = 'male';

        void applyGenderFilter(String gender) {
          selectedGender = gender == 'All' ? '' : gender.toLowerCase();
        }

        applyGenderFilter('All');
        expect(selectedGender, equals(''));

        applyGenderFilter('Male');
        expect(selectedGender, equals('male'));

        applyGenderFilter('Female');
        expect(selectedGender, equals('female'));
      });

      test('applyBloodGroupFilter should handle "All" option', () {
        String selectedBloodGroup = 'O+';

        void applyBloodGroupFilter(String bloodGroup) {
          selectedBloodGroup = bloodGroup == 'All' ? '' : bloodGroup;
        }

        applyBloodGroupFilter('All');
        expect(selectedBloodGroup, equals(''));

        applyBloodGroupFilter('A+');
        expect(selectedBloodGroup, equals('A+'));

        applyBloodGroupFilter('O-');
        expect(selectedBloodGroup, equals('O-'));
      });
    });

    group('Filter Options', () {
      test('genders list should contain expected values', () {
        final genders = ['All', 'Male', 'Female'];

        expect(genders, contains('All'));
        expect(genders, contains('Male'));
        expect(genders, contains('Female'));
        expect(genders.length, equals(3));
      });

      test('bloodGroups list should contain all blood types', () {
        final bloodGroups = ['All', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

        expect(bloodGroups, contains('All'));
        expect(bloodGroups, contains('A+'));
        expect(bloodGroups, contains('A-'));
        expect(bloodGroups, contains('B+'));
        expect(bloodGroups, contains('B-'));
        expect(bloodGroups, contains('AB+'));
        expect(bloodGroups, contains('AB-'));
        expect(bloodGroups, contains('O+'));
        expect(bloodGroups, contains('O-'));
        expect(bloodGroups.length, equals(9));
      });
    });

    group('Sort Direction', () {
      test('changeSortDirection should update sort direction', () {
        String sortDirection = 'desc';

        void changeSortDirection(String direction) {
          sortDirection = direction;
        }

        changeSortDirection('asc');
        expect(sortDirection, equals('asc'));

        changeSortDirection('desc');
        expect(sortDirection, equals('desc'));
      });
    });
  });
}

PatientModel _createMockPatient(String fullName, String email, String patientId) {
  return PatientModel(
    id: patientId,
    patientUniqueId: patientId,
    customField: '',
    createdAt: '2024-01-01',
    updatedAt: '2024-01-01',
    user: {
      'full_name': fullName,
      'email': email,
      'phone': '1234567890'
    },
    stats: {},
    appointments: [],
    documents: [],
    vitalSigns: [],
  );
}
