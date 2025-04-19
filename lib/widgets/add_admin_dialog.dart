import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/provider/admin_service.dart';
import 'package:ige_hospital/widgets/common_button.dart';
import 'package:ige_hospital/widgets/text_field.dart';

class AddAdminDialog extends StatefulWidget {
  final ColourNotifier notifier;
  final AdminsService adminsService;

  const AddAdminDialog({
    super.key,
    required this.notifier,
    required this.adminsService,
  });

  @override
  State<AddAdminDialog> createState() => _AddAdminDialogState();
}

class _AddAdminDialogState extends State<AddAdminDialog> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String selectedGender = 'male';
  bool isDefault = false;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Add New Administrator",
                    style: TextStyle(
                      color: widget.notifier.getMainText,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: widget.notifier.getIconColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Personal Information Section
                      _buildSectionTitle("Personal Information"),
                      const SizedBox(height: 15),

                      // First Name & Last Name
                      Row(
                        children: [
                          Expanded(
                            child: MyTextField(
                              title: 'First Name',
                              hinttext: "Enter First Name",
                              controller: firstNameController,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MyTextField(
                              title: 'Last Name',
                              hinttext: "Enter Last Name",
                              controller: lastNameController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Email & Phone
                      Row(
                        children: [
                          Expanded(
                            child: MyTextField(
                              title: 'Email',
                              hinttext: "Enter Email Address",
                              controller: emailController,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MyTextField(
                              title: 'Phone',
                              hinttext: "Enter Phone Number",
                              controller: phoneController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Gender
                      Column(
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
                      const SizedBox(height: 15),

                      // Account Information Section
                      _buildSectionTitle("Account Information"),
                      const SizedBox(height: 15),

                      // Password & Confirm Password
                      Row(
                        children: [
                          Expanded(
                            child: MyTextField(
                              title: 'Password',
                              hinttext: "Enter Password",
                              controller: passwordController,
                              obscureText: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MyTextField(
                              title: 'Confirm Password',
                              hinttext: "Confirm Password",
                              controller: confirmPasswordController,
                              obscureText: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Default Admin Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: isDefault,
                            activeColor: widget.notifier.getIconColor,
                            onChanged: (value) {
                              setState(() {
                                isDefault = value ?? false;
                              });
                            },
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "Make Default Administrator",
                            style: TextStyle(
                              color: widget.notifier.getMainText,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Action Buttons
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
                    title: "Add Administrator",
                    color: appMainColor,
                    onTap: () {
                      _validateAndSubmit();
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

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: widget.notifier.getMainText,
        ),
      ),
    );
  }

  void _validateAndSubmit() {
    // Check for empty fields
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all required fields",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Check for valid email
    if (!GetUtils.isEmail(emailController.text)) {
      Get.snackbar(
        "Error",
        "Please enter a valid email address",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Check if passwords match
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        "Error",
        "Passwords do not match",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final Map<String, dynamic> adminData = {
      "first_name": firstNameController.text,
      "last_name": lastNameController.text,
      "email": emailController.text,
      "phone": phoneController.text,
      "password": passwordController.text,
      "password_confirmation": confirmPasswordController.text,
      "gender": selectedGender,
      "is_default": isDefault,
    };

    // Submit to service
    widget.adminsService.createAdmin(adminData);

    // Close dialog
    Navigator.pop(context);
  }
}