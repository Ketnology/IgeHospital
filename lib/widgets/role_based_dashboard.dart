import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/provider/dashboard_service.dart';
import 'package:ige_hospital/provider/permission_service.dart';
import 'package:ige_hospital/static_data.dart';
import 'package:ige_hospital/widgets/common_title.dart';
import 'package:ige_hospital/widgets/dashboard_data_card.dart';
import 'package:ige_hospital/widgets/permission_wrapper.dart';
import 'package:ige_hospital/widgets/role_based_widget.dart';
import 'package:ige_hospital/constants/user_roles.dart';
import 'package:provider/provider.dart';

class RoleBasedDashboard extends StatefulWidget {
  const RoleBasedDashboard({super.key});

  @override
  State<RoleBasedDashboard> createState() => _RoleBasedDashboardState();
}

class _RoleBasedDashboardState extends State<RoleBasedDashboard> {
  late DashboardService dashboardService;
  late PermissionService permissionService;
  late ColourNotifier notifier;

  @override
  void initState() {
    super.initState();
    dashboardService = Get.find<DashboardService>();
    permissionService = Get.find<PermissionService>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      dashboardService.fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColourNotifier>(context);

    return Scaffold(
      backgroundColor: notifier.getBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CommonTitle(title: 'Dashboard', path: "Overview"),
              _buildRefreshButton(),
              _buildRoleBasedContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBasedContent() {
    return RoleBasedWidget(
      roleWidgets: {
        UserRoles.admin: _buildAdminDashboard(),
        UserRoles.doctor: _buildDoctorDashboard(),
        UserRoles.receptionist:
            _buildReceptionistDashboard(), // Updated from nurse
        UserRoles.patient: _buildPatientDashboard(),
      },
      defaultWidget: _buildDefaultDashboard(),
    );
  }

  // ... (keep _buildAdminDashboard, _buildDoctorDashboard, _buildPatientDashboard the same)

  Widget _buildAdminDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hospital Management Overview",
            style: TextStyle(
              color: notifier.getMainText,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),

          // Admin sees all dashboard cards
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth < 600
                  ? 1
                  : constraints.maxWidth < 900
                      ? 2
                      : 4;

              return GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3.0,
                ),
                children: [
                  Obx(() => DashboardDataCard(
                        title: "Doctors",
                        count: dashboardService.doctorCount.toString(),
                        icon: Icons.medical_services,
                        iconColor: Colors.blue,
                        onTap: () => Get.find<AppConst>().changePage('doctors'),
                      )),
                  Obx(() => DashboardDataCard(
                        title: "Patients",
                        count: dashboardService.patientCount.toString(),
                        icon: Icons.people,
                        iconColor: appMainColor,
                        onTap: () =>
                            Get.find<AppConst>().changePage('patients'),
                      )),
                  Obx(() => DashboardDataCard(
                        title: "Receptionists",
                        count: dashboardService.receptionistCount.toString(),
                        icon: Icons.support_agent,
                        iconColor: Colors.orange,
                        onTap: () => Get.find<AppConst>().changePage('nurses'),
                      )),
                  Obx(() => DashboardDataCard(
                        title: "Administrators",
                        count: dashboardService.adminCount.toString(),
                        icon: Icons.admin_panel_settings,
                        iconColor: Colors.purple,
                        onTap: () => Get.find<AppConst>().changePage('admins'),
                      )),
                ],
              );
            },
          ),

          const SizedBox(height: 24),
          _buildRecentAppointments(),
          const SizedBox(height: 24),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildDoctorDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Doctor Portal",
            style: TextStyle(
              color: notifier.getMainText,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),

          // Doctor sees limited dashboard
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth < 600 ? 1 : 2;

              return GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3.0,
                ),
                children: [
                  Obx(() => DashboardDataCard(
                        title: "View Patients",
                        count: dashboardService.patientCount.toString(),
                        icon: Icons.people,
                        iconColor: appMainColor,
                        onTap: () =>
                            Get.find<AppConst>().changePage('patients'),
                      )),
                  DashboardDataCard(
                    title: "My Appointments",
                    count: "0", // Would need doctor-specific data
                    icon: Icons.calendar_today,
                    iconColor: Colors.green,
                    onTap: () =>
                        Get.find<AppConst>().changePage('appointments'),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),
          _buildDoctorAppointments(),
          const SizedBox(height: 24),
          _buildDoctorQuickActions(),
        ],
      ),
    );
  }

  Widget _buildReceptionistDashboard() {
    // Renamed from _buildNurseDashboard
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Receptionist Portal", // Updated title
            style: TextStyle(
              color: notifier.getMainText,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),

          // Receptionist sees patient and appointment data
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth < 600 ? 1 : 2;

              return GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3.0,
                ),
                children: [
                  Obx(() => DashboardDataCard(
                        title: "Patients",
                        count: dashboardService.patientCount.toString(),
                        icon: Icons.people,
                        iconColor: appMainColor,
                        onTap: () =>
                            Get.find<AppConst>().changePage('patients'),
                      )),
                  DashboardDataCard(
                    title: "Today's Appointments",
                    count: "0", // Would need today's appointment count
                    icon: Icons.calendar_today,
                    iconColor: Colors.green,
                    onTap: () =>
                        Get.find<AppConst>().changePage('appointments'),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),
          _buildReceptionistTaskList(), // Renamed from _buildNurseTaskList
        ],
      ),
    );
  }

  Widget _buildReceptionistTaskList() {
    // Renamed from _buildNurseTaskList
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Tasks",
          style: TextStyle(
            color: notifier.getMainText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notifier.getContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: notifier.getBorderColor),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.person_add, color: notifier.getIconColor),
                title: Text("Patient registration",
                    style: TextStyle(color: notifier.getMainText)),
                subtitle: Text("3 patients waiting",
                    style: TextStyle(color: notifier.getMaingey)),
              ),
              ListTile(
                leading: Icon(Icons.schedule, color: notifier.getIconColor),
                title: Text("Appointment scheduling",
                    style: TextStyle(color: notifier.getMainText)),
                subtitle: Text("5 appointments today",
                    style: TextStyle(color: notifier.getMaingey)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPatientDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Patient Portal",
            style: TextStyle(
              color: notifier.getMainText,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          // Patient dashboard content...
          Text("Patient content goes here",
              style: TextStyle(color: notifier.getMainText)),
        ],
      ),
    );
  }

  Widget _buildDefaultDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome to IGE Hospital",
            style: TextStyle(
              color: notifier.getMainText,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Please contact your administrator for access.",
            style: TextStyle(color: notifier.getMaingey),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAppointments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recent Appointments",
          style: TextStyle(
            color: notifier.getMainText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (dashboardService.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(color: notifier.getIconColor),
            );
          }

          if (dashboardService.recentAppointments.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: notifier.getContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: notifier.getBorderColor),
              ),
              child: Center(
                child: Text(
                  "No recent appointments",
                  style: TextStyle(color: notifier.getMaingey),
                ),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dashboardService.recentAppointments.length,
            itemBuilder: (context, index) {
              final appointment = dashboardService.recentAppointments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: notifier.getContainer,
                child: ListTile(
                  title: Text(
                    appointment.doctor['name'] ?? 'Unknown Doctor',
                    style: TextStyle(color: notifier.getMainText),
                  ),
                  subtitle: Text(
                    "Patient: ${appointment.patient['name'] ?? 'Unknown Patient'}",
                    style: TextStyle(color: notifier.getMaingey),
                  ),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: appointment.status == 'pending'
                          ? Colors.orange
                          : Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      appointment.status.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
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
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            PermissionWrapper(
              permission: 'create_patients',
              child: _buildQuickActionCard(
                'Add Patient',
                Icons.person_add,
                Colors.blue,
                () => Get.find<AppConst>().changePage('patients'),
              ),
            ),
            PermissionWrapper(
              permission: 'create_appointments',
              child: _buildQuickActionCard(
                'Schedule Appointment',
                Icons.calendar_today,
                Colors.green,
                () => Get.find<AppConst>().changePage('appointments'),
              ),
            ),
            PermissionWrapper(
              permission: 'view_accounting',
              child: _buildQuickActionCard(
                'View Reports',
                Icons.bar_chart,
                Colors.orange,
                () => Get.find<AppConst>().changePage('accounting'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDoctorAppointments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "My Today's Appointments",
          style: TextStyle(
            color: notifier.getMainText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notifier.getContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: notifier.getBorderColor),
          ),
          child: Text(
            "No appointments scheduled for today",
            style: TextStyle(color: notifier.getMaingey),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorQuickActions() {
    return Column(
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
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildQuickActionCard(
              'View Patients',
              Icons.people,
              Colors.blue,
              () => Get.find<AppConst>().changePage('patients'),
            ),
            _buildQuickActionCard(
              'Start Consultation',
              Icons.video_call,
              Colors.green,
              () => Get.find<AppConst>().changePage('live-consultations'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNurseTaskList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Tasks",
          style: TextStyle(
            color: notifier.getMainText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notifier.getContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: notifier.getBorderColor),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.check_circle_outline,
                    color: notifier.getIconColor),
                title: Text("Patient vitals check",
                    style: TextStyle(color: notifier.getMainText)),
                subtitle: Text("Due in 30 minutes",
                    style: TextStyle(color: notifier.getMaingey)),
              ),
              ListTile(
                leading: Icon(Icons.medication, color: notifier.getIconColor),
                title: Text("Medication administration",
                    style: TextStyle(color: notifier.getMainText)),
                subtitle: Text("Due in 1 hour",
                    style: TextStyle(color: notifier.getMaingey)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPatientProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifier.getContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifier.getBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "My Profile",
            style: TextStyle(
              color: notifier.getMainText,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/profile.png'),
              backgroundColor: Colors.white,
            ),
            title: Text(
              permissionService.currentUserId, // Would show actual patient name
              style: TextStyle(color: notifier.getMainText),
            ),
            subtitle: Text(
              "Patient ID: ${permissionService.currentUserId}",
              style: TextStyle(color: notifier.getMaingey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientAppointments() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifier.getContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifier.getBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "My Appointments",
            style: TextStyle(
              color: notifier.getMainText,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "No upcoming appointments",
            style: TextStyle(color: notifier.getMaingey),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientQuickActions() {
    return Column(
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
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildQuickActionCard(
              'Book Appointment',
              Icons.calendar_today,
              Colors.blue,
              () => Get.find<AppConst>().changePage('appointments'),
            ),
            _buildQuickActionCard(
              'View Profile',
              Icons.person,
              Colors.green,
              () => Get.find<AppConst>().changePage('profile'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notifier.getContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: notifier.getBorderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: notifier.getMainText,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefreshButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: 48.0,
          height: 48.0,
          child: IconButton(
            iconSize: 24.0,
            icon: Icon(Icons.refresh, color: notifier.getMainText),
            onPressed: () => dashboardService.fetchDashboardData(),
            tooltip: "Refresh dashboard",
          ),
        ),
      ),
    );
  }
}
