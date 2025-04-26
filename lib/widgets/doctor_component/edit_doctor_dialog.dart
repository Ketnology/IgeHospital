import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:provider/provider.dart';
import 'package:ige_hospital/controllers/doctor_controller.dart';
import 'package:ige_hospital/provider/department_service.dart';
import 'package:intl/intl.dart';

class EditDoctorDialog extends StatefulWidget {
  final Doctor doctor;

  const EditDoctorDialog({
    super.key,
    required this.doctor,
  });

  @override
  State<EditDoctorDialog> createState() => _EditDoctorDialogState();
}

class _EditDoctorDialogState extends State<EditDoctorDialog> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController specialtyController;
  late final TextEditingController qualificationController;
  late final TextEditingController descriptionController;

  // Selected values
  late String selectedGender;
  late String selectedDepartment;
  late String selectedBloodGroup;
  late String selectedStatus;

  // Selected date
  late DateTime selectedDate;

  // Loading state
  bool isLoading = false;

  // Services
  late DoctorController doctorController;
  late DepartmentService departmentService;

  @override
  void initState() {
    super.initState();
    doctorController = Get.find<DoctorController>();

    // Initialize controllers with doctor data
    firstNameController = TextEditingController(text: widget.doctor.firstName);
    lastNameController = TextEditingController(text: widget.doctor.lastName);
    emailController = TextEditingController(text: widget.doctor.email);
    phoneController = TextEditingController(text: widget.doctor.phone);
    specialtyController = TextEditingController(text: widget.doctor.specialty);
    qualificationController =
        TextEditingController(text: widget.doctor.qualification);
    descriptionController =
        TextEditingController(text: widget.doctor.description);

    // Initialize selected values
    selectedGender = widget.doctor.gender;
    selectedDepartment = widget.doctor.departmentId;
    selectedBloodGroup = widget.doctor.bloodGroup;
    selectedStatus = widget.doctor.status;

    // Parse date of birth if available
    try {
      if (widget.doctor.user['dob'] != null && widget.doctor.user['dob'].toString().isNotEmpty) {
        selectedDate = DateTime.parse(widget.doctor.user['dob']);
      } else {
        selectedDate = DateTime.now().subtract(const Duration(days: 365 * 30));
      }
    } catch (e) {
      selectedDate = DateTime.now().subtract(const Duration(days: 365 * 30));
      Get.log("Error parsing date: $e");
    }

    // Initialize department service
    try {
      departmentService = Get.find<DepartmentService>();
    } catch (e) {
      Get.log("Department service not initialized: $e");
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    specialtyController.dispose();
    qualificationController.dispose();
    descriptionController.dispose();
    super.dispose();
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
        decoration: BoxDecoration(
          color: notifier.getContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: notifier.getBorderColor),
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
                            child: TextFormField(
                              controller: firstNameController,
                              decoration: _inputDecoration(
                                  context, 'First Name', notifier),
                              validator: (value) =>
                              value!.isEmpty ? 'Required' : null,
                              style: TextStyle(color: notifier.getMainText),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: lastNameController,
                              decoration: _inputDecoration(
                                  context, 'Last Name', notifier),
                              validator: (value) =>
                              value!.isEmpty ? 'Required' : null,
                              style: TextStyle(color: notifier.getMainText),
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
                              decoration: _inputDecoration(
                                  context, 'Email', notifier,
                                  prefixIcon: Icons.email),
                              validator: (value) {
                                if (value!.isEmpty) return 'Required';
                                if (!GetUtils.isEmail(value))
                                  return 'Invalid email';
                                return null;
                              },
                              style: TextStyle(color: notifier.getMainText),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: phoneController,
                              decoration: _inputDecoration(
                                  context, 'Phone', notifier,
                                  prefixIcon: Icons.phone),
                              validator: (value) =>
                              value!.isEmpty ? 'Required' : null,
                              style: TextStyle(color: notifier.getMainText),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Gender & Status
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedGender,
                              decoration: _inputDecoration(
                                  context, 'Gender', notifier,
                                  prefixIcon: Icons.person),
                              items: ['male', 'female'].map((gender) {
                                return DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender.capitalizeFirst!,
                                      style: TextStyle(
                                          color: notifier.getMainText)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedGender = value;
                                  });
                                }
                              },
                              validator: (value) =>
                              value == null ? 'Required' : null,
                              dropdownColor: notifier.getContainer,
                              style: TextStyle(color: notifier.getMainText),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedStatus,
                              decoration: _inputDecoration(
                                  context, 'Status', notifier,
                                  prefixIcon: Icons.verified_user),
                              items: ['active', 'pending', 'blocked']
                                  .map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _getStatusColor(
                                              status, notifier),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        status.capitalizeFirst!,
                                        style: TextStyle(
                                            color: notifier.getMainText),
                                      ),
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
                              validator: (value) =>
                              value == null ? 'Required' : null,
                              dropdownColor: notifier.getContainer,
                              style: TextStyle(color: notifier.getMainText),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Date of Birth
                      GestureDetector(
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
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: _inputDecoration(
                              context,
                              'Date of Birth',
                              notifier,
                              prefixIcon: Icons.calendar_today,
                            ),
                            controller: TextEditingController(
                              text: DateFormat('yyyy-MM-dd').format(selectedDate),
                            ),
                            style: TextStyle(color: notifier.getMainText),
                          ),
                        ),
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
                            child: DropdownButtonFormField<String>(
                              value: selectedDepartment,
                              decoration: _inputDecoration(
                                  context, 'Department', notifier,
                                  prefixIcon: Icons.business),
                              items: departmentService.departments
                                  .where((dept) => dept.status.toLowerCase() == 'active')
                                  .map((dept) {
                                return DropdownMenuItem(
                                  value: dept.id,
                                  child: Text(dept.title,
                                      style: TextStyle(
                                          color: notifier.getMainText)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedDepartment = value;
                                  });
                                }
                              },
                              validator: (value) =>
                              value == null ? 'Required' : null,
                              dropdownColor: notifier.getContainer,
                              style: TextStyle(color: notifier.getMainText),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: specialtyController,
                              decoration: _inputDecoration(
                                  context, 'Specialty', notifier,
                                  prefixIcon: Icons.local_hospital),
                              validator: (value) =>
                              value!.isEmpty ? 'Required' : null,
                              style: TextStyle(color: notifier.getMainText),
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
                              decoration: _inputDecoration(
                                  context, 'Qualification', notifier,
                                  prefixIcon: Icons.school),
                              validator: (value) =>
                              value!.isEmpty ? 'Required' : null,
                              style: TextStyle(color: notifier.getMainText),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedBloodGroup,
                              decoration: _inputDecoration(
                                  context, 'Blood Group', notifier,
                                  prefixIcon: Icons.bloodtype),
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
                                  child: Text(group,
                                      style: TextStyle(
                                          color: notifier.getMainText)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedBloodGroup = value;
                                  });
                                }
                              },
                              dropdownColor: notifier.getContainer,
                              style: TextStyle(color: notifier.getMainText),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: descriptionController,
                        decoration: _inputDecoration(
                          context,
                          'Professional Description',
                          notifier,
                          prefixIcon: Icons.description,
                        ),
                        maxLines: 3,
                        validator: (value) =>
                        value!.isEmpty ? 'Required' : null,
                        style: TextStyle(color: notifier.getMainText),
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
        color: notifier.getIconColor.withOpacity(0.2),
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
              'Edit Doctor: Dr. ${widget.doctor.fullName}',
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
        color: notifier.getContainer,
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
              foregroundColor: notifier.getMainText,
            ),
            child:
            Text('Cancel', style: TextStyle(color: notifier.getMainText)),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: isLoading ? null : _updateDoctor,
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
                : const Text('Update Doctor'),
          ),
        ],
      ),
    );
  }

  void _updateDoctor() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // Prepare updated doctor data
        final Map<String, dynamic> doctorData = {
          "first_name": firstNameController.text,
          "last_name": lastNameController.text,
          "email": emailController.text,
          "phone": phoneController.text,
          "gender": selectedGender,
          "dob": DateFormat('yyyy-MM-dd').format(selectedDate),
          "blood_group": selectedBloodGroup,
          "qualification": qualificationController.text,
          "doctor_department_id": selectedDepartment,
          "specialist": specialtyController.text,
          "description": descriptionController.text,
          "status": selectedStatus,
        };

        // Call controller to update
        await doctorController.updateDoctor(widget.doctor.id, doctorData);

        // Close the dialog
        Navigator.pop(context);
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to update doctor: $e',
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

  InputDecoration _inputDecoration(
      BuildContext context,
      String label,
      ColourNotifier notifier, {
        IconData? prefixIcon,
      }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: notifier.getMaingey),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: notifier.getIconColor)
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: notifier.getBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: notifier.getBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: notifier.getIconColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xfff73164)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xfff73164), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      fillColor: notifier.getPrimaryColor,
      filled: true,
    );
  }

  Color _getStatusColor(String status, ColourNotifier notifier) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'blocked':
        return const Color(0xfff73164); // Using existing error color
      case 'pending':
        return Colors.orange;
      default:
        return appMainColor; // Using main app color
    }
  }
}