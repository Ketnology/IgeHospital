import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/provider/permission_service.dart';
import 'package:ige_hospital/static_data.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/widgets/permission_wrapper.dart';
import 'package:provider/provider.dart';

class DrawerCode extends StatefulWidget {
  const DrawerCode({super.key});

  @override
  State<DrawerCode> createState() => _DrawerCodeState();
}

class _DrawerCodeState extends State<DrawerCode> {
  AppConst obj = AppConst();
  final AppConst controller = Get.put(AppConst());
  final PermissionService permissionService = Get.find<PermissionService>();

  final screenWidth = Get.width;
  bool isPresent = false;

  static const breakpoint = 600.0;

  @override
  Widget build(BuildContext context) {
    if (screenWidth >= breakpoint) {
      setState(() {
        isPresent = true;
      });
    }

    return GetBuilder<AppConst>(builder: (controller) {
      return SafeArea(
        child: Consumer<ColourNotifier>(
          builder: (context, value, child) => Drawer(
            backgroundColor: notifier!.getPrimaryColor,
            shape: RoundedRectangleBorder(
                side: BorderSide(color: notifier!.getBorderColor)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: isPresent ? 30 : 15,
                      top: isPresent ? 24 : 20,
                      bottom: isPresent ? 10 : 12),
                  child: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/app-logo.svg",
                          height: 48,
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: isPresent ? 10 : 8),

                            // Overview - Available to all logged-in users
                            PermissionWrapper(
                              permission: 'view_dashboard',
                              child: _buildSingleTile(
                                  header: "Overview",
                                  iconPath: "assets/chart-bar-vertical.svg",
                                  index: '',
                                  onTap: () {
                                    controller.changePage('');
                                    Get.back();
                                  }
                              ),
                            ),

                            // Hospital Operations Section
                            if (permissionService.hasAnyPermission([
                              'view_appointments',
                              'view_own_appointments',
                              'view_patients',
                              'view_doctors',
                              'view_nurses'
                            ]))
                              _buildDivider(title: 'Hospital Operations'),

                            PermissionWrapper(
                              anyOf: ['view_appointments', 'view_own_appointments'],
                              child: _buildSingleTile(
                                  header: "Appointments",
                                  iconPath: "assets/calendar.svg",
                                  index: 'appointments',
                                  onTap: () {
                                    controller.changePage('appointments');
                                    Get.back();
                                  }
                              ),
                            ),

                            PermissionWrapper(
                              permission: 'view_patients',
                              child: _buildSingleTile(
                                  header: "Patient Records",
                                  iconPath: "assets/file-list.svg",
                                  index: 'patients',
                                  onTap: () {
                                    controller.changePage('patients');
                                    Get.back();
                                  }
                              ),
                            ),

                            PermissionWrapper(
                              permission: 'view_doctors',
                              child: _buildSingleTile(
                                  header: "Doctors",
                                  iconPath: "assets/users33.svg",
                                  index: 'doctors',
                                  onTap: () {
                                    controller.changePage('doctors');
                                    Get.back();
                                  }
                              ),
                            ),

                            PermissionWrapper(
                              permission: 'view_nurses',
                              child: _buildSingleTile(
                                  header: "Nurses",
                                  iconPath: "assets/chat-info.svg",
                                  index: 'nurses',
                                  onTap: () {
                                    controller.changePage('nurses');
                                    Get.back();
                                  }
                              ),
                            ),

                            // Medical Services Section
                            PermissionWrapper(
                              permission: 'view_consultations',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDivider(title: 'Medical Services'),
                                  _buildSingleTile(
                                      header: "Live Consultations",
                                      iconPath: "assets/video.svg",
                                      index: 'live-consultations',
                                      onTap: () {
                                        controller.changePage('live-consultations');
                                        Get.back();
                                      }
                                  ),
                                ],
                              ),
                            ),

                            // Finance & Accounting Section
                            PermissionWrapper(
                              permission: 'view_accounting',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDivider(title: 'Finance & Accounting'),
                                  _buildSingleTile(
                                      header: "Accounting",
                                      iconPath: "assets/hand-holding-dollar.svg",
                                      index: 'accounting',
                                      onTap: () {
                                        controller.changePage('accounting');
                                        Get.back();
                                      }
                                  ),
                                ],
                              ),
                            ),

                            // System Management (Admin only)
                            PermissionWrapper(
                              permission: 'view_admins',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDivider(title: 'System Management'),
                                  _buildSingleTile(
                                      header: "Administrators",
                                      iconPath: "assets/users33.svg",
                                      index: 'admins',
                                      onTap: () {
                                        controller.changePage('admins');
                                        Get.back();
                                      }
                                  ),
                                ],
                              ),
                            ),

                            // Profile Section - Available to all users
                            _buildDivider(title: 'Profile & Settings'),

                            PermissionWrapper(
                              permission: 'view_own_profile',
                              child: _buildSingleTile(
                                  header: 'My Profile',
                                  iconPath: 'assets/user.svg',
                                  index: 'profile',
                                  onTap: () {
                                    controller.changePage('profile');
                                    Get.back();
                                  }
                              ),
                            ),

                            // Updates & Support Section
                            _buildDivider(title: 'Support & Communication'),

                            _buildSingleTile(
                                header: 'Notifications',
                                iconPath: 'assets/bell-notification.svg',
                                index: 'notifications',
                                onTap: () {
                                  Get.back();
                                }
                            ),

                            _buildSingleTile(
                                header: 'Staff Communication',
                                iconPath: 'assets/chats.svg',
                                index: 'chat',
                                onTap: () {
                                  Get.back();
                                }
                            ),

                            _buildSingleTile(
                                header: 'Feedback',
                                iconPath: 'assets/chat-exclamation.svg',
                                index: 'support',
                                onTap: () {
                                  Get.back();
                                }
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSingleTile({
    required String header,
    required String iconPath,
    required String index,
    required void Function() onTap
  }) {
    return Obx(() => ListTileTheme(
      horizontalTitleGap: 12.0,
      dense: true,
      child: ListTile(
        hoverColor: Colors.transparent,
        onTap: onTap,
        title: Text(
          header,
          style: mediumBlackTextStyle.copyWith(
              fontSize: 14,
              color: controller.selectedPageKey.value == index
                  ? appMainColor
                  : notifier!.getMainText),
        ),
        leading: SvgPicture.asset(iconPath,
            height: 18,
            width: 18,
            color: controller.selectedPageKey.value == index
                ? appMainColor
                : notifier!.getMainText),
        trailing: const SizedBox(),
        contentPadding: EdgeInsets.symmetric(
            vertical: isPresent ? 5 : 2, horizontal: 8),
      ),
    ));
  }

  Widget _buildDivider({required String title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            height: isPresent ? 15 : 10,
            width: isPresent ? 230 : 260,
            child: Center(
                child: Divider(color: notifier!.getBorderColor, height: 1))),
        SizedBox(height: isPresent ? 15 : 10),
        Text(
          title,
          style: mainTextStyle.copyWith(
              fontSize: 14, color: notifier!.getMainText),
        ),
        SizedBox(height: isPresent ? 10 : 8),
      ],
    );
  }
}