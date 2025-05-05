// lib/widgets/patient/edit_patient_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ige_hospital/controllers/patient_controller.dart';
import 'package:ige_hospital/models/patient_model.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/form/app_text_field.dart';
import 'package:ige_hospital/widgets/form/app_dropdown_field.dart';
import 'package:ige_hospital/widgets/ui/section_header.dart';
import 'package:provider/provider.dart';

class EditPatientDialog extends StatefulWidget {
  final PatientModel patient;
  final PatientController controller;

  const EditPatientDialog({
    super.key,
    required this.patient,
    required this.controller,
  });

  @override
  State<EditPatientDialog> createState() => _EditPatientDialogState();
}

class _EditPatientDialogState extends State<EditPatientDialog> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController dobController;

  // Selected values
  late String selectedGender;
  late String selectedBloodGroup;
  late String selectedStatus;

  // Selected date
  late DateTime selectedDate;

  // Loading state
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with patient data
    firstNameController = TextEditingController(text: widget.patient.user['first_name'] ?? '');
    lastNameController = TextEditingController(text: widget.patient.user['last_name'] ?? '');
    emailController = TextEditingController(text: widget.patient.user['email'] ?? '');
    phoneController = TextEditingController(text: widget.patient.user['phone'] ?? '');

    // Initialize address controller
    if (widget.patient.address != null && widget.patient.address!['address1'] != null) {
      addressController = TextEditingController(text: widget.patient.address!['address1']);
    } else {
      addressController = TextEditingController();
    }

    // Initialize date of birth
    final String dob = widget.patient.user['dob'] ?? '';
    if (dob.isNotEmpty) {
      try {
        selectedDate = DateTime.parse(dob);
        dobController = TextEditingController(text: dob);
      } catch (e) {
        selectedDate = DateTime.now().subtract(const Duration(days: 365 * 30));
        dobController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(selectedDate));
      }
    } else {
      selectedDate = DateTime.now().subtract(const Duration(days: 365 * 30));
      dobController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(selectedDate));
    }

    // Initialize selected values
    selectedGender = widget.patient.user['gender'] ?? 'male';
    selectedBloodGroup = widget.patient.user['blood_group'] ?? 'O+';
    selectedStatus = widget.patient.user['status'] ?? 'active';
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    dobController.dispose();
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
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
                  Text(
                    'Edit Patient',
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
            ),

            // Form content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: 'Personal Information',
                          fontSize: 16,
                        ),
                        const SizedBox(height: 16),

                        // First and Last Name
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: 'First Name',
                                controller: firstNameController,
                                validator: (value) =>
                                value?.isEmpty == true ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AppTextField(
                                label: 'Last Name',
                                controller: lastNameController,
                                validator: (value) =>
                                value?.isEmpty == true ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Email and Phone
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: 'Email',
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value?.isEmpty == true) return 'Required';
                                  if (value != null && !GetUtils.isEmail(value)) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AppTextField(
                                label: 'Phone',
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                validator: (value) =>
                                value?.isEmpty == true ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Gender and Date of Birth
                        Row(
                          children: [
                            Expanded(
                              child: AppDropdownField<String>(
                                label: 'Gender',
                                value: selectedGender,
                                items: [
                                  DropdownMenuItem(value: 'male', child: Text('Male')),
                                  DropdownMenuItem(value: 'female', child: Text('Female')),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedGender = value;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final DateTime? date = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime(1900),
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
                                    suffixIcon: Icons.calendar_today,
                                    validator: (value) =>
                                    value?.isEmpty == true ? 'Required' : null,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Blood Group and Status
                        Row(
                          children: [
                            Expanded(
                              child: AppDropdownField<String>(
                                label: 'Blood Group',
                                value: selectedBloodGroup,
                                items: [
                                  DropdownMenuItem(value: 'A+', child: Text('A+')),
                                  DropdownMenuItem(value: 'A-', child: Text('A-')),
                                  DropdownMenuItem(value: 'B+', child: Text('B+')),
                                  DropdownMenuItem(value: 'B-', child: Text('B-')),
                                  DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                                  DropdownMenuItem(value: 'AB-', child: Text('AB-')),
                                  DropdownMenuItem(value: 'O+', child: Text('O+')),
                                  DropdownMenuItem(value: 'O-', child: Text('O-')),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedBloodGroup = value;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AppDropdownField<String>(
                                label: 'Status',
                                value: selectedStatus,
                                items: [
                                  DropdownMenuItem(
                                    value: 'active',
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.green,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text('Active'),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'pending',
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.orange,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text('Pending'),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'blocked',
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.red,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text('Blocked'),
                                      ],
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedStatus = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Address
                        AppTextField(
                          label: 'Address',
                          controller: addressController,
                          maxLines: 3,
                        ),

                        // Additional template fields if present
                        if (widget.patient.template != null && widget.patient.template!.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          SectionHeader(
                            title: 'Additional Information',
                            fontSize: 16,
                          ),
                          const SizedBox(height: 16),

                          ...widget.patient.template!.entries.map((entry) {
                            if (entry.value != null) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Text(
                                      "${entry.key.toString().replaceAll('_', ' ').capitalizeFirst!}: ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: notifier.getMainText,
                                      ),
                                    ),
                                    Text(
                                      entry.value.toString(),
                                      style: TextStyle(
                                        color: notifier.getMainText,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }).toList(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Footer with actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: notifier.getBorderColor),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: notifier.getMainText,
                      side: BorderSide(color: notifier.getBorderColor),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: isLoading ? null : _updatePatient,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: notifier.getIconColor,
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
                        : Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updatePatient() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // Prepare address data
        Map<String, dynamic> addressData = {};
        if (widget.patient.address != null) {
          addressData = Map.from(widget.patient.address!);
        }
        addressData['address1'] = addressController.text;

        final Map<String, dynamic> patientData = {
          'first_name': firstNameController.text,
          'last_name': lastNameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'gender': selectedGender,
          'dob': dobController.text,
          'blood_group': selectedBloodGroup,
          'status': selectedStatus,
          'address': addressData,
        };

        await widget.controller.updatePatient(widget.patient.id, patientData);

        Navigator.pop(context);
      } catch (e) {
        // Error is already handled in the controller
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }
}