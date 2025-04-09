import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/provider/patient_service.dart';
import 'package:ige_hospital/widgets/common_button.dart';
import 'package:ige_hospital/widgets/text_field.dart';

class AddPatientDialog extends StatefulWidget {
  final ColourNotifier notifier;
  final PatientsService patientsService;

  const AddPatientDialog({
    super.key,
    required this.notifier,
    required this.patientsService,
  });

  @override
  State<AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends State<AddPatientDialog> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  String selectedGender = 'male';
  String selectedBloodGroup = 'O+';

  DateTime selectedDate = DateTime.now()
      .subtract(const Duration(days: 365 * 20)); // Default 20 years ago

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: widget.notifier.getContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content: StatefulBuilder(builder: (context, setState) {
        return Container(
          width: 500,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.notifier.getContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "Add New Patient",
                style: TextStyle(
                  color: widget.notifier.getMainText,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 15),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyTextField(
                        title: 'First Name',
                        hinttext: "Enter Patient's First Name",
                        controller: firstNameController,
                      ),
                      const SizedBox(height: 10),
                      MyTextField(
                        title: 'Last Name',
                        hinttext: "Enter Patient's Last Name",
                        controller: lastNameController,
                      ),
                      const SizedBox(height: 10),
                      MyTextField(
                        title: 'Email',
                        hinttext: "Enter Patient's Email",
                        controller: emailController,
                      ),
                      const SizedBox(height: 10),
                      MyTextField(
                        title: 'Phone',
                        hinttext: "Enter Patient's Phone Number",
                        controller: phoneController,
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );

                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                              dobController.text =
                                  DateFormat('yyyy-MM-dd').format(selectedDate);
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: MyTextField(
                            title: 'Date of Birth',
                            hinttext: DateFormat('yyyy-MM-dd').format(selectedDate),
                            controller: dobController,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Gender",
                                  style: mediumBlackTextStyle.copyWith(
                                    color: widget.notifier.getMainText,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                DropdownButtonFormField<String>(
                                  value: selectedGender,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: widget.notifier.getContainer,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.withOpacity(0.3)),
                                      borderRadius:
                                      const BorderRadius.all(Radius.circular(10)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: widget.notifier.getIconColor,
                                        width: 1.5,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 12),
                                  ),
                                  dropdownColor: widget.notifier.getContainer,
                                  style: TextStyle(color: widget.notifier.getMainText),
                                  items: [
                                    DropdownMenuItem(
                                      value: "male",
                                      child: Text("Male",
                                          style: TextStyle(
                                              color: widget.notifier.getMainText)),
                                    ),
                                    DropdownMenuItem(
                                      value: "female",
                                      child: Text("Female",
                                          style: TextStyle(
                                              color: widget.notifier.getMainText)),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        selectedGender = value;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Blood Group",
                                  style: mediumBlackTextStyle.copyWith(
                                    color: widget.notifier.getMainText,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                DropdownButtonFormField<String>(
                                  value: selectedBloodGroup,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: widget.notifier.getContainer,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.withOpacity(0.3)),
                                      borderRadius:
                                      const BorderRadius.all(Radius.circular(10)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: widget.notifier.getIconColor,
                                        width: 1.5,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 12),
                                  ),
                                  dropdownColor: widget.notifier.getContainer,
                                  style: TextStyle(color: widget.notifier.getMainText),
                                  items: [
                                    DropdownMenuItem(
                                      value: "A+",
                                      child: Text("A+",
                                          style: TextStyle(
                                              color: widget.notifier.getMainText)),
                                    ),
                                    DropdownMenuItem(
                                      value: "A-",
                                      child: Text("A-",
                                          style: TextStyle(
                                              color: widget.notifier.getMainText)),
                                    ),
                                    DropdownMenuItem(
                                      value: "B+",
                                      child: Text("B+",
                                          style: TextStyle(
                                              color: widget.notifier.getMainText)),
                                    ),
                                    DropdownMenuItem(
                                      value: "B-",
                                      child: Text("B-",
                                          style: TextStyle(
                                              color: widget.notifier.getMainText)),
                                    ),
                                    DropdownMenuItem(
                                      value: "AB+",
                                      child: Text("AB+",
                                          style: TextStyle(
                                              color: widget.notifier.getMainText)),
                                    ),
                                    DropdownMenuItem(
                                      value: "AB-",
                                      child: Text("AB-",
                                          style: TextStyle(
                                              color: widget.notifier.getMainText)),
                                    ),
                                    DropdownMenuItem(
                                      value: "O+",
                                      child: Text("O+",
                                          style: TextStyle(
                                              color: widget.notifier.getMainText)),
                                    ),
                                    DropdownMenuItem(
                                      value: "O-",
                                      child: Text("O-",
                                          style: TextStyle(
                                              color: widget.notifier.getMainText)),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        selectedBloodGroup = value;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CommonButton(
                    title: "Cancel",
                    color: const Color(0xfff73164),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 10),
                  CommonButton(
                    title: "Add Patient",
                    color: appMainColor,
                    onTap: () {
                      if (firstNameController.text.isEmpty ||
                          lastNameController.text.isEmpty ||
                          emailController.text.isEmpty ||
                          phoneController.text.isEmpty ||
                          dobController.text.isEmpty) {
                        Get.snackbar(
                          "Error",
                          "Please fill all required fields",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      final Map<String, dynamic> patientData = {
                        "first_name": firstNameController.text,
                        "last_name": lastNameController.text,
                        "email": emailController.text,
                        "phone": phoneController.text,
                        "dob": dobController.text,
                        "gender": selectedGender,
                        "blood_group": selectedBloodGroup,
                      };

                      // Here you would call to create patient
                      widget.patientsService.createPatient(patientData);

                      Get.snackbar(
                        "Success",
                        "Patient added successfully",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );

                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}