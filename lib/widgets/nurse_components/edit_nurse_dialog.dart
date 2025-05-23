import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/controllers/nurse_controller.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/provider/department_service.dart';
import 'package:ige_hospital/widgets/form/app_dropdown_field.dart';
import 'package:ige_hospital/widgets/form/app_text_field.dart';
import 'package:provider/provider.dart';

class EditNurseDialog extends StatefulWidget {
  final Nurse nurse;
  final NurseController nurseController;

  const EditNurseDialog({
    super.key,
    required this.nurse,
    required this.nurseController,
  });

  @override
  State<EditNurseDialog> createState() => _EditNurseDialogState();
}

class _EditNurseDialogState extends State<EditNurseDialog> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController specialtyController;
  late TextEditingController qualificationController;
  late TextEditingController dobController;

  // Selected values
  late String selectedGender;
  late String selectedDepartment;
  late String selectedBloodGroup;
  late String selectedStatus;

  // Selected date
  late DateTime selectedDate;

  // Loading state
  bool isLoading = false;

  // Department service
  late DepartmentService _departmentService;
  bool _departmentServiceInitialized = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with nurse data
    firstNameController = TextEditingController(text: widget.nurse.firstName);
    lastNameController = TextEditingController(text: widget.nurse.lastName);
    emailController = TextEditingController(text: widget.nurse.email);
    phoneController = TextEditingController(text: widget.nurse.phone);
    specialtyController = TextEditingController(text: widget.nurse.specialty);
    qualificationController =
        TextEditingController(text: widget.nurse.qualification);
    dobController = TextEditingController(text: widget.nurse.user['dob'] ?? '');

    // Initialize selected values
    selectedGender = widget.nurse.gender.toLowerCase();
    selectedDepartment = widget.nurse.departmentId;
    selectedBloodGroup = widget.nurse.bloodGroup;
    selectedStatus = widget.nurse.status.toLowerCase();

    // Parse date of birth if available
    try {
      selectedDate = widget.nurse.user['dob'] != null &&
              widget.nurse.user['dob'].toString().isNotEmpty
          ? DateTime.parse(widget.nurse.user['dob'])
          : DateTime.now().subtract(const Duration(days: 365 * 25));
    } catch (e) {
      selectedDate = DateTime.now().subtract(const Duration(days: 365 * 25));
    }

    _initDepartmentService();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    specialtyController.dispose();
    qualificationController.dispose();
    dobController.dispose();
    super.dispose();
  }

  void _initDepartmentService() {
    try {
      _departmentService = Get.find<DepartmentService>();
      _departmentServiceInitialized = true;
    } catch (e) {
      // Service not found, create it
      _departmentServiceInitialized = false;
      // Create and initialize the department service
      _departmentService = Get.put(DepartmentService());
      _departmentServiceInitialized = true;
      // Trigger a refresh after fetching data
      _departmentService.fetchDepartments().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: notifier.getContainer,
      child: Container(
        width: 600,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context, notifier),

            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal Information
                      _buildSectionTitle(
                          context, 'Personal Information', notifier),
                      const SizedBox(height: 16),

                      // First & Last Name
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'First Name',
                              controller: firstNameController,
                              validator: (value) =>
                                  value!.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              label: 'Last Name',
                              controller: lastNameController,
                              validator: (value) =>
                                  value!.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Email & Phone
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Email',
                              controller: emailController,
                              prefixIcon: Icons.email,
                              validator: (value) {
                                if (value!.isEmpty) return 'Required';
                                if (!GetUtils.isEmail(value))
                                  return 'Invalid email';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              label: 'Phone',
                              controller: phoneController,
                              prefixIcon: Icons.phone,
                              validator: (value) =>
                                  value!.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Gender & Date of Birth
                      Row(
                        children: [
                          Expanded(
                            child: AppDropdownField(
                              label: 'Gender',
                              value: selectedGender,
                              items: ['male', 'female'].map((gender) {
                                return DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender.capitalizeFirst!),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedGender = value;
                                  });
                                }
                              },
                              prefixIcon: Icons.person,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime(1940),
                                  lastDate: DateTime.now(),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: notifier.getIconColor,
                                        ),
                                        dialogBackgroundColor:
                                            notifier.getContainer,
                                      ),
                                      child: child!,
                                    );
                                  },
                                );

                                if (date != null) {
                                  setState(() {
                                    selectedDate = date;
                                    dobController.text =
                                        DateFormat('yyyy-MM-dd').format(date);
                                  });
                                }
                              },
                              child: AbsorbPointer(
                                child: AppTextField(
                                  label: 'Date of Birth',
                                  controller: dobController,
                                  prefixIcon: Icons.calendar_today,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Professional Information
                      _buildSectionTitle(
                          context, 'Professional Information', notifier),
                      const SizedBox(height: 16),

                      // Department & Specialty
                      Row(
                        children: [
                          Expanded(
                            child: AppDropdownField(
                              label: 'Department',
                              value: _departmentService.departments
                                      .any((d) => d.id == selectedDepartment)
                                  ? selectedDepartment
                                  : null, // null if value not in list
                              items: _getDepartmentItems(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedDepartment = value;
                                  });
                                }
                              },
                              prefixIcon: Icons.business,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              label: 'Specialty',
                              controller: specialtyController,
                              prefixIcon: Icons.local_hospital,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Qualification & Blood Group
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Qualification',
                              controller: qualificationController,
                              prefixIcon: Icons.school,
                              validator: (value) =>
                                  value!.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppDropdownField(
                              label: 'Blood Group',
                              value: selectedBloodGroup,
                              items: [
                                'A+',
                                'A-',
                                'B+',
                                'B-',
                                'AB+',
                                'AB-',
                                'O+',
                                'O-'
                              ].map((group) {
                                return DropdownMenuItem(
                                  value: group,
                                  child: Text(group),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedBloodGroup = value;
                                  });
                                }
                              },
                              prefixIcon: Icons.bloodtype,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Status
                      AppDropdownField(
                        label: 'Status',
                        value: selectedStatus,
                        items: ['active', 'pending', 'blocked'].map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _getStatusColor(status),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(status.capitalizeFirst!),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedStatus = value;
                            });
                          }
                        },
                        prefixIcon: Icons.verified_user,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer with actions
            _buildFooter(context, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColourNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifier.getIconColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.edit,
            color: notifier.getIconColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Edit Nurse: ${widget.nurse.fullName}',
              style: TextStyle(
                color: notifier.getMainText,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: notifier.getMainText),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ColourNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: notifier.getBorderColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(color: notifier.getMainText),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: isLoading ? null : _updateNurse,
            style: ElevatedButton.styleFrom(
              backgroundColor: appMainColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _updateNurse() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        final nurseData = {
          "first_name": firstNameController.text,
          "last_name": lastNameController.text,
          "email": emailController.text,
          "phone": phoneController.text,
          "gender": selectedGender,
          "department_id": selectedDepartment,
          "specialty": specialtyController.text,
          "qualification": qualificationController.text,
          "blood_group": selectedBloodGroup,
          "status": selectedStatus,
          if (dobController.text.isNotEmpty) "dob": dobController.text,
        };

        await widget.nurseController.updateNurse(widget.nurse.id, nurseData);

        Navigator.pop(context);
      } catch (e) {
        Get.snackbar(
          "Error",
          "Failed to update nurse: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  Widget _buildSectionTitle(
      BuildContext context, String title, ColourNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: notifier.getIconColor,
          ),
        ),
        const SizedBox(height: 5),
        Divider(color: notifier.getBorderColor),
      ],
    );
  }

  List<DropdownMenuItem<String>> _getDepartmentItems() {
    if (!_departmentServiceInitialized ||
        _departmentService.departments.isEmpty) {
      // Return a default item with the current value if departments aren't loaded yet
      return [
        DropdownMenuItem(
          value: selectedDepartment, // Keep the current value
          child: Text(_departmentServiceInitialized
              ? "No departments available"
              : "Loading departments..."),
        )
      ];
    }

    // Filter active departments and ensure no duplicates
    final activeDepartments = _departmentService.departments
        .where((dept) => dept.status.toLowerCase() == 'active')
        .toSet() // Remove duplicates
        .toList();

    return activeDepartments
        .map((dept) => DropdownMenuItem<String>(
              value: dept.id,
              child: Text(dept.title),
            ))
        .toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'blocked':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
