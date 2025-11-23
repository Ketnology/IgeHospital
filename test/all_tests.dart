/// This file exports all test files for the IGE Hospital application.
/// Run all tests with: flutter test
///
/// Test Categories:
/// 1. Model Tests - Test JSON serialization/deserialization and computed properties
/// 2. Utility Tests - Test role permissions, user roles, and constants
/// 3. Controller Tests - Test controller logic and state management
/// 4. Widget Tests - Test UI components and form fields
/// 5. Integration Tests - Test component interactions and user flows

library all_tests;

// Model Tests
export 'models/patient_model_test.dart';
export 'models/vital_signs_model_test.dart';
export 'models/consultation_model_test.dart';
export 'models/doctor_model_test.dart';
export 'models/appointment_model_test.dart';
export 'models/account_model_test.dart';
export 'models/bill_model_test.dart';
export 'models/nurse_model_test.dart';

// Utility Tests
export 'utils/user_roles_test.dart';
export 'utils/role_permissions_test.dart';

// Constants Tests
export 'constants/permissions_test.dart';

// Controller Tests
export 'controllers/patient_controller_test.dart';
export 'controllers/auth_controller_test.dart';

// Widget Tests
export 'widgets/permission_wrapper_test.dart';
export 'widgets/form_fields_test.dart';

// Integration Tests
export 'integration/app_integration_test.dart';

// Mocks
export 'mocks/mock_http_client.dart';
