# Development Guide

> **Document Version:** 1.0.0
> **Last Updated:** November 2024

## Prerequisites

- Flutter SDK 3.6.1+
- Dart SDK 3.6.1+
- IDE: VS Code (recommended) or Android Studio
- Git

---

## Getting Started

### 1. Clone Repository

```bash
git clone <repository-url>
cd IgeHospital
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run Application

```bash
# Development
flutter run

# Web
flutter run -d chrome

# Release mode
flutter run --release
```

---

## Development Commands

### Flutter Commands

```bash
# Install dependencies
flutter pub get

# Run application
flutter run

# Run with specific device
flutter run -d chrome
flutter run -d macos
flutter run -d ios

# Build for platforms
flutter build web --release
flutter build apk --release
flutter build ios --release
flutter build macos --release

# Run tests
flutter test
flutter test --coverage

# Analyze code
flutter analyze

# Format code
dart format .
dart format lib/

# Clean build
flutter clean
flutter pub get
```

### Development Workflow

```bash
# 1. Create feature branch
git checkout -b feature/new-feature

# 2. Make changes
# 3. Format code
dart format lib/

# 4. Analyze
flutter analyze

# 5. Run tests
flutter test

# 6. Commit
git add .
git commit -m "feat: add new feature"

# 7. Push
git push origin feature/new-feature
```

---

## Project Structure

### Adding a New Feature

1. **Create Model** (`lib/models/`)
```dart
// lib/models/feature_model.dart
class FeatureModel {
  final String id;
  final String name;

  const FeatureModel({required this.id, required this.name});

  factory FeatureModel.fromJson(Map<String, dynamic> json) {
    return FeatureModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
```

2. **Create Service** (`lib/provider/`)
```dart
// lib/provider/feature_service.dart
class FeatureService extends GetxController {
  final HttpClient _http = HttpClient();

  Future<List<FeatureModel>> getFeatures() async {
    final response = await _http.get(ApiEndpoints.features);
    final json = jsonDecode(response.body);
    return (json['data'] as List)
        .map((f) => FeatureModel.fromJson(f))
        .toList();
  }
}
```

3. **Create Controller** (`lib/controllers/`)
```dart
// lib/controllers/feature_controller.dart
class FeatureController extends GetxController {
  final FeatureService _service = Get.find();

  var features = <FeatureModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFeatures();
  }

  Future<void> loadFeatures() async {
    isLoading.value = true;
    try {
      features.value = await _service.getFeatures();
    } finally {
      isLoading.value = false;
    }
  }
}
```

4. **Create Page** (`lib/pages/`)
```dart
// lib/pages/feature_page.dart
class FeaturePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FeatureController());

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: controller.features.length,
          itemBuilder: (_, i) => FeatureCard(controller.features[i]),
        );
      }),
    );
  }
}
```

5. **Add Permissions** (`lib/constants/permissions.dart`)
```dart
static const String viewFeatures = 'view_features';
static const String createFeatures = 'create_features';
```

6. **Update Role Permissions** (`lib/utils/role_permissions.dart`)
```dart
UserRoles.admin: [
  // ...existing
  Permissions.viewFeatures,
  Permissions.createFeatures,
],
```

7. **Add API Endpoint** (`lib/constants/api_endpoints.dart`)
```dart
static const String features = '$baseUrl/features';
```

8. **Register in Page Mappings** (`lib/pages/page_mappings.dart`)
```dart
final Map<String, Widget> pages = {
  // ...existing
  'features': FeaturePage(),
};
```

9. **Add to Drawer** (`lib/drawer.dart`)
```dart
PermissionWrapper(
  permission: Permissions.viewFeatures,
  child: DrawerItem(
    title: 'Features',
    icon: Icons.star,
    pageKey: 'features',
  ),
),
```

10. **Register Services** (`lib/main.dart`)
```dart
Get.put(FeatureService());
Get.put(FeatureController());
```

---

## Code Style Guidelines

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Classes | PascalCase | `PatientController` |
| Files | snake_case | `patient_controller.dart` |
| Variables | camelCase | `isLoading` |
| Constants | camelCase | `apiBaseUrl` |
| Private | underscore prefix | `_privateMethod` |

### File Organization

```dart
// 1. Imports (grouped)
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../models/patient_model.dart';
import '../provider/patient_service.dart';

// 2. Class definition
class PatientController extends GetxController {
  // 3. Dependencies
  final PatientService _service = Get.find();

  // 4. Observable state
  var patients = <PatientModel>[].obs;
  var isLoading = false.obs;

  // 5. Lifecycle methods
  @override
  void onInit() {
    super.onInit();
    loadPatients();
  }

  // 6. Public methods
  Future<void> loadPatients() async { ... }

  // 7. Private methods
  void _handleError(dynamic e) { ... }
}
```

### Widget Structure

```dart
class MyWidget extends StatelessWidget {
  // 1. Constructor parameters
  final String title;
  final VoidCallback? onTap;

  const MyWidget({
    Key? key,
    required this.title,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 2. Get theme/providers
    final notifier = Provider.of<ColourNotifier>(context);

    // 3. Build UI
    return Container(
      color: notifier.getContainer,
      child: Text(title),
    );
  }
}
```

---

## Error Handling

### Service Layer

```dart
Future<List<PatientModel>> getPatients() async {
  try {
    final response = await _http.get(ApiEndpoints.patients);
    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return (json['data'] as List)
          .map((p) => PatientModel.fromJson(p))
          .toList();
    } else {
      throw Exception(json['message'] ?? 'Failed to load patients');
    }
  } catch (e) {
    Get.log('Error in getPatients: $e');
    rethrow;
  }
}
```

### Controller Layer

```dart
Future<void> loadPatients() async {
  isLoading.value = true;
  hasError.value = false;

  try {
    patients.value = await _service.getPatients();
  } catch (e) {
    hasError.value = true;
    errorMessage.value = e.toString();
    SnackBarUtils.showError('Failed to load patients');
  } finally {
    isLoading.value = false;
  }
}
```

### UI Layer

```dart
Obx(() {
  if (controller.isLoading.value) {
    return CircularProgressIndicator();
  }

  if (controller.hasError.value) {
    return Column(
      children: [
        Icon(Icons.error, color: Colors.red, size: 48),
        Text(controller.errorMessage.value),
        ElevatedButton(
          onPressed: controller.loadPatients,
          child: Text('Retry'),
        ),
      ],
    );
  }

  return PatientList(controller.patients);
})
```

---

## Testing Guidelines

### Unit Tests

```dart
// test/services/patient_service_test.dart
void main() {
  group('PatientService', () {
    late PatientService service;

    setUp(() {
      service = PatientService();
    });

    test('getPatients returns list', () async {
      final patients = await service.getPatients();
      expect(patients, isA<List<PatientModel>>());
    });
  });
}
```

### Widget Tests

```dart
// test/widgets/patient_card_test.dart
void main() {
  testWidgets('PatientCard displays patient name', (tester) async {
    final patient = PatientModel(id: '1', name: 'John Doe');

    await tester.pumpWidget(
      MaterialApp(
        home: PatientCard(patient: patient),
      ),
    );

    expect(find.text('John Doe'), findsOneWidget);
  });
}
```

---

## Debugging

### GetX Logging

```dart
// Enable in debug mode
Get.log('Debug message');
Get.log('User: ${user.toJson()}');
```

### Network Debugging

```dart
// In HttpClient
print('Request: $url');
print('Headers: $headers');
print('Response: ${response.statusCode}');
print('Body: ${response.body}');
```

### State Debugging

```dart
// Print state changes
ever(isAuthenticated, (value) {
  print('Auth state changed: $value');
});
```

---

## Common Patterns

### Loading Pattern

```dart
var isLoading = false.obs;
var hasError = false.obs;
var errorMessage = ''.obs;

Future<void> loadData() async {
  isLoading.value = true;
  hasError.value = false;

  try {
    // Load data
  } catch (e) {
    hasError.value = true;
    errorMessage.value = e.toString();
  } finally {
    isLoading.value = false;
  }
}
```

### Form Pattern

```dart
class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Submit form
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          ElevatedButton(
            onPressed: _submit,
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
```

### Dialog Pattern

```dart
Future<bool?> showConfirmDialog(BuildContext context, String message) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Confirm'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Confirm'),
        ),
      ],
    ),
  );
}

// Usage
final confirmed = await showConfirmDialog(context, 'Delete this item?');
if (confirmed == true) {
  await deleteItem();
}
```

---

## VS Code Extensions

Recommended extensions:
- Flutter
- Dart
- Flutter Widget Snippets
- Bracket Pair Colorizer
- GitLens

### settings.json

```json
{
  "editor.formatOnSave": true,
  "dart.lineLength": 100,
  "editor.codeActionsOnSave": {
    "source.organizeImports": true,
    "source.fixAll": true
  }
}
```
