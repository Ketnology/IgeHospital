
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/provider/dashboard_service.dart';
import 'package:ige_hospital/static_data.dart';
import 'package:ige_hospital/widgets/common_title.dart';
import 'package:ige_hospital/widgets/dashboard_data_card.dart';
import 'package:provider/provider.dart';

class DefaultPage extends StatefulWidget {
  const DefaultPage({Key? key}) : super(key: key);

  @override
  State<DefaultPage> createState() => _DefaultPageState();
}

class _DefaultPageState extends State<DefaultPage> {
  late DashboardService dashboardService;

  @override
  void initState() {
    super.initState();
    dashboardService = Get.find<DashboardService>();

    // Refresh dashboard data when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dashboardService.fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Scaffold(
      backgroundColor: notifier.getBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CommonTitle(title: 'Dashboard', path: "Overview"),

              // Dashboard Summary Cards
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hospital Overview",
                      style: TextStyle(
                        color: notifier.getMainText,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dashboard Cards - Updated as requested
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Responsive layout
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
                            childAspectRatio: 3.0, // Higher ratio for shorter height
                          ),
                          children: [
                            // Doctors Card
                            Obx(() => DashboardDataCard(
                              title: "Doctors",
                              count: dashboardService.doctorCount.toString(),
                              icon: Icons.medical_services,
                              iconColor: Colors.blue,
                              onTap: () => Get.find<AppConst>().changePage('doctors'),
                            )),

                            // Patients Card
                            Obx(() => DashboardDataCard(
                              title: "Patients",
                              count: dashboardService.patientCount.toString(),
                              icon: Icons.people,
                              iconColor: appMainColor,
                              onTap: () => Get.find<AppConst>().changePage('patients'),
                            )),

                            // Receptionists Card
                            Obx(() => DashboardDataCard(
                              title: "Receptionists",
                              count: dashboardService.receptionistCount.toString(),
                              icon: Icons.support_agent,
                              iconColor: Colors.orange,
                              onTap: () => Get.find<AppConst>().changePage('nurses'),
                            )),

                            // Admins Card
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

                    // Recent Appointments Section
                    Text(
                      "Recent Appointments",
                      style: TextStyle(
                        color: notifier.getMainText,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Recent Appointments List
                    Obx(() {
                      if (dashboardService.isLoading.value) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: notifier.getIconColor,
                          ),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: notifier.getBorderColor),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.withOpacity(0.1),
                                child: const Icon(Icons.calendar_today, color: Colors.blue),
                              ),
                              title: Text(
                                appointment.doctor['name'] ?? 'Unknown Doctor',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: notifier.getMainText,
                                ),
                              ),
                              subtitle: Text(
                                "Patient: ${appointment.patient['name'] ?? 'Unknown Patient'}",
                                style: TextStyle(
                                  color: notifier.getMaingey,
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: appointment.status == 'pending' ? Colors.orange : Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  appointment.status.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),

                    const SizedBox(height: 24),

                    // Call to action button to see all appointments
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => Get.find<AppConst>().changePage('appointments'),
                        icon: const Icon(Icons.calendar_month),
                        label: const Text("View All Appointments"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appMainColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
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
}