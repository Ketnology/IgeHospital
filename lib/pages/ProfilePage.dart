import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/auth_controller.dart';
import 'package:ige_hospital/provider/auth_service.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/static_data/static_data.dart';
import 'package:ige_hospital/widgets/common_button.dart';
import 'package:ige_hospital/widgets/common_title.dart';
import 'package:ige_hospital/widgets/text_field.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService authService = Get.find<AuthService>();
  final AuthController authController = Get.find<AuthController>();
  late UserModel? user;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final designationController = TextEditingController();
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() {
    user = authService.currentUser.value;
    if (user != null) {
      nameController.text = user!.name;
      emailController.text = user!.email;
      phoneController.text = user!.phone;
      designationController.text = user!.designation;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Scaffold(
      backgroundColor: notifier.getBgColor,
      body: SafeArea(
        child: Column(
          children: [
            const CommonTitle(title: 'Profile', path: "Account/Profile"),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      _buildProfileHeader(notifier),
                      const SizedBox(height: 20),
                      _buildProfileDetails(notifier),
                      const SizedBox(height: 20),
                      if (isEditing) _buildEditButtons(notifier),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ColourNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: notifier.getContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: boxShadow,
      ),
      child: Row(
        children: [
          // Profile image
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/profile.png'),
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: 20),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                  authController.userName.value,
                  style: mainTextStyle.copyWith(
                    fontSize: 24,
                    color: notifier.getMainText,
                  ),
                )),
                const SizedBox(height: 5),
                Obx(() => Text(
                  authController.userRole.value,
                  style: mediumGreyTextStyle.copyWith(
                    fontSize: 16,
                  ),
                )),
                const SizedBox(height: 5),
                Obx(() => Text(
                  authController.userEmail.value,
                  style: mediumGreyTextStyle,
                )),
              ],
            ),
          ),
          // Edit button
          IconButton(
            icon: Icon(
              isEditing ? Icons.close : Icons.edit,
              color: notifier.getIconColor,
            ),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
                if (!isEditing) {
                  loadUserData(); // Reset to original data if canceling edit
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails(ColourNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: notifier.getContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: boxShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Personal Information",
            style: mainTextStyle.copyWith(
              fontSize: 18,
              color: notifier.getMainText,
            ),
          ),
          const SizedBox(height: 20),

          // Full Name
          MyTextField(
            title: 'Full Name',
            hinttext: "Enter your full name",
            controller: nameController,
            enabled: isEditing,
          ),
          const SizedBox(height: 15),

          // Email
          MyTextField(
            title: 'Email',
            hinttext: "Enter your email",
            controller: emailController,
            enabled: isEditing,
          ),
          const SizedBox(height: 15),

          // Phone Number
          MyTextField(
            title: 'Phone Number',
            hinttext: "Enter your phone number",
            controller: phoneController,
            enabled: isEditing,
          ),
          const SizedBox(height: 15),

          // Designation
          MyTextField(
            title: 'Designation',
            hinttext: "Enter your designation",
            controller: designationController,
            enabled: isEditing,
          ),

          // Additional User Details
          if (user != null && user!.additionalData != null)
            _buildAdditionalDetails(notifier),
        ],
      ),
    );
  }

  Widget _buildAdditionalDetails(ColourNotifier notifier) {
    final additionalFields = [
      {'label': 'Gender', 'key': 'gender'},
      {'label': 'Date of Birth', 'key': 'dob'},
      {'label': 'Blood Group', 'key': 'blood_group'},
      {'label': 'Qualification', 'key': 'qualification'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          "Additional Information",
          style: mainTextStyle.copyWith(
            fontSize: 18,
            color: notifier.getMainText,
          ),
        ),
        const SizedBox(height: 15),

        ...additionalFields.map((field) {
          final value = user!.additionalData![field['key']] ?? 'Not specified';
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    "${field['label']}:",
                    style: mediumBlackTextStyle.copyWith(
                      color: notifier.getMainText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value.toString(),
                    style: mediumBlackTextStyle.copyWith(
                      color: notifier.getMainText,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),

        // Social Media Links
        if (user!.additionalData!.containsKey('facebook_url') ||
            user!.additionalData!.containsKey('twitter_url') ||
            user!.additionalData!.containsKey('instagram_url') ||
            user!.additionalData!.containsKey('linkedIn_url'))
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Social Media",
                style: mainTextStyle.copyWith(
                  fontSize: 18,
                  color: notifier.getMainText,
                ),
              ),
              const SizedBox(height: 15),

              _buildSocialMediaLink(
                  notifier,
                  'Facebook',
                  'facebook_url',
                  Icons.facebook
              ),
              _buildSocialMediaLink(
                  notifier,
                  'Twitter',
                  'twitter_url',
                  Icons.flutter_dash
              ),
              _buildSocialMediaLink(
                  notifier,
                  'Instagram',
                  'instagram_url',
                  Icons.camera_alt
              ),
              _buildSocialMediaLink(
                  notifier,
                  'LinkedIn',
                  'linkedIn_url',
                  Icons.business
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSocialMediaLink(
      ColourNotifier notifier,
      String label,
      String key,
      IconData icon
      ) {
    final url = user!.additionalData![key];
    if (url == null || url.toString().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: notifier.getIconColor, size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: mediumBlackTextStyle.copyWith(
              color: notifier.getMainText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButtons(ColourNotifier notifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CommonButton(
          title: "Cancel",
          color: const Color(0xfff73164),
          onTap: () {
            setState(() {
              isEditing = false;
              loadUserData(); // Reset to original data
            });
          },
        ),
        const SizedBox(width: 10),
        CommonButton(
          title: "Save Changes",
          color: appMainColor,
          onTap: () {
            // Here you would implement the API call to update the user profile
            // For now we'll just show a success message
            Get.snackbar(
              "Success",
              "Profile updated successfully",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
            setState(() {
              isEditing = false;
            });
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    designationController.dispose();
    super.dispose();
  }
}