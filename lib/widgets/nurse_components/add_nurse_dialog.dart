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

class AddNurseDialog extends StatefulWidget {
  final NurseController nurseController;

  const AddNurseDialog({
    super.key,
    required this.nurseController,
  });

  @override
  State<AddNurseDialog> createState() => _AddNurseDialogState();
}

class _AddNurseDialogState extends State<AddNurseDialog> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final specialtyController = TextEditingController();
  final qualificationController = TextEditingController();
  final dobController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Selected values
  String selectedGender = 'male';
  String selectedDepartment = '';
  String selectedBloodGroup = 'O+';

  // Selected date
  DateTime selectedDate = DateTime.now().subtract(const Duration(days: 365 * 25));

  // Loading state
  bool isLoading = false;

  // Department service
  late DepartmentService _departmentService;
  bool _departmentServiceInitialized = false;

  @override
  void initState() {
    super.initState();
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
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _initDepartmentService() {
    try {
      _departmentService = Get.find<DepartmentService>();
      _departmentServiceInitialized = true;
      // Initialize selectedDepartment with the first department if available
      if (_departmentService.departments.isNotEmpty) {
        selectedDepartment = _departmentService.departments.first.id;
      }
    } catch (e) {
      // Service not found, create it
      _departmentServiceInitialized = false;
      // Create and initialize the department service
      _departmentService = Get.put(DepartmentService());
      _departmentServiceInitialized = true;
      // Trigger a refresh after fetching data
      _departmentService.fetchDepartments().then((_) {
        if (mounted && _departmentService.departments.isNotEmpty) {
          setState(() {
            selectedDepartment = _departmentService.departments.first.id;
          });
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
          maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                      _buildSectionTitle(context, 'Personal Information', notifier),
                      const SizedBox(height: 16),

                      // First & Last Name
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'First Name',
                              controller: firstNameController,
                              validator: (value) => value!.isEmpty ? 'Required' : null,
                              hintText: "Enter first name",
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              label: 'Last Name',
                              controller: lastNameController,
                              validator: (value) => value!.isEmpty ? 'Required' : null,
                              hintText: "Enter last name",
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
                                if (!GetUtils.isEmail(value)) return 'Invalid email';
                                return null;
                              },
                              hintText: "Enter email address",
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              label: 'Phone',
                              controller: phoneController,
                              prefixIcon: Icons.phone,
                              validator: (value) => value!.isEmpty ? 'Required' : null,
                              hintText: "Enter phone number",
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
                                        dialogBackgroundColor: notifier.getContainer,
                                      ),
                                      child: child!,
                                    );
                                  },
                                );

                                if (date != null) {
                                  setState(() {
                                    selectedDate = date;
                                    dobController.text = DateFormat('yyyy-MM-dd').format(date);
                                  });
                                }
                              },
                              child: AbsorbPointer(
                                child: AppTextField(
                                  label: 'Date of Birth',
                                  controller: dobController,
                                  prefixIcon: Icons.calendar_today,
                                  hintText: DateFormat('yyyy-MM-dd').format(selectedDate),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Password & Confirm Password
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Password',
                              controller: passwordController,
                              prefixIcon: Icons.lock,
                              obscureText: true,
                              validator: (value) => value!.isEmpty ? 'Required' : null,
                              hintText: "Enter password",
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              label: 'Confirm Password',
                              controller: confirmPasswordController,
                              prefixIcon: Icons.lock_outline,
                              obscureText: true,
                              validator: (value) {
                                if (value!.isEmpty) return 'Required';
                                if (value != passwordController.text) return 'Passwords do not match';
                                return null;
                              },
                              hintText: "Confirm password",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Professional Information
                      _buildSectionTitle(context, 'Professional Information', notifier),
                      const SizedBox(height: 16),

                      // Department & Specialty
                      Row(
                        children: [
                          Expanded(
                            child: AppDropdownField(
                              label: 'Department',
                              value: selectedDepartment,
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
                              hintText: "Enter specialty (optional)",
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
                              validator: (value) => value!.isEmpty ? 'Required' : null,
                              hintText: "Enter qualification",
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppDropdownField(
                              label: 'Blood Group',
                              value: selectedBloodGroup,
                              items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map((group) {
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
            Icons.person_add,
            color: notifier.getIconColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Add New Nurse',
            style: TextStyle(
              color: notifier.getMainText,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const Spacer(),
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
      padding: const EdgeInsets.all(16),
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
            onPressed: isLoading ? null : _saveNurse,
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
                : const Text('Add Nurse'),
          ),
        ],
      ),
    );
  }

  void _saveNurse() async {
    if (_formKey.currentState!.validate()) {
      if (selectedDepartment.isEmpty) {
        Get.snackbar(
          "Error",
          "Please select a department",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      try {
        final nurseData = {
          "first_name": firstNameController.text,
          "last_name": lastNameController.text,
          "email": emailController.text,
          "phone": phoneController.text,
          "password": passwordController.text,
          "password_confirmation": confirmPasswordController.text,
          "gender": selectedGender,
          "department_id": selectedDepartment,
          "specialty": specialtyController.text,
          "qualification": qualificationController.text,
          "blood_group": selectedBloodGroup,
          if (dobController.text.isNotEmpty) "dob": dobController.text,
        };

        await widget.nurseController.addNurse(nurseData);

        Navigator.pop(context);
      } catch (e) {
        Get.snackbar(
          "Error",
          "Failed to add nurse: $e",
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

  Widget _buildSectionTitle(BuildContext context, String title, ColourNotifier notifier) {
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
    if (!_departmentServiceInitialized) {
      return [
        const DropdownMenuItem(value: '', child: Text("Loading departments..."))
      ];
    }

    if (_departmentService.departments.isEmpty) {
      return [
        const DropdownMenuItem(value: '', child: Text("No departments available"))
      ];
    }

    return _departmentService.departments
        .where((dept) => dept.status.toLowerCase() == 'active')
        .map((dept) => DropdownMenuItem<String>(
      value: dept.id,
      child: Text(dept.title),
    ))
        .toList();
  }
}