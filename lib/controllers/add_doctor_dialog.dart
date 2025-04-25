import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'doctor_controller.dart';

class AddDoctorDialog extends StatefulWidget {
  const AddDoctorDialog({super.key});

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
  final specialtyController = TextEditingController();
  final qualificationController = TextEditingController();
  final descriptionController = TextEditingController();

  // Selected values
  String selectedGender = 'Male';
  String selectedDepartment = 'Cardiology';
  String selectedBloodGroup = 'O+';

  // Selected date
  DateTime selectedDate = DateTime.now().subtract(
      const Duration(days: 365 * 30));

  // Loading state
  bool isLoading = false;

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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 600,
        constraints: BoxConstraints(
          maxHeight: MediaQuery
              .of(context)
              .size
              .height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context),

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
                      _buildSectionTitle(context, 'Personal Information'),
                      const SizedBox(height: 16),

                      // First & Last Name
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: firstNameController,
                              decoration: _inputDecoration(
                                  context, 'First Name'),
                              validator: (value) =>
                              value!.isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: lastNameController,
                              decoration: _inputDecoration(
                                  context, 'Last Name'),
                              validator: (value) =>
                              value!.isEmpty
                                  ? 'Required'
                                  : null,
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
                                  context, 'Email', prefixIcon: Icons.email),
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
                            child: TextFormField(
                              controller: phoneController,
                              decoration: _inputDecoration(
                                  context, 'Phone', prefixIcon: Icons.phone),
                              validator: (value) =>
                              value!.isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Gender & Date of Birth
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedGender,
                              decoration: _inputDecoration(
                                  context, 'Gender', prefixIcon: Icons.person),
                              items: ['Male', 'Female'].map((gender) {
                                return DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
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
                              value == null
                                  ? 'Required'
                                  : null,
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
                                          primary: Theme
                                              .of(context)
                                              .primaryColor,
                                        ),
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
                                    prefixIcon: Icons.calendar_today,
                                  ),
                                  controller: TextEditingController(
                                    text: DateFormat('MMM dd, yyyy').format(
                                        selectedDate),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Professional Information
                      _buildSectionTitle(context, 'Professional Information'),
                      const SizedBox(height: 16),

                      // Department & Specialty
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedDepartment,
                              decoration: _inputDecoration(
                                  context, 'Department',
                                  prefixIcon: Icons.business),
                              items: [
                                'Cardiology',
                                'Neurology',
                                'Orthopedics',
                                'Pediatrics',
                                'Dermatology',
                                'Ophthalmology',
                                'Gynecology',
                              ].map((department) {
                                return DropdownMenuItem(
                                  value: department,
                                  child: Text(department),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedDepartment = value;
                                    // Update specialty based on department
                                    switch (value) {
                                      case 'Cardiology':
                                        specialtyController.text =
                                        'Cardiologist';
                                        break;
                                      case 'Neurology':
                                        specialtyController.text =
                                        'Neurologist';
                                        break;
                                      case 'Orthopedics':
                                        specialtyController.text =
                                        'Orthopedic Surgeon';
                                        break;
                                      case 'Pediatrics':
                                        specialtyController.text =
                                        'Pediatrician';
                                        break;
                                      case 'Dermatology':
                                        specialtyController.text =
                                        'Dermatologist';
                                        break;
                                      case 'Ophthalmology':
                                        specialtyController.text =
                                        'Ophthalmologist';
                                        break;
                                      case 'Gynecology':
                                        specialtyController.text =
                                        'Gynecologist';
                                        break;
                                    }
                                  });
                                }
                              },
                              validator: (value) =>
                              value == null
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: specialtyController,
                              decoration: _inputDecoration(context, 'Specialty',
                                  prefixIcon: Icons.local_hospital),
                              validator: (value) =>
                              value!.isEmpty
                                  ? 'Required'
                                  : null,
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
                                  context, 'Qualification',
                                  prefixIcon: Icons.school),
                              validator: (value) =>
                              value!.isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedBloodGroup,
                              decoration: _inputDecoration(
                                  context, 'Blood Group',
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
                          prefixIcon: Icons.description,
                        ),
                        maxLines: 3,
                        validator: (value) =>
                        value!.isEmpty
                            ? 'Required'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer with actions
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme
            .of(context)
            .primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.person_add,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Text(
            'Add New Doctor',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.2)),
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
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: isLoading ? null : _saveDoctor,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme
                  .of(context)
                  .primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : const Text('Save Doctor'),
          ),
        ],
      ),
    );
  }

  void _saveDoctor() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // Make sure the controller is available
        DoctorController controller;
        try {
          controller = Get.find<DoctorController>();
        } catch (e) {
          // If controller is not found, create a new instance
          controller = Get.put(DoctorController());
        }

        // Add the doctor using the controller method
        controller.addDoctor(
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          email: emailController.text,
          phone: phoneController.text,
          gender: selectedGender,
          department: selectedDepartment,
          specialty: specialtyController.text,
          qualification: qualificationController.text,
          description: descriptionController.text,
          bloodGroup: selectedBloodGroup,
        );

        // Close the dialog
        Navigator.pop(context);

        // Show success message
        Get.snackbar(
          'Success',
          'Doctor added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        // Show error message
        Get.snackbar(
          'Error',
          'Failed to add doctor: $e',
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

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme
                .of(context)
                .primaryColor,
          ),
        ),
        const SizedBox(height: 5),
        Divider(color: Colors.grey.withOpacity(0.3)),
      ],
    );
  }

  InputDecoration _inputDecoration(BuildContext context,
      String label, {
        IconData? prefixIcon,
      }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Theme
            .of(context)
            .primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );
  }
}