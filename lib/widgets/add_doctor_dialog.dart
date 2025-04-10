import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/provider/doctor_service.dart';
import 'package:ige_hospital/provider/department_service.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:intl/intl.dart';

class AddDoctorDialog extends StatefulWidget {
  final ColourNotifier notifier;
  final DoctorsService doctorsService;

  const AddDoctorDialog({
    super.key,
    required this.notifier,
    required this.doctorsService,
  });

  @override
  State<AddDoctorDialog> createState() => _AddDoctorDialogState();
}

class _AddDoctorDialogState extends State<AddDoctorDialog> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final specialistController = TextEditingController();
  final qualificationController = TextEditingController();
  final descriptionController = TextEditingController();
  final dobController = TextEditingController();

  // Selected values
  String selectedGender = 'male';
  String selectedDepartment = '';
  String selectedBloodGroup = 'O+';

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
    specialistController.dispose();
    qualificationController.dispose();
    descriptionController.dispose();
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
    return AlertDialog(
      backgroundColor: widget.notifier.getContainer,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Container(
        width: 600,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.notifier.getIconColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: widget.notifier.getIconColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Add New Doctor",
                    style: TextStyle(
                      color: widget.notifier.getMainText,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: widget.notifier.getMainText,
                    ),
                  ),
                ],
              ),
            ),

            // Form content
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Personal Information
                        Text(
                          "Personal Information",
                          style: TextStyle(
                            color: widget.notifier.getMainText,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Name fields
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: firstNameController,
                                style: TextStyle(color: widget.notifier.getMainText),
                                decoration: _inputDecoration("First Name"),
                                validator: (value) => value!.isEmpty ? "Required" : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: lastNameController,
                                style: TextStyle(color: widget.notifier.getMainText),
                                decoration: _inputDecoration("Last Name"),
                                validator: (value) => value!.isEmpty ? "Required" : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Email & Phone
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: emailController,
                                style: TextStyle(color: widget.notifier.getMainText),
                                decoration: _inputDecoration("Email"),
                                validator: (value) {
                                  if (value!.isEmpty) return "Required";
                                  if (!GetUtils.isEmail(value)) return "Invalid email";
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: phoneController,
                                style: TextStyle(color: widget.notifier.getMainText),
                                decoration: _inputDecoration("Phone"),
                                validator: (value) => value!.isEmpty ? "Required" : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Gender & Date of Birth
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdown(
                                label: "Gender",
                                value: selectedGender,
                                items: const [
                                  DropdownMenuItem(value: "male", child: Text("Male")),
                                  DropdownMenuItem(value: "female", child: Text("Female")),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedGender = value!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(primary: widget.notifier.getIconColor),
                                          dialogBackgroundColor: widget.notifier.getContainer,
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );

                                  if (date != null) {
                                    setState(() {
                                      dobController.text = DateFormat('yyyy-MM-dd').format(date);
                                    });
                                  }
                                },
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    controller: dobController,
                                    style: TextStyle(color: widget.notifier.getMainText),
                                    decoration: _inputDecoration(
                                      "Date of Birth",
                                      suffixIcon: Icons.calendar_today,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Professional Information
                        Text(
                          "Professional Information",
                          style: TextStyle(
                            color: widget.notifier.getMainText,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Department & Specialty
                        Row(
                          children: [
                            Expanded(
                              child: Obx(() {
                                // Use the department service if available
                                if (_departmentServiceInitialized && _departmentService.departments.isNotEmpty) {
                                  return _buildDropdown(
                                    label: "Department",
                                    value: selectedDepartment.isEmpty && _departmentService.departments.isNotEmpty
                                        ? _departmentService.departments.first.id
                                        : selectedDepartment,
                                    items: _getDepartmentItems(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedDepartment = value!;
                                      });
                                    },
                                  );
                                } else {
                                  // Show loading dropdown
                                  return _buildDropdown(
                                    label: "Department (Loading...)",
                                    value: '',
                                    items: const [
                                      DropdownMenuItem(value: '', child: Text("Loading departments...")),
                                    ],
                                    onChanged: (value) {},
                                  );
                                }
                              }),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: specialistController,
                                style: TextStyle(color: widget.notifier.getMainText),
                                decoration: _inputDecoration("Specialist Area"),
                                validator: (value) => value!.isEmpty ? "Required" : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Qualification & Blood Group
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: qualificationController,
                                style: TextStyle(color: widget.notifier.getMainText),
                                decoration: _inputDecoration("Qualification"),
                                validator: (value) => value!.isEmpty ? "Required" : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDropdown(
                                label: "Blood Group",
                                value: selectedBloodGroup,
                                items: const [
                                  DropdownMenuItem(value: "A+", child: Text("A+")),
                                  DropdownMenuItem(value: "A-", child: Text("A-")),
                                  DropdownMenuItem(value: "B+", child: Text("B+")),
                                  DropdownMenuItem(value: "B-", child: Text("B-")),
                                  DropdownMenuItem(value: "AB+", child: Text("AB+")),
                                  DropdownMenuItem(value: "AB-", child: Text("AB-")),
                                  DropdownMenuItem(value: "O+", child: Text("O+")),
                                  DropdownMenuItem(value: "O-", child: Text("O-")),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedBloodGroup = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Description
                        TextFormField(
                          controller: descriptionController,
                          style: TextStyle(color: widget.notifier.getMainText),
                          decoration: _inputDecoration("Professional Description"),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Dialog actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: widget.notifier.getBorderColor),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: widget.notifier.getMainText),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: isLoading ? null : _saveDoctor,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appMainColor,
                      foregroundColor: Colors.white,
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
                        : const Text("Save"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveDoctor() async {
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
        final doctorData = {
          "first_name": firstNameController.text,
          "last_name": lastNameController.text,
          "email": emailController.text,
          "phone": phoneController.text,
          "gender": selectedGender,
          "doctor_department_id": selectedDepartment,
          "specialist": specialistController.text,
          "description": descriptionController.text,
          "qualification": qualificationController.text,
          "blood_group": selectedBloodGroup,
          "status": "active",
          if (dobController.text.isNotEmpty) "dob": dobController.text,
        };

        Get.log("Creating doctor with department ID: $selectedDepartment");
        await widget.doctorsService.createDoctor(doctorData);

        Navigator.pop(context);

        Get.snackbar(
          "Success",
          "Doctor added successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          "Error",
          "Failed to add doctor: $e",
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

  InputDecoration _inputDecoration(String label, {IconData? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: widget.notifier.getMainText),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: widget.notifier.getBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: widget.notifier.getBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: widget.notifier.getIconColor),
      ),
      filled: true,
      fillColor: widget.notifier.getPrimaryColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      suffixIcon: suffixIcon != null
          ? Icon(suffixIcon, color: widget.notifier.getIconColor)
          : null,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _inputDecoration(label),
      dropdownColor: widget.notifier.getContainer,
      style: TextStyle(color: widget.notifier.getMainText),
      items: items,
      onChanged: onChanged,
    );
  }

  List<DropdownMenuItem<String>> _getDepartmentItems() {
    if (!_departmentServiceInitialized) {
      return [const DropdownMenuItem(value: '', child: Text("No departments available"))];
    }

    if (_departmentService.departments.isEmpty) {
      return [const DropdownMenuItem(value: '', child: Text("No departments available"))];
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