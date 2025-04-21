import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/provider/nurse_service.dart';
import 'package:ige_hospital/provider/department_service.dart';
import 'package:ige_hospital/widgets/common_button.dart';
import 'package:ige_hospital/widgets/text_field.dart';

class EditNurseDialog extends StatefulWidget {
  final NurseModel nurse;
  final ColourNotifier notifier;
  final NursesService nursesService;

  const EditNurseDialog({
    super.key,
    required this.nurse,
    required this.notifier,
    required this.nursesService,
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
    firstNameController = TextEditingController(text: widget.nurse.user['first_name'] ?? '');
    lastNameController = TextEditingController(text: widget.nurse.user['last_name'] ?? '');
    emailController = TextEditingController(text: widget.nurse.email);
    phoneController = TextEditingController(text: widget.nurse.phone);
    specialtyController = TextEditingController(text: widget.nurse.specialty ?? '');
    qualificationController = TextEditingController(text: widget.nurse.qualification);
    dobController = TextEditingController(text: widget.nurse.user['dob'] ?? '');

    // Initialize selected values
    selectedGender = widget.nurse.gender.toLowerCase();
    selectedDepartment = widget.nurse.departmentId;
    selectedBloodGroup = widget.nurse.user['blood_group'] ?? 'O+';
    selectedStatus = widget.nurse.status.toLowerCase();

    // Parse date of birth if available
    try {
      selectedDate = widget.nurse.user['dob'] != null && widget.nurse.user['dob'].toString().isNotEmpty
          ? DateFormat('yyyy-MM-dd').parse(widget.nurse.user['dob'])
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
                    Icons.edit,
                    color: widget.notifier.getIconColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Edit Nurse: ${widget.nurse.fullName}",
                      style: TextStyle(
                        color: widget.notifier.getMainText,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
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
                                    initialDate: selectedDate,
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
                                      selectedDate = date;
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

                        // Status
                        _buildDropdown(
                          label: "Status",
                          value: selectedStatus,
                          items: const [
                            DropdownMenuItem(value: "active", child: Text("Active")),
                            DropdownMenuItem(value: "pending", child: Text("Pending")),
                            DropdownMenuItem(value: "blocked", child: Text("Blocked")),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value!;
                            });
                          },
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
                    onPressed: isLoading ? null : _updateNurse,
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
                        : const Text("Save Changes"),
                  ),
                ],
              ),
            ),
          ],
        ),
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

        await widget.nursesService.updateNurse(widget.nurse.id, nurseData);

        Navigator.pop(context);

        Get.snackbar(
          "Success",
          "Nurse updated successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
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
      decoration: InputDecoration(
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
      ),
      dropdownColor: widget.notifier.getContainer,
      style: TextStyle(color: widget.notifier.getMainText),
      items: items,
      onChanged: onChanged,
    );
  }
}