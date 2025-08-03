import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/auth_service.dart';
import 'package:ige_hospital/provider/permission_service.dart';
import 'package:ige_hospital/pages/home.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/constants/user_roles.dart';
import 'package:ige_hospital/static_data.dart';
import 'package:ige_hospital/widgets/common_title.dart';
import 'package:provider/provider.dart';

class RoleBasedDashboard extends StatefulWidget {
  const RoleBasedDashboard({super.key});

  @override
  State<RoleBasedDashboard> createState() => _RoleBasedDashboardState();
}

class _RoleBasedDashboardState extends State<RoleBasedDashboard> {
  final AuthService authService = Get.find<AuthService>();
  final PermissionService permissionService = Get.find<PermissionService>();

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Obx(() {
      // Check if user is authenticated
      if (!authService.isAuthenticated.value) {
        return _buildLoadingScreen(notifier);
      }

      // Check if user data is available
      if (authService.currentUser.value == null) {
        return _buildLoadingScreen(notifier);
      }

      final userRole = permissionService.currentUserRole;
      Get.log("RoleBasedDashboard - Rendering for role: $userRole"); // Debug log

      // Route to appropriate dashboard based on user role
      switch (userRole) {
        case UserRoles.admin:
        case UserRoles.doctor:
        case UserRoles.receptionist:
        // Staff members get the full dashboard
          return const DefaultPage();

        case UserRoles.patient:
        // Patients get a simplified dashboard
          return _buildPatientDashboard(notifier);

        default:
        // Fallback for unknown roles
          Get.log("Unknown role: $userRole, showing default dashboard");
          return const DefaultPage();
      }
    });
  }

  Widget _buildLoadingScreen(ColourNotifier notifier) {
    return Scaffold(
      backgroundColor: notifier.getBgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: notifier.getIconColor),
            const SizedBox(height: 16),
            Text(
              'Loading your dashboard...',
              style: TextStyle(
                color: notifier.getMainText,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientDashboard(ColourNotifier notifier) {
    return Scaffold(
      backgroundColor: notifier.getBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CommonTitle(title: 'My Dashboard', path: "Patient Portal"),

              // Welcome Section
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: notifier.getContainer,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: boxShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: appMainColor.withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: appMainColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: TextStyle(
                                  color: notifier.getMaingey,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                authService.getUserName(),
                                style: TextStyle(
                                  color: notifier.getMainText,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Quick Actions for Patients
              Container(
                margin: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quick Actions",
                      style: TextStyle(
                        color: notifier.getMainText,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),

                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        _buildPatientActionCard(
                          'My Appointments',
                          Icons.calendar_today,
                          appMainColor,
                              () => Get.find<AppConst>().changePage('appointments'),
                          notifier,
                        ),
                        _buildPatientActionCard(
                          'My Profile',
                          Icons.person,
                          Colors.blue,
                              () => Get.find<AppConst>().changePage('profile'),
                          notifier,
                        ),
                        _buildPatientActionCard(
                          'Medical Records',
                          Icons.medical_information,
                          Colors.green,
                              () => Get.find<AppConst>().changePage('patients'),
                          notifier,
                        ),
                        _buildPatientActionCard(
                          'Consultations',
                          Icons.video_call,
                          Colors.purple,
                              () => Get.find<AppConst>().changePage('live-consultations'),
                          notifier,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Health Tips or Information Section
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: notifier.getContainer,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: boxShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.health_and_safety,
                          color: Colors.green,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Health Tips",
                          style: TextStyle(
                            color: notifier.getMainText,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "• Stay hydrated and drink plenty of water daily\n"
                          "• Maintain regular exercise routine\n"
                          "• Get adequate sleep (7-9 hours)\n"
                          "• Eat a balanced diet rich in fruits and vegetables\n"
                          "• Don't forget your regular check-ups",
                      style: TextStyle(
                        color: notifier.getMainText,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientActionCard(
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ColourNotifier notifier,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notifier.getContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: notifier.getBorderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: notifier.getMainText,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}