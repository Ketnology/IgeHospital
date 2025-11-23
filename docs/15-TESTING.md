# Testing Documentation

> **Document Version:** 1.0.0
> **Last Updated:** November 2024

## Overview

IGE Hospital follows a comprehensive testing strategy covering unit tests, widget tests, and integration tests. Tests are located in the `test/` directory.

---

## Test Structure

```
test/
├── unit/
│   ├── models/
│   │   ├── patient_model_test.dart
│   │   └── appointment_model_test.dart
│   ├── services/
│   │   ├── auth_service_test.dart
│   │   └── patient_service_test.dart
│   └── controllers/
│       ├── auth_controller_test.dart
│       └── patient_controller_test.dart
├── widget/
│   ├── components/
│   │   ├── patient_card_test.dart
│   │   └── status_badge_test.dart
│   └── pages/
│       ├── login_page_test.dart
│       └── patients_page_test.dart
├── integration/
│   └── app_test.dart
└── test_helpers/
    ├── mocks.dart
    └── test_data.dart
```

---

## Running Tests

### All Tests

```bash
flutter test
```

### Specific Test File

```bash
flutter test test/unit/models/patient_model_test.dart
```

### With Coverage

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Watch Mode

```bash
flutter test --watch
```

---

## Unit Tests

### Model Tests

```dart
// test/unit/models/patient_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:igehospital/models/patient_model.dart';

void main() {
  group('PatientModel', () {
    test('fromJson creates model correctly', () {
      final json = {
        'id': '123',
        'patient_unique_id': 'PAT-001',
        'user': {
          'full_name': 'John Doe',
          'email': 'john@example.com',
          'phone': '+1234567890',
          'gender': 'male',
        },
        'stats': {
          'appointments_count': 5,
          'documents_count': 3,
        },
        'vital_signs': [],
      };

      final patient = PatientModel.fromJson(json);

      expect(patient.id, '123');
      expect(patient.patientUniqueId, 'PAT-001');
      expect(patient.name, 'John Doe');
      expect(patient.email, 'john@example.com');
      expect(patient.appointmentsCount, 5);
    });

    test('handles missing fields gracefully', () {
      final json = {'id': '123'};

      final patient = PatientModel.fromJson(json);

      expect(patient.id, '123');
      expect(patient.name, '');
      expect(patient.email, '');
    });

    test('hasVitalSigns returns correct value', () {
      final withVitals = PatientModel.fromJson({
        'id': '1',
        'vital_signs': [{'id': 'v1'}],
      });

      final withoutVitals = PatientModel.fromJson({
        'id': '2',
        'vital_signs': [],
      });

      expect(withVitals.hasVitalSigns, true);
      expect(withoutVitals.hasVitalSigns, false);
    });
  });
}
```

### Service Tests

```dart
// test/unit/services/patient_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;

import 'package:igehospital/provider/patient_service.dart';
import 'package:igehospital/models/patient_model.dart';

@GenerateMocks([http.Client])
void main() {
  group('PatientService', () {
    late PatientService service;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      service = PatientService();
      // Inject mock client
    });

    test('getPatients returns list on success', () async {
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(
            '{"status": 200, "data": {"data": [{"id": "1", "user": {"full_name": "Test"}}]}}',
            200,
          ));

      final patients = await service.getPatients();

      expect(patients, isA<List<PatientModel>>());
      expect(patients.length, 1);
    });

    test('getPatients throws on error', () async {
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(
            '{"status": 500, "message": "Server error"}',
            500,
          ));

      expect(
        () => service.getPatients(),
        throwsException,
      );
    });
  });
}
```

### Controller Tests

```dart
// test/unit/controllers/patient_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';

import 'package:igehospital/controllers/patient_controller.dart';
import 'package:igehospital/provider/patient_service.dart';
import 'package:igehospital/models/patient_model.dart';

class MockPatientService extends GetxService
    with Mock
    implements PatientService {}

void main() {
  group('PatientController', () {
    late PatientController controller;
    late MockPatientService mockService;

    setUp(() {
      mockService = MockPatientService();
      Get.put<PatientService>(mockService);
      controller = PatientController();
    });

    tearDown(() {
      Get.reset();
    });

    test('initial state is correct', () {
      expect(controller.patients.isEmpty, true);
      expect(controller.isLoading.value, false);
      expect(controller.currentPage.value, 1);
    });

    test('loadPatients updates state correctly', () async {
      final testPatients = [
        PatientModel.fromJson({'id': '1', 'user': {'full_name': 'Test'}}),
      ];

      when(mockService.getPatientsWithPagination(
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenAnswer((_) async => {
        'patients': testPatients,
        'total': 1,
        'lastPage': 1,
      });

      await controller.loadPatients();

      expect(controller.patients.length, 1);
      expect(controller.totalPatients.value, 1);
      expect(controller.isLoading.value, false);
    });

    test('loadPatients handles error', () async {
      when(mockService.getPatientsWithPagination(
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenThrow(Exception('Network error'));

      await controller.loadPatients();

      expect(controller.hasError.value, true);
      expect(controller.errorMessage.value, contains('Network error'));
    });
  });
}
```

---

## Widget Tests

### Component Tests

```dart
// test/widget/components/patient_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:igehospital/widgets/patient_component/patient_card.dart';
import 'package:igehospital/models/patient_model.dart';
import 'package:igehospital/provider/colors_provider.dart';

void main() {
  group('PatientCard', () {
    late PatientModel patient;

    setUp(() {
      patient = PatientModel.fromJson({
        'id': '1',
        'user': {
          'full_name': 'John Doe',
          'email': 'john@example.com',
          'phone': '+1234567890',
          'gender': 'male',
        },
      });
    });

    Widget createWidget({VoidCallback? onTap}) {
      return MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => ColourNotifier(),
          child: Scaffold(
            body: PatientCard(
              patient: patient,
              onTap: onTap,
            ),
          ),
        ),
      );
    }

    testWidgets('displays patient name', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('displays patient email', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('john@example.com'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(createWidget(
        onTap: () => tapped = true,
      ));

      await tester.tap(find.byType(PatientCard));
      await tester.pump();

      expect(tapped, true);
    });
  });
}
```

### Status Badge Tests

```dart
// test/widget/components/status_badge_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:igehospital/widgets/ui/status_badge.dart';

void main() {
  group('StatusBadge', () {
    testWidgets('displays status text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StatusBadge(status: 'Active'),
        ),
      );

      expect(find.text('ACTIVE'), findsOneWidget);
    });

    testWidgets('uses correct color for active status', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StatusBadge(status: 'active'),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.border?.top.color, Colors.green);
    });

    testWidgets('uses correct color for blocked status', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StatusBadge(status: 'blocked'),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.border?.top.color, Colors.red);
    });
  });
}
```

### Page Tests

```dart
// test/widget/pages/login_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:igehospital/pages/login_page.dart';
import 'package:igehospital/controllers/auth_controller.dart';
import 'package:igehospital/provider/auth_service.dart';
import 'package:igehospital/provider/colors_provider.dart';

void main() {
  group('LoginPage', () {
    setUp(() {
      Get.put(AuthService());
      Get.put(AuthController());
    });

    tearDown(() {
      Get.reset();
    });

    Widget createWidget() {
      return GetMaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => ColourNotifier(),
          child: LoginPage(),
        ),
      );
    }

    testWidgets('displays email and password fields', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('displays login button', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('shows error for empty email', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('Login'));
      await tester.pump();

      // Verify snackbar or error shown
    });

    testWidgets('can enter credentials', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );

      expect(find.text('test@example.com'), findsOneWidget);
    });
  });
}
```

---

## Test Helpers

### Mock Data

```dart
// test/test_helpers/test_data.dart
import 'package:igehospital/models/patient_model.dart';
import 'package:igehospital/models/doctor_model.dart';

class TestData {
  static PatientModel get patient => PatientModel.fromJson({
    'id': 'test-patient-1',
    'patient_unique_id': 'PAT-001',
    'user': {
      'full_name': 'Test Patient',
      'email': 'patient@test.com',
      'phone': '+1234567890',
      'gender': 'male',
    },
    'stats': {
      'appointments_count': 5,
      'documents_count': 2,
    },
    'vital_signs': [],
  });

  static List<PatientModel> get patients => [
    patient,
    PatientModel.fromJson({
      'id': 'test-patient-2',
      'user': {'full_name': 'Another Patient'},
    }),
  ];

  static Doctora get doctor => Doctora.fromJson({
    'id': 'test-doctor-1',
    'first_name': 'Dr. Test',
    'last_name': 'Doctor',
    'email': 'doctor@test.com',
    'department': 'Cardiology',
    'status': 'active',
  });
}
```

### Test Wrappers

```dart
// test/test_helpers/test_wrapper.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:igehospital/provider/colors_provider.dart';
import 'package:igehospital/provider/auth_service.dart';
import 'package:igehospital/provider/permission_service.dart';

Widget createTestWidget(Widget child) {
  return GetMaterialApp(
    home: ChangeNotifierProvider(
      create: (_) => ColourNotifier(),
      child: Scaffold(body: child),
    ),
  );
}

void setupTestDependencies() {
  Get.put(AuthService());
  Get.put(PermissionService());
}

void tearDownTestDependencies() {
  Get.reset();
}
```

---

## Integration Tests

```dart
// test/integration/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:igehospital/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('login flow works', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Should be on login page
      expect(find.text('Login'), findsOneWidget);

      // Enter credentials
      await tester.enterText(
        find.byType(TextFormField).first,
        'admin@igehospital.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );

      // Tap login
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should navigate to home
      expect(find.text('Dashboard'), findsOneWidget);
    });
  });
}
```

---

## Best Practices

### 1. Test Naming

```dart
test('should return empty list when no patients exist', () { ... });
test('should throw exception when API returns 500', () { ... });
test('should update loading state during fetch', () { ... });
```

### 2. Arrange-Act-Assert

```dart
test('adds patient successfully', () async {
  // Arrange
  final controller = PatientController();
  final newPatient = {'name': 'Test'};

  // Act
  final result = await controller.addPatient(newPatient);

  // Assert
  expect(result, true);
  expect(controller.patients.length, 1);
});
```

### 3. Test Edge Cases

```dart
group('edge cases', () {
  test('handles empty response', () { ... });
  test('handles null values', () { ... });
  test('handles network timeout', () { ... });
  test('handles invalid JSON', () { ... });
});
```

### 4. Mock External Dependencies

```dart
// Always mock HTTP, storage, etc.
when(mockHttp.get(any)).thenAnswer((_) async => Response('{}', 200));
```

### 5. Clean Up

```dart
tearDown(() {
  Get.reset();
  // Clean up any resources
});
```
