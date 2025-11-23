# Project Structure Documentation

> **Document Version:** 1.0.0
> **Last Updated:** November 2024

## Complete Directory Structure

```
IgeHospital/
├── .dart_tool/                      # Dart tool cache (generated)
├── .idea/                           # IDE configuration
├── android/                         # Android platform files
├── assets/                          # Static assets (SVGs, images)
├── build/                           # Build output (generated)
├── docs/                            # Technical documentation
├── ios/                             # iOS platform files
├── lib/                             # Main source code
│   ├── constants/                   # Application constants
│   ├── controllers/                 # GetX controllers
│   ├── models/                      # Data models
│   ├── pages/                       # UI screens/pages
│   ├── provider/                    # Services & providers
│   ├── screen/                      # Special screens
│   ├── utils/                       # Utility classes
│   ├── widgets/                     # Reusable widgets
│   ├── app_bar.dart                 # Custom app bar
│   ├── drawer.dart                  # Navigation drawer
│   ├── home_page.dart               # Main layout shell
│   ├── main.dart                    # Application entry point
│   ├── routes.dart                  # Route configuration
│   └── static_data.dart             # App-wide state
├── linux/                           # Linux platform files
├── macos/                           # macOS platform files
├── test/                            # Test files
├── web/                             # Web platform files
├── windows/                         # Windows platform files
├── .gitignore                       # Git ignore rules
├── .metadata                        # Flutter metadata
├── analysis_options.yaml            # Dart analysis config
├── CLAUDE.md                        # Claude AI instructions
├── pubspec.lock                     # Dependency lock file
├── pubspec.yaml                     # Project configuration
└── README.md                        # Project readme
```

---

## Source Code Structure (`lib/`)

### Constants (`lib/constants/`)

Configuration and constant values used throughout the application.

```
lib/constants/
├── api_endpoints.dart          # REST API endpoint URLs
├── color_theme.dart            # Light/dark theme colors
├── password_constants.dart     # Password validation rules
├── permissions.dart            # Permission string constants
├── static_data.dart            # Static configuration
└── user_roles.dart             # User role definitions
```

| File | Purpose | Key Exports |
|------|---------|-------------|
| `api_endpoints.dart` | API URL constants | `ApiEndpoints` class with all endpoints |
| `color_theme.dart` | Theme color definitions | Color variables for light/dark modes |
| `password_constants.dart` | Password rules | Min length, complexity requirements |
| `permissions.dart` | Permission constants | `Permissions` class with all permission strings |
| `user_roles.dart` | Role definitions | `UserRoles` class with role constants |

---

### Controllers (`lib/controllers/`)

GetX controllers managing UI state and business logic.

```
lib/controllers/
├── accounting_controller.dart      # Accounting operations
├── auth_controller.dart            # Authentication UI state
├── consultation_controller.dart    # Consultation management
├── doctor_controller.dart          # Doctor list management
├── nurse_controller.dart           # Nurse/receptionist management
├── password_toggle_controller.dart # Password visibility toggle
├── patient_controller.dart         # Patient list management
└── vital_signs_controller.dart     # Vital signs management
```

| Controller | Responsibility | Key Features |
|------------|----------------|--------------|
| `AuthController` | Login form, user state | Form validation, login/logout |
| `PatientController` | Patient CRUD | Pagination, filters, search |
| `DoctorController` | Doctor management | List, filters, CRUD |
| `NurseController` | Nurse management | List, filters, CRUD |
| `ConsultationController` | Video consultations | Schedule, join, manage |
| `VitalSignsController` | Patient vitals | Record, history, trends |
| `AccountingController` | Financial operations | Accounts, payments, bills |
| `PasswordToggleController` | Password visibility | Toggle obscure text |

---

### Models (`lib/models/`)

Data structures with JSON serialization.

```
lib/models/
├── account_model.dart              # Account, Payment models
├── appointment_model.dart          # Appointment data
├── bill_model.dart                 # Bill, BillItem models
├── consultation_model.dart         # Consultation models
├── doctor_model.dart               # Doctor, Schedule models
├── nurse_model.dart                # Nurse/Receptionist model
├── patient_model.dart              # Patient data
└── vital_signs_model.dart          # Vital signs data
```

| Model | Fields Count | Key Relationships |
|-------|--------------|-------------------|
| `PatientModel` | 15+ | → Appointments, VitalSigns, Documents |
| `DoctorModel` | 20+ | → Department, Schedules, Appointments |
| `AppointmentModel` | 18 | → Patient, Doctor, Department |
| `ConsultationModel` | 25+ | → Patient, Doctor, JoinInfo |
| `VitalSignModel` | 15+ | → Patient, RecordedBy |
| `Account` | 12 | → Payments |
| `Bill` | 15 | → Patient, BillItems |

---

### Pages (`lib/pages/`)

UI screens and page components.

```
lib/pages/
├── accounting_page.dart            # Financial dashboard
├── admin_page.dart                 # Admin user management
├── appointments.dart               # Appointment management
├── doctor_page.dart                # Doctor management
├── home.dart                       # Dashboard screen
├── live_consultations_page.dart    # Video consultations
├── login_page.dart                 # Authentication screen
├── nurse_page.dart                 # Nurse management
├── page_mappings.dart              # Route → Widget mapping
├── patients_page.dart              # Patient records
├── profile_page.dart               # User profile
└── vital_signs_page.dart           # Vital signs tracking
```

| Page | Access Roles | Features |
|------|--------------|----------|
| `LoginPage` | Public | Email/password login |
| `HomePage` | All authenticated | Role-based dashboard |
| `PatientsPage` | Admin, Doctor, Receptionist | List, search, CRUD |
| `DoctorsPage` | Admin | Doctor management |
| `NursesPage` | Admin | Nurse management |
| `AdminsPage` | Admin | Admin user management |
| `AppointmentsPage` | Admin, Doctor, Patient | Booking, calendar |
| `ConsultationsPage` | All authenticated | Video meeting management |
| `VitalSignsPage` | Admin, Doctor, Receptionist | Patient vitals |
| `AccountingPage` | Admin | Financial operations |
| `ProfilePage` | All authenticated | Self profile management |

---

### Provider (Services) (`lib/provider/`)

Business logic and API communication services.

```
lib/provider/
├── accounting_service.dart         # Financial API operations
├── admin_service.dart              # Admin user API
├── appointment_service.dart        # Appointment API
├── auth_service.dart               # Authentication & session
├── colors_provider.dart            # Theme state (Provider)
├── consultation_service.dart       # Consultation API
├── dashboard_service.dart          # Dashboard data API
├── department_service.dart         # Department API
├── doctor_service.dart             # Doctor API
├── nurse_service.dart              # Nurse API
├── patient_service.dart            # Patient API
├── permission_service.dart         # RBAC permission service
└── vital_signs_service.dart        # Vital signs API
```

| Service | Methods | API Endpoints |
|---------|---------|---------------|
| `AuthService` | 10+ | `/auth/*` |
| `PatientService` | 5 | `/patient/*` |
| `DoctorService` | 5 | `/doctor/*` |
| `NurseService` | 5 | `/receptionist/*` |
| `AppointmentService` | 6 | `/appointments/*` |
| `ConsultationService` | 10+ | `/live-consultations/*` |
| `VitalSignsService` | 4 | `/vital-signs/*` |
| `AccountingService` | 15+ | `/accounting/*` |
| `DashboardService` | 2 | `/admin/dashboard` |
| `PermissionService` | 8 | Local only |

---

### Utils (`lib/utils/`)

Utility classes and helper functions.

```
lib/utils/
├── http_client.dart                # HTTP client singleton
├── permission_helper.dart          # Permission utilities
├── role_permissions.dart           # Role → Permission mapping
├── session_timeout_dialog.dart     # Session expiry handling
└── snack_bar_utils.dart            # Toast notifications
```

| Utility | Purpose | Key Methods |
|---------|---------|-------------|
| `HttpClient` | API communication | get, post, put, patch, delete |
| `RolePermissions` | Permission mapping | getPermissionsForRole, hasPermission |
| `SessionTimeoutDialog` | Session warning | startSessionTimer, showWarning |
| `SnackBarUtils` | Notifications | showSuccess, showError, showWarning |

---

### Widgets (`lib/widgets/`)

Reusable UI components organized by feature.

```
lib/widgets/
├── accounting/                     # Accounting widgets
│   ├── accounts_tab.dart
│   ├── bills_tab.dart
│   ├── create_account_dialog.dart
│   ├── dashboard_tab.dart
│   ├── edit_account_dialog.dart
│   ├── payments_tab.dart
│   └── recent_transactions_list.dart
│
├── appointment_components/         # Appointment widgets
│   ├── appointment_card.dart
│   ├── appointment_detail_dialog.dart
│   ├── appointment_filters.dart
│   ├── appointment_pagination.dart
│   ├── create_appointment_dialog.dart
│   └── edit_appointment_dialog.dart
│
├── doctor_component/               # Doctor widgets
│   ├── add_doctor_dialog.dart
│   ├── doctor_card.dart
│   ├── doctor_detail_dialog.dart
│   ├── doctor_filters.dart
│   └── edit_doctor_dialog.dart
│
├── form/                           # Form field components
│   ├── app_currency_field.dart
│   ├── app_date_field.dart
│   ├── app_dropdown_field.dart
│   ├── app_search_field.dart
│   └── app_text_field.dart
│
├── nurse_components/               # Nurse widgets
│   ├── add_nurse_dialog.dart
│   ├── edit_nurse_dialog.dart
│   ├── nurse_card.dart
│   ├── nurse_detail_dialog.dart
│   └── nurse_filters.dart
│
├── patient_component/              # Patient widgets
│   ├── add_patient_dialog.dart
│   ├── edit_patient_dialog.dart
│   ├── patient_card.dart
│   ├── patient_detail_dialog.dart
│   ├── patient_filters.dart
│   └── patient_pagination.dart
│
├── ui/                             # Generic UI components
│   ├── info_item.dart
│   ├── section_header.dart
│   ├── stat_card.dart
│   └── status_badge.dart
│
├── vital_signs_components/         # Vital signs widgets
│   ├── add_vital_signs_dialog.dart
│   ├── edit_vital_signs_dialog.dart
│   └── vital_signs_card.dart
│
├── add_admin_dialog.dart           # Admin creation
├── admin_data_table.dart           # Admin list table
├── admin_pagination.dart           # Admin pagination
├── app_bar.dart                    # App bar widget
├── bottom_bar.dart                 # Bottom navigation
├── common_button.dart              # Styled button
├── common_title.dart               # Page title
├── conditional_action_widget.dart  # Conditional rendering
├── consultation_card.dart          # Consultation display
├── consultation_detail_dialog.dart # Consultation details
├── consultation_filters.dart       # Consultation filters
├── consultation_form_dialog.dart   # Consultation form
├── consultation_status_badge.dart  # Status indicator
├── dashboard_card.dart             # Dashboard metric
├── dashboard_data_card.dart        # Data visualization
├── password_text_field.dart        # Password input
├── permission_button.dart          # Permission-wrapped button
├── permission_wrapper.dart         # Permission-based visibility
├── role_based_dashboard.dart       # Dashboard by role
├── role_based_widget.dart          # Role-conditional widget
├── size_box.dart                   # Spacing helper
├── text_field.dart                 # Text input
└── vital_signs_widget.dart         # Vital signs display
```

---

### Screen (`lib/screen/`)

Special purpose screens.

```
lib/screen/
└── auth/
    └── splash_screen.dart          # App initialization screen
```

| Screen | Purpose | Behavior |
|--------|---------|----------|
| `SplashScreen` | App startup | Check auth, redirect to home/login |

---

### Root Files (`lib/`)

Core application files.

| File | Purpose | Key Exports |
|------|---------|-------------|
| `main.dart` | Application entry point | main() function, service initialization |
| `routes.dart` | Route configuration | Routes class, getPage list, Middleware |
| `home_page.dart` | Main layout shell | MyHomepage with responsive layout |
| `drawer.dart` | Navigation drawer | DrawerCode with permission-based items |
| `app_bar.dart` | Custom app bar | AppBarCode with user info |
| `static_data.dart` | Global state | AppConst observable class |

---

## Asset Structure

```
assets/
├── icons/                          # SVG icons
│   ├── dashboard.svg
│   ├── patient.svg
│   ├── doctor.svg
│   └── ...
├── images/                         # Image assets
│   ├── logo.png
│   └── ...
└── ...
```

---

## Test Structure

```
test/
└── widget_test.dart                # Widget tests
```

---

## Configuration Files

| File | Purpose |
|------|---------|
| `pubspec.yaml` | Project dependencies and configuration |
| `pubspec.lock` | Locked dependency versions |
| `analysis_options.yaml` | Dart analyzer configuration |
| `.gitignore` | Git ignore patterns |
| `CLAUDE.md` | AI assistant instructions |

---

## File Naming Conventions

### Dart Files

| Type | Convention | Example |
|------|------------|---------|
| Models | `*_model.dart` | `patient_model.dart` |
| Services | `*_service.dart` | `patient_service.dart` |
| Controllers | `*_controller.dart` | `patient_controller.dart` |
| Pages | `*_page.dart` or `*.dart` | `patients_page.dart` |
| Widgets | `*_widget.dart` or descriptive | `patient_card.dart` |
| Dialogs | `*_dialog.dart` | `add_patient_dialog.dart` |
| Utils | Descriptive | `http_client.dart` |

### Component Organization

| Component Type | Location |
|----------------|----------|
| Feature-specific widgets | `lib/widgets/{feature}_component(s)/` |
| Generic form fields | `lib/widgets/form/` |
| Generic UI components | `lib/widgets/ui/` |
| Standalone widgets | `lib/widgets/` |

---

## Import Organization

Recommended import order:

```dart
// 1. Dart SDK
import 'dart:async';
import 'dart:convert';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. Third-party packages
import 'package:get/get.dart';
import 'package:provider/provider.dart';

// 4. Local imports (organized by layer)
import '../constants/api_endpoints.dart';
import '../models/patient_model.dart';
import '../provider/patient_service.dart';
import '../widgets/patient_component/patient_card.dart';
```
