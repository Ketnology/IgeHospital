import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/provider/dashboard_service.dart';
import 'package:ige_hospital/static_data.dart';
import 'package:ige_hospital/widgets/common_title.dart';
import 'package:ige_hospital/widgets/dashboard_data_card.dart';
import 'package:ige_hospital/widgets/permission_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

class DefaultPage extends StatefulWidget {
  const DefaultPage({Key? key}) : super(key: key);

  @override
  State<DefaultPage> createState() => _DefaultPageState();
}

class _DefaultPageState extends State<DefaultPage> {
  late DashboardService dashboardService;
  late ColourNotifier notifier;

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

              // Hospital Overview Section - Only visible to Admins
              PermissionWrapper(
                permission: 'view_admins', // Only admins can see this
                child: Column(
                  children: [
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

                          // Dashboard Cards
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
                                gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 3.0,
                                ),
                                children: [
                                  // Doctors Card
                                  Obx(() => DashboardDataCard(
                                    title: "Doctors",
                                    count:
                                    dashboardService.doctorCount.toString(),
                                    icon: Icons.medical_services,
                                    iconColor: Colors.blue,
                                    onTap: () => Get.find<AppConst>()
                                        .changePage('doctors'),
                                  )),

                                  // Patients Card
                                  Obx(() => DashboardDataCard(
                                    title: "Patients",
                                    count:
                                    dashboardService.patientCount.toString(),
                                    icon: Icons.people,
                                    iconColor: appMainColor,
                                    onTap: () => Get.find<AppConst>()
                                        .changePage('patients'),
                                  )),

                                  // Receptionists Card
                                  Obx(() => DashboardDataCard(
                                    title: "Receptionists",
                                    count: dashboardService.receptionistCount
                                        .toString(),
                                    icon: Icons.support_agent,
                                    iconColor: Colors.orange,
                                    onTap: () =>
                                        Get.find<AppConst>().changePage('nurses'),
                                  )),

                                  // Admins Card
                                  Obx(() => DashboardDataCard(
                                    title: "Administrators",
                                    count: dashboardService.adminCount.toString(),
                                    icon: Icons.admin_panel_settings,
                                    iconColor: Colors.purple,
                                    onTap: () =>
                                        Get.find<AppConst>().changePage('admins'),
                                  )),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Recent Appointments Section - Visible to all staff
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
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
                          final appointment =
                          dashboardService.recentAppointments[index];

                          // Date and time parsing
                          String time = '';
                          String date = '';

                          try {
                            if (appointment.dateTime['formatted'] != null) {
                              DateTime parsedDate = DateTime.parse(
                                  "${appointment.dateTime['date']} ${appointment.dateTime['time']}");
                              time = DateFormat('hh:mm a').format(parsedDate);
                              date = DateFormat('dd/MM/yyyy').format(parsedDate);
                            } else {
                              date = appointment.dateTime['date'] ?? 'N/A';
                              time = appointment.dateTime['time'] ?? 'N/A';
                            }
                          } catch (e) {
                            print("Error parsing date: $e");
                            date = appointment.dateTime['date'] ?? 'N/A';
                            time = appointment.dateTime['time'] ?? 'N/A';
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: notifier.getContainer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: notifier.getBorderColor),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          appointment.doctor['name'] ?? 'Unknown Doctor',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: notifier.getMainText,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: appointment.status == 'pending'
                                              ? Colors.orange
                                              : Colors.green,
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
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Patient: ${appointment.patient['name'] ?? 'Unknown Patient'}",
                                    style: TextStyle(
                                      color: notifier.getMaingey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: notifier.getMaingey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        date,
                                        style: TextStyle(
                                          color: notifier.getMaingey,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: notifier.getMaingey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        time,
                                        style: TextStyle(
                                          color: notifier.getMaingey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
                        onPressed: () =>
                            Get.find<AppConst>().changePage('appointments'),
                        icon: const Icon(Icons.calendar_month),
                        label: const Text("View All Appointments"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appMainColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
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
            tooltip: "Refresh dashboard counts",
          ),
        ),
      ),
    );
  }
}