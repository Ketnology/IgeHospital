# UI Components Documentation

> **Document Version:** 1.0.0
> **Last Updated:** November 2024

## Overview

IGE Hospital uses a component-based UI architecture with reusable widgets organized by feature and function. All components are located in `lib/widgets/`.

---

## Component Organization

```
lib/widgets/
├── accounting/              # Accounting module widgets
├── appointment_components/  # Appointment widgets
├── doctor_component/        # Doctor management widgets
├── form/                    # Form field components
├── nurse_components/        # Nurse management widgets
├── patient_component/       # Patient widgets
├── ui/                      # Generic UI components
├── vital_signs_components/  # Vital signs widgets
└── [root widgets]           # Shared/common widgets
```

---

## Permission-Based Components

### PermissionWrapper

Conditionally renders child based on user permissions.

```dart
// lib/widgets/permission_wrapper.dart
class PermissionWrapper extends StatelessWidget {
  final Widget child;
  final String? permission;      // Single permission check
  final List<String>? anyOf;     // Any of these permissions
  final List<String>? allOf;     // All of these permissions
  final Widget? fallback;        // Widget if denied (default: SizedBox.shrink())

  const PermissionWrapper({
    Key? key,
    required this.child,
    this.permission,
    this.anyOf,
    this.allOf,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final permService = Get.find<PermissionService>();
    bool hasAccess = false;

    if (permission != null) {
      hasAccess = permService.hasPermission(permission!);
    } else if (anyOf != null && anyOf!.isNotEmpty) {
      hasAccess = permService.hasAnyPermission(anyOf!);
    } else if (allOf != null && allOf!.isNotEmpty) {
      hasAccess = permService.hasAllPermissions(allOf!);
    } else {
      hasAccess = true;
    }

    return hasAccess ? child : (fallback ?? const SizedBox.shrink());
  }
}
```

**Usage Examples:**

```dart
// Single permission
PermissionWrapper(
  permission: Permissions.viewPatients,
  child: PatientListWidget(),
)

// Any of multiple permissions
PermissionWrapper(
  anyOf: [Permissions.viewAppointments, Permissions.viewOwnAppointments],
  child: AppointmentMenu(),
)

// With fallback
PermissionWrapper(
  permission: Permissions.deletePatients,
  child: DeleteButton(),
  fallback: DisabledDeleteButton(),
)
```

### RoleBasedWidget

Renders different content based on user role.

```dart
class RoleBasedWidget extends StatelessWidget {
  final Widget? adminWidget;
  final Widget? doctorWidget;
  final Widget? receptionistWidget;
  final Widget? patientWidget;
  final Widget? defaultWidget;

  @override
  Widget build(BuildContext context) {
    final permService = Get.find<PermissionService>();

    if (permService.isAdmin && adminWidget != null) {
      return adminWidget!;
    } else if (permService.isDoctor && doctorWidget != null) {
      return doctorWidget!;
    } else if (permService.isReceptionist && receptionistWidget != null) {
      return receptionistWidget!;
    } else if (permService.isPatient && patientWidget != null) {
      return patientWidget!;
    }

    return defaultWidget ?? const SizedBox.shrink();
  }
}
```

### RoleBasedDashboard

Dashboard that adapts to user role.

```dart
class RoleBasedDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final permService = Get.find<PermissionService>();

    if (permService.isAdmin) {
      return AdminDashboard();
    } else if (permService.isDoctor) {
      return DoctorDashboard();
    } else if (permService.isReceptionist) {
      return ReceptionistDashboard();
    } else if (permService.isPatient) {
      return PatientDashboard();
    }

    return DefaultDashboard();
  }
}
```

---

## Form Components

### AppTextField

Standard text input with theming.

```dart
// lib/widgets/form/app_text_field.dart
class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLines;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool enabled;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: notifier.getMainText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            filled: true,
            fillColor: notifier.getContainer,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: notifier.getBorderColor),
            ),
          ),
        ),
      ],
    );
  }
}
```

**Usage:**

```dart
AppTextField(
  label: 'Email',
  hint: 'Enter your email',
  controller: emailController,
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value?.isEmpty ?? true) return 'Email is required';
    return null;
  },
)
```

### AppDateField

Date picker input.

```dart
class AppDateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final void Function(DateTime) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: firstDate ?? DateTime(2000),
              lastDate: lastDate ?? DateTime(2100),
            );
            if (date != null) onChanged(date);
          },
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today),
                SizedBox(width: 8),
                Text(value != null
                    ? DateFormat('MMM dd, yyyy').format(value!)
                    : 'Select date'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
```

### AppDropdownField

Dropdown select component.

```dart
class AppDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
```

### AppCurrencyField

Currency input with formatting.

```dart
class AppCurrencyField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      prefixIcon: Padding(
        padding: EdgeInsets.all(12),
        child: Text(currency, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
```

### AppSearchField

Search input with debounce.

```dart
class AppSearchField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final void Function(String) onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(Icons.search),
        suffixIcon: controller?.text.isNotEmpty ?? false
            ? IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  controller?.clear();
                  onClear?.call();
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
```

---

## UI Components

### StatusBadge

Status indicator with color.

```dart
// lib/widgets/ui/status_badge.dart
class StatusBadge extends StatelessWidget {
  final String status;
  final Color? color;
  final Color? textColor;

  static const Map<String, Color> _statusColors = {
    'active': Colors.green,
    'pending': Colors.orange,
    'blocked': Colors.red,
    'completed': Colors.blue,
    'cancelled': Colors.grey,
    'ongoing': Colors.purple,
    'scheduled': Colors.teal,
  };

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? _statusColors[status.toLowerCase()] ?? Colors.grey;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bgColor),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor ?? bgColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
```

### StatCard

Metric display card.

```dart
// lib/widgets/ui/stat_card.dart
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Card(
      color: notifier.getContainer,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: iconColor ?? notifier.getIconColor),
                  if (onTap != null) Icon(Icons.chevron_right),
                ],
              ),
              Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: notifier.getMainText,
                ),
              ),
              SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: notifier.getMainText.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### SectionHeader

Section title with optional action.

```dart
// lib/widgets/ui/section_header.dart
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onActionTap;
  final String? actionText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (trailing != null) trailing!,
        if (actionText != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(actionText!),
          ),
      ],
    );
  }
}
```

### InfoItem

Key-value display.

```dart
// lib/widgets/ui/info_item.dart
class InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.grey),
            SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
```

---

## Feature Components

### Patient Card

```dart
// lib/widgets/patient_component/patient_card.dart
class PatientCard extends StatelessWidget {
  final PatientModel patient;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: patient.profileImage != null
                        ? NetworkImage(patient.profileImage!)
                        : null,
                    child: patient.profileImage == null
                        ? Text(patient.name[0].toUpperCase())
                        : null,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          patient.email,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'view',
                        child: Text('View Details'),
                      ),
                      if (onEdit != null)
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                      if (onDelete != null)
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                    ],
                    onSelected: (value) {
                      if (value == 'view') onTap?.call();
                      if (value == 'edit') onEdit?.call();
                      if (value == 'delete') onDelete?.call();
                    },
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  _InfoChip(Icons.phone, patient.phone),
                  SizedBox(width: 8),
                  _InfoChip(Icons.person, patient.gender),
                ],
              ),
              if (patient.hasVitalSigns) ...[
                SizedBox(height: 8),
                _VitalSignsSummary(patient),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

### Consultation Card

```dart
// lib/widgets/consultation_card.dart
class ConsultationCard extends StatelessWidget {
  final LiveConsultation consultation;
  final VoidCallback? onJoin;
  final VoidCallback? onStart;
  final VoidCallback? onEnd;
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    consultation.consultationTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                ConsultationStatusBadge(status: consultation.status),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16),
                SizedBox(width: 8),
                Text(DateFormat('MMM dd, yyyy').format(consultation.consultationDate)),
                SizedBox(width: 16),
                Icon(Icons.access_time, size: 16),
                SizedBox(width: 8),
                Text(DateFormat('HH:mm').format(consultation.consultationDate)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 16),
                SizedBox(width: 8),
                Text('Dr. ${consultation.doctor.name}'),
              ],
            ),
            Row(
              children: [
                Icon(Icons.person_outline, size: 16),
                SizedBox(width: 8),
                Text(consultation.patient.name),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (consultation.permissions.canJoin && consultation.joinInfo?.canJoinNow == true)
                  ElevatedButton.icon(
                    onPressed: onJoin,
                    icon: Icon(Icons.video_call),
                    label: Text('Join'),
                  ),
                if (consultation.permissions.canStart)
                  ElevatedButton.icon(
                    onPressed: onStart,
                    icon: Icon(Icons.play_arrow),
                    label: Text('Start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                if (consultation.permissions.canEnd)
                  ElevatedButton.icon(
                    onPressed: onEnd,
                    icon: Icon(Icons.stop),
                    label: Text('End'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Layout Components

### AppBarCode

Custom app bar with user info.

```dart
// lib/app_bar.dart
class AppBarCode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final notifier = Provider.of<ColourNotifier>(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: notifier.getContainer,
        border: Border(bottom: BorderSide(color: notifier.getBorderColor)),
      ),
      child: Row(
        children: [
          // Page title
          Obx(() => Text(
            _getPageTitle(AppConst.selectedPageKey.value),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          )),
          Spacer(),
          // User info
          Obx(() => Row(
            children: [
              CircleAvatar(
                child: Text(authController.userName.value[0].toUpperCase()),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(authController.userName.value),
                  Text(
                    authController.userRole.value,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(width: 16),
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () => authController.logout(),
              ),
            ],
          )),
        ],
      ),
    );
  }
}
```

### DrawerCode

Navigation drawer with permissions.

```dart
// lib/drawer.dart
class DrawerCode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Container(
      width: 260,
      color: notifier.getPrimaryColor,
      child: Column(
        children: [
          // Logo header
          Container(
            padding: EdgeInsets.all(20),
            child: Image.asset('assets/logo.png', height: 50),
          ),
          Divider(),
          // Menu items
          Expanded(
            child: ListView(
              children: [
                _DrawerItem(
                  title: 'Dashboard',
                  icon: Icons.dashboard,
                  pageKey: 'overview',
                ),
                PermissionWrapper(
                  permission: Permissions.viewPatients,
                  child: _DrawerItem(
                    title: 'Patients',
                    icon: Icons.people,
                    pageKey: 'patients',
                  ),
                ),
                PermissionWrapper(
                  permission: Permissions.viewDoctors,
                  child: _DrawerItem(
                    title: 'Doctors',
                    icon: Icons.medical_services,
                    pageKey: 'doctors',
                  ),
                ),
                PermissionWrapper(
                  anyOf: [Permissions.viewAppointments, Permissions.viewOwnAppointments],
                  child: _DrawerItem(
                    title: 'Appointments',
                    icon: Icons.calendar_today,
                    pageKey: 'appointments',
                  ),
                ),
                PermissionWrapper(
                  anyOf: [Permissions.viewConsultations, Permissions.joinConsultations],
                  child: _DrawerItem(
                    title: 'Live Consultations',
                    icon: Icons.video_call,
                    pageKey: 'live-consultations',
                  ),
                ),
                PermissionWrapper(
                  permission: Permissions.viewAccounting,
                  child: _DrawerItem(
                    title: 'Accounting',
                    icon: Icons.attach_money,
                    pageKey: 'accounting',
                  ),
                ),
              ],
            ),
          ),
          // Theme toggle
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.light_mode),
                Switch(
                  value: notifier.isDark,
                  onChanged: (value) => notifier.isAvaliable(value),
                ),
                Icon(Icons.dark_mode),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String pageKey;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = AppConst.selectedPageKey.value == pageKey;

      return ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Theme.of(context).primaryColor : null,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onTap: () {
          AppConst.selectedPageKey.value = pageKey;
          if (MediaQuery.of(context).size.width < 600) {
            Navigator.pop(context); // Close drawer on mobile
          }
        },
      );
    });
  }
}
```

---

## Component Best Practices

### 1. Theme Integration

```dart
@override
Widget build(BuildContext context) {
  final notifier = Provider.of<ColourNotifier>(context);

  return Container(
    color: notifier.getContainer,
    child: Text(
      'Hello',
      style: TextStyle(color: notifier.getMainText),
    ),
  );
}
```

### 2. Responsive Design

```dart
@override
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth >= 600) {
        return DesktopLayout();
      } else {
        return MobileLayout();
      }
    },
  );
}
```

### 3. Loading States

```dart
Obx(() {
  if (controller.isLoading.value) {
    return Center(child: CircularProgressIndicator());
  }

  if (controller.hasError.value) {
    return ErrorWidget(message: controller.errorMessage.value);
  }

  return ContentWidget(data: controller.data);
})
```
