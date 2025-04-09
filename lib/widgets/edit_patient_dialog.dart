import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/models/patient_model.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/provider/patient_service.dart';
import 'package:ige_hospital/widgets/common_button.dart';
import 'package:ige_hospital/widgets/text_field.dart';

class EditPatientDialog extends StatefulWidget {
  final PatientModel patient;
  final ColourNotifier notifier;
  final PatientsService patientsService;

  const EditPatientDialog({
    super.key,
    required this.patient,
    required this.notifier,
    required this.patientsService,
  });

  @override
  State<EditPatientDialog> createState() => _EditPatientDialogState();
}

class _EditPatientDialogState extends State<EditPatientDialog> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController dobController;
  // late TextEditingController qualificationController;
  late TextEditingController addressController;

  late String selectedGender;
  late String selectedBloodGroup;
  late String selectedStatus;

  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();

    String fullName = widget.patient.user['full_name'] ?? '';
    List<String> nameParts = fullName.split(' ');

    String firstName = nameParts.isNotEmpty ? nameParts.first : '';
    String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    firstNameController = TextEditingController(text: firstName);
    lastNameController = TextEditingController(text: lastName);

    emailController = TextEditingController(text: widget.patient.user['email'] ?? '');
    phoneController = TextEditingController(text: widget.patient.user['phone'] ?? '');
    dobController = TextEditingController(text: widget.patient.user['dob'] ?? '');
    // qualificationController = TextEditingController(text: widget.patient.user['qualification'] ?? '');
    addressController = TextEditingController(
        text: widget.patient.address != null
            ? " ${widget.patient.address!['address1'] ?? ''}"
            : '');

    // Initialize dropdowns with patient data
    selectedGender = widget.patient.user['gender']?.toLowerCase() ?? 'male';
    selectedBloodGroup = widget.patient.user['blood_group'] ?? 'O+';
    selectedStatus = widget.patient.user['status'] ?? 'active';

    // Parse date of birth if available
    try {
      selectedDate = widget.patient.user['dob'] != null && widget.patient.user['dob'].isNotEmpty
          ? DateFormat('yyyy-MM-dd').parse(widget.patient.user['dob'])
          : DateTime.now().subtract(const Duration(days: 365 * 20));
    } catch (e) {
      selectedDate = DateTime.now().subtract(const Duration(days: 365 * 20));
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    // qualificationController.dispose();
    addressController.dispose();
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
          width: 600,
          height: 600,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.notifier.getContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: [
                  // Show patient image if available
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade200,
                    child: widget.patient.user['profile_image'] != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(
                        widget.patient.user['profile_image'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(
                              Icons.person,
                              size: 30,
                              color: widget.notifier.getIconColor,
                            ),
                      ),
                    )
                        : Icon(
                      Icons.person,
                      size: 30,
                      color: widget.notifier.getIconColor,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Edit Patient Profile",
                          style: TextStyle(
                            color: widget.notifier.getMainText,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          "ID: ${widget.patient.patientUniqueId}",
                          style: TextStyle(
                            color: widget.notifier.getMaingey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: widget.notifier.getIconColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyTextField(
                        title: 'First Name',
                        hinttext: "Enter Patient's First Name",
                        controller: firstNameController,
                      ),
                      const SizedBox(height: 15),
                      MyTextField(
                        title: 'Last Name',
                        hinttext: "Enter Patient's Last Name",
                        controller: lastNameController,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final DateTime? pickedDate =
                                await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: widget.notifier.getIconColor,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );

                                if (pickedDate != null) {
                                  setState(() {
                                    selectedDate = pickedDate;
                                    dobController.text =
                                        DateFormat('yyyy-MM-dd')
                                            .format(selectedDate);
                                  });
                                }
                              },
                              child: AbsorbPointer(
                                child: MyTextField(
                                  title: 'Date of Birth',
                                  hinttext: dobController.text.isNotEmpty
                                      ? dobController.text
                                      : DateFormat('yyyy-MM-dd')
                                      .format(selectedDate),
                                  controller: dobController,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
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
                                          color:
                                          Colors.grey.withOpacity(0.3)),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: widget.notifier.getIconColor,
                                        width: 1.5,
                                      ),
                                    ),
                                    contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 12),
                                  ),
                                  dropdownColor: widget.notifier.getContainer,
                                  style:
                                  TextStyle(color: widget.notifier.getMainText),
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
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
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
                                          color:
                                          Colors.grey.withOpacity(0.3)),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: widget.notifier.getIconColor,
                                        width: 1.5,
                                      ),
                                    ),
                                    contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 12),
                                  ),
                                  dropdownColor: widget.notifier.getContainer,
                                  style:
                                  TextStyle(color: widget.notifier.getMainText),
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
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Status",
                                  style: mediumBlackTextStyle.copyWith(
                                    color: widget.notifier.getMainText,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                DropdownButtonFormField<String>(
                                  value: selectedStatus,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: widget.notifier.getContainer,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                          Colors.grey.withOpacity(0.3)),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: widget.notifier.getIconColor,
                                        width: 1.5,
                                      ),
                                    ),
                                    contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 12),
                                  ),
                                  dropdownColor: widget.notifier.getContainer,
                                  style:
                                  TextStyle(color: widget.notifier.getMainText),
                                  items: [
                                    DropdownMenuItem(
                                      value: "active",
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.green,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text("Active",
                                              style: TextStyle(
                                                  color:
                                                  widget.notifier.getMainText)),
                                        ],
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: "blocked",
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text("Blocked",
                                              style: TextStyle(
                                                  color:
                                                  widget.notifier.getMainText)),
                                        ],
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: "pending",
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.orange,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text("Pending",
                                              style: TextStyle(
                                                  color:
                                                  widget.notifier.getMainText)),
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
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      // MyTextField(
                      //   title: 'Qualification',
                      //   hinttext: "Enter Patient's Qualification",
                      //   controller: qualificationController,
                      // ),
                      // const SizedBox(height: 15),
                      MyTextField(
                        title: 'Address',
                        hinttext: "Enter Patient's Full Address",
                        controller: addressController,
                      ),

                      // Additional fields section
                      if (widget.patient.template != null) ...[
                        const SizedBox(height: 20),
                        Text(
                          "Additional Information",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.notifier.getMainText,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Display custom template fields
                        ...widget.patient.template!.entries.map((entry) {
                          if (entry.value != null) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Text(
                                    "${entry.key.toString().replaceAll('_', ' ').capitalizeFirst!}: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: widget.notifier.getMainText,
                                    ),
                                  ),
                                  Text(
                                    entry.value.toString(),
                                    style: TextStyle(
                                        color: widget.notifier.getMainText),
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
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
                        title: "Save Changes",
                        color: appMainColor,
                        onTap: () {
                          if (firstNameController.text.isEmpty ||
                              lastNameController.text.isEmpty ||
                              emailController.text.isEmpty ||
                              phoneController.text.isEmpty) {
                            Get.snackbar(
                              "Error",
                              "Please fill all required fields",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          // Parse address into components if changed
                          Map<String, dynamic> addressData = {};
                          if (widget.patient.address != null) {
                            addressData = Map.from(widget.patient.address!);
                          }
                          if (addressController.text !=
                              "${widget.patient.address?['street'] ?? ''}, ${widget.patient.address?['city'] ?? ''}") {
                            // Simple parsing - in a real app, you'd have separate fields
                            List<String> addressParts =
                            addressController.text.split(',');
                            if (addressParts.isNotEmpty) {
                              addressData['street'] = addressParts[0].trim();
                            }
                            if (addressParts.length > 1) {
                              addressData['city'] = addressParts[1].trim();
                            }
                          }

                          // Prepare the data to be updated
                          final Map<String, dynamic> userData = {
                            "first_name": firstNameController.text,
                            "last_name": lastNameController.text,
                            "email": emailController.text,
                            "phone": phoneController.text,
                            "dob": dobController.text,
                            "gender": selectedGender,
                            "blood_group": selectedBloodGroup,
                            // "qualification": qualificationController.text,
                            "address1": addressController.text,
                            "status": selectedStatus,
                            "address": addressData,
                          };

                          // Update the patient
                          widget.patientsService.updatePatient(widget.patient.id, userData);

                          Navigator.pop(context);
                        },
                      ),
                    ],
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