import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/provider/dashboard_service.dart';
import 'package:ige_hospital/static_data.dart';
import 'package:ige_hospital/widgets/common_title.dart';
import 'package:ige_hospital/widgets/dashboard_data_card.dart';
import 'package:provider/provider.dart';

class DefaultPage extends StatelessWidget {
  const DefaultPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ColourNotifier>(
      builder: (context, themeNotifier, child) {
        return Scaffold(
          backgroundColor: themeNotifier.getBgColor,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CommonTitle(title: 'Dashboard', path: 'Dashboard'),
                Expanded(
                  child: _buildDashboardContent(themeNotifier),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashboardContent(ColourNotifier themeNotifier) {
    final dashboardService = Get.find<DashboardService>();
    final controller = Get.find<AppConst>();

    return Obx(() {
      if (dashboardService.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            color: themeNotifier.getIconColor,
          ),
        );
      }

      if (dashboardService.hasError.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                dashboardService.errorMessage.value,
                style: TextStyle(color: themeNotifier.getMainText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => dashboardService.fetchDashboardData(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeNotifier.getIconColor,
                ),
                child: const Text(
                  "Retry",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with refresh button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Hospital Overview",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeNotifier.getMainText,
                  ),
                ),
                _buildRefreshButton(themeNotifier, dashboardService),
              ],
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
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 3.0, // Higher ratio for shorter height
                  ),
                  children: [
                    // Doctors Card
                    DashboardDataCard(
                      title: "Doctors",
                      count: dashboardService.doctorCount.toString(),
                      icon: Icons.medical_services,
                      iconColor: Colors.blue,
                      onTap: () => Get.find<AppConst>().changePage('doctors'),
                    ),

                    // Patients Card
                    DashboardDataCard(
                      title: "Patients",
                      count: dashboardService.patientCount.toString(),
                      icon: Icons.people,
                      iconColor: appMainColor,
                      onTap: () => Get.find<AppConst>().changePage('patients'),
                    ),

                    // Receptionists Card
                    DashboardDataCard(
                      title: "Receptionists",
                      count: dashboardService.receptionistCount.toString(),
                      icon: Icons.support_agent,
                      iconColor: Colors.orange,
                      onTap: () => Get.find<AppConst>().changePage('nurses'),
                    ),

                    // Admins Card
                    DashboardDataCard(
                      title: "Administrators",
                      count: dashboardService.adminCount.toString(),
                      icon: Icons.admin_panel_settings,
                      iconColor: Colors.purple,
                      onTap: () => Get.find<AppConst>().changePage('admins'),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // Recent Appointments
            _recentAppointmentsCard(
                themeNotifier, dashboardService, controller),
          ],
        ),
      );
    });
  }

  // Refresh button for dashboard data
  Widget _buildRefreshButton(
      ColourNotifier themeNotifier, DashboardService dashboardService) {
    return IconButton(
      onPressed: () {
        // Only refresh the dashboard data, not the entire page
        dashboardService.refreshDashboardData();
      },
      icon: Icon(
        Icons.refresh,
        color: themeNotifier.getIconColor,
      ),
      tooltip: "Refresh Dashboard Data",
    );
  }

  Widget _recentAppointmentsCard(ColourNotifier themeNotifier,
      DashboardService dashboardService, AppConst controller) {
    return Padding(
      padding: const EdgeInsets.all(padding),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          color: themeNotifier.getContainer,
          boxShadow: boxShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(padding),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Appointments",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeNotifier.getMainText,
                    ),
                  ),
                ],
              ),
              Obx(() {
                if (dashboardService.isLoading.value &&
                    dashboardService.recentAppointments.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (dashboardService.recentAppointments.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 40,
                            color: themeNotifier.getIconColor,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "No recent appointments found",
                            style: mediumGreyTextStyle,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: dashboardService.recentAppointments.length > 5
                      ? 5
                      : dashboardService.recentAppointments.length,
                  itemBuilder: (context, index) {
                    final appointment =
                        dashboardService.recentAppointments[index];

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

                    return Column(
                      children: [
                        ListTile(
                          leading: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: appointment.doctor['image'] != null
                                    ? (appointment.doctor['image']
                                            .toString()
                                            .contains('http')
                                        ? Image.network(
                                            appointment.doctor['image'],
                                            width: 40,
                                            height: 40,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(Icons.person,
                                                        size: 40),
                                          )
                                        : SvgPicture.asset(
                                            "assets/icons8-figma.svg",
                                            width: 40,
                                            height: 40,
                                          ))
                                    : const Icon(Icons.person, size: 40),
                              ),
                              Container(
                                height: 12,
                                width: 12,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(appointment.status),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: themeNotifier.getContainer,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          title: Text(
                            appointment.doctor['full_name'] ?? 'Unknown Doctor',
                            style: mediumBlackTextStyle.copyWith(
                              color: themeNotifier.getMainText,
                            ),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                time,
                                style: mediumBlackTextStyle.copyWith(
                                  color: themeNotifier.getMainText,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                date,
                                style: mediumGreyTextStyle,
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              "Patient: ${appointment.patient['full_name'] ?? 'Unknown Patient'}",
                              style: mediumGreyTextStyle,
                            ),
                          ),
                          onTap: () => controller.changePage('appointments'),
                        ),
                        if (index <
                            dashboardService.recentAppointments.length - 1)
                          Divider(color: themeNotifier.getBorderColor),
                      ],
                    );
                  },
                );
              }),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  controller.changePage('appointments');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeNotifier.getPrimaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: themeNotifier.getBorderColor),
                  ),
                ),
                child: Text(
                  "View All Appointments",
                  style: TextStyle(
                    color: themeNotifier.getMainText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
