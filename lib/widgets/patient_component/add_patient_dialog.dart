import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ige_hospital/controllers/patient_controller.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/form/app_text_field.dart';
import 'package:ige_hospital/widgets/form/app_dropdown_field.dart';
import 'package:ige_hospital/widgets/ui/section_header.dart';
import 'package:provider/provider.dart';

class AddPatientDialog extends StatefulWidget {
  final PatientController controller;

  const AddPatientDialog({
    super.key,
    required this.controller,
  });

  @override
  State<AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends State<AddPatientDialog> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final dobController = TextEditingController();

  // Selected values
  String selectedGender = 'male';
  String selectedBloodGroup = 'O+';

  // Selected date
  late DateTime selectedDate;

  // Loading state
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize date to a sensible default (30 years ago)
    selectedDate = DateTime.now().subtract(const Duration(days: 365 * 30));
    dobController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
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
                    Icons.person_add,
                    color: notifier.getIconColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Add New Patient',
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
                                hintText: 'Enter patient first name',
                                controller: firstNameController,
                                validator: (value) =>
                                value?.isEmpty == true ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AppTextField(
                                label: 'Last Name',
                                hintText: 'Enter patient last name',
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
                                hintText: 'Enter patient email',
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
                                hintText: 'Enter patient phone number',
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
                                    hintText: 'Select date of birth',
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

                        // Blood Group
                        AppDropdownField<String>(
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
                        const SizedBox(height: 16),

                        // Address
                        AppTextField(
                          label: 'Address',
                          hintText: 'Enter patient address',
                          controller: addressController,
                          maxLines: 3,
                        ),
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
                    onPressed: isLoading ? null : _savePatient,
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
                        : Text('Save Patient'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _savePatient() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        final Map<String, dynamic> patientData = {
          'first_name': firstNameController.text,
          'last_name': lastNameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'gender': selectedGender,
          'dob': dobController.text,
          'blood_group': selectedBloodGroup,
          'address1': addressController.text,
          'status': 'active',
        };

        await widget.controller.addPatient(patientData);

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