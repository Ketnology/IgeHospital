import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/static_data.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:provider/provider.dart';

class DrawerCode extends StatefulWidget {
  const DrawerCode({super.key});

  @override
  State<DrawerCode> createState() => _DrawerCodeState();
}

class _DrawerCodeState extends State<DrawerCode> {
  AppConst obj = AppConst();
  final AppConst controller = Get.put(AppConst());

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
                      // controller.changePage(0);
                      Get.back();
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/app-logo.svg",
                          height: 48,
                          // width: 48,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
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
                            SizedBox(
                              height: isPresent ? 10 : 8,
                            ),
                            _buildSingleTile(
                                header: "Overview",
                                iconPath: "assets/chart-bar-vertical.svg",
                                index: '',
                                onTap: () {
                                  controller.changePage('');
                                  Get.back();
                                }),
                            _buildDivider(title: 'Hospital Operations'),
                            _buildSingleTile(
                                header: "Appointments",
                                iconPath: "assets/calendar.svg",
                                index: 'appointments',
                                onTap: () {
                                  controller.changePage('appointments');
                                  Get.back();
                                }),
                            _buildSingleTile(
                                header: "Patient Records",
                                iconPath: "assets/file-list.svg",
                                index: 'patients',
                                onTap: () {
                                  controller.changePage('patients');
                                  Get.back();
                                }),
                            _buildSingleTile(
                                header: "Doctors",
                                iconPath: "assets/users33.svg",
                                index: 'doctors',
                                onTap: () {
                                  controller.changePage('doctors');
                                  Get.back();
                                }),
                            _buildSingleTile(
                                header: "Nurses",
                                iconPath: "assets/chat-info.svg",
                                index: 'nurses',
                                onTap: () {
                                  controller.changePage('nurses');
                                  Get.back();
                                }),
                            _buildDivider(title: 'Finance & Accounting'),
                            _buildSingleTile(
                                header: "Accounting",
                                iconPath: "assets/hand-holding-dollar.svg",
                                index: 'accounting',
                                onTap: () {
                                  controller.changePage('accounting');
                                  Get.back();
                                }),
                            // _buildSingleTile(
                            //     header: "Hospital Stay",
                            //     iconPath: "assets/home.svg",
                            //     index: 'in-patient',
                            //     onTap: () {
                            //       // controller.changePage('in-patient');
                            //       Get.back();
                            //     }),
                            // _buildDivider(title: 'Clinical Documentation'),
                            // _buildSingleTile(
                            //     header: "Prescriptions",
                            //     iconPath: "assets/clipboard-check.svg",
                            //     index: 'prescriptions',
                            //     onTap: () {
                            //       // controller.changePage(12);
                            //       Get.back();
                            //     }),
                            // _buildSingleTile(
                            //     header: "Reports",
                            //     iconPath: "assets/file-text.svg",
                            //     index: 'reports',
                            //     onTap: () {
                            //       // controller.changePage(12);
                            //       Get.back();
                            //     }),
                            // _buildDivider(title: 'Treatment'),
                            // _buildSingleTile(
                            //     header: "Procedures",
                            //     iconPath: "assets/settings.svg",
                            //     index: 'procedures',
                            //     onTap: () {
                            //       // controller.changePage(12);
                            //       Get.back();
                            //     }),
                            // _buildSingleTile(
                            //     header: "Surgery",
                            //     iconPath: "assets/grid-web-5.svg",
                            //     index: 'surgery',
                            //     onTap: () {
                            //       // controller.changePage(12);
                            //       Get.back();
                            //     }),
                            _buildDivider(title: 'Updates & Support'),
                            _buildSingleTile(
                                header: 'Notifications',
                                iconPath: 'assets/bell-notification.svg',
                                index: 'notifications',
                                onTap: () {
                                  // controller.changePage(38);
                                  Get.back();
                                }),
                            // _buildExpansionTilt(
                            //     index: 8,
                            //     children: Row(
                            //       children: [
                            //         Expanded(
                            //           child: Column(children: [
                            //             InkWell(
                            //                 onTap: () {
                            //                   // controller.changePage(37);
                            //                   Get.back();
                            //                 },
                            //                 child: Row(
                            //                   children: [
                            //                     const SizedBox(
                            //                       width: 16,
                            //                     ),
                            //                     _buildCommonDash(index: 0),
                            //                     _buildCommonText(
                            //                         title: 'Level 1.1',
                            //                         index: 0),
                            //                   ],
                            //                 )),
                            //             ListTileTheme(
                            //               contentPadding:
                            //                   const EdgeInsets.symmetric(
                            //                       horizontal: 10),
                            //               child: ExpansionTile(
                            //                 title: Transform.translate(
                            //                     offset: const Offset(-16, 0),
                            //                     child: Text(
                            //                       'Level 1.2',
                            //                       style: TextStyle(
                            //                           color:
                            //                               notifier!.getMainText,
                            //                           fontSize: 13),
                            //                     )),
                            //                 leading: Transform.translate(
                            //                     offset: const Offset(5, 8),
                            //                     child:
                            //                         _buildCommonDash(index: 0)),
                            //                 children: [
                            //                   InkWell(
                            //                       onTap: () {
                            //                         // controller.changePage(37);
                            //                         Get.back();
                            //                       },
                            //                       child: Row(
                            //                         children: [
                            //                           const SizedBox(
                            //                             width: 40,
                            //                           ),
                            //                           _buildCommonDash(
                            //                               index: 0),
                            //                           _buildCommonText(
                            //                               title: 'Level 2.1',
                            //                               index: 0),
                            //                         ],
                            //                       )),
                            //                   ListTileTheme(
                            //                     contentPadding:
                            //                         const EdgeInsets.only(
                            //                             right: 10),
                            //                     child: ExpansionTile(
                            //                       title: Transform.translate(
                            //                           offset:
                            //                               const Offset(18, 0),
                            //                           child: Text(
                            //                             'Level 2.2',
                            //                             style: TextStyle(
                            //                                 color: notifier!
                            //                                     .getMainText,
                            //                                 fontSize: 13),
                            //                           )),
                            //                       leading: Transform.translate(
                            //                           offset:
                            //                               const Offset(40, 8),
                            //                           child: _buildCommonDash(
                            //                               index: 0)),
                            //                       children: [
                            //                         InkWell(
                            //                             onTap: () {
                            //                               // controller
                            //                               //     .changePage(37);
                            //                               Get.back();
                            //                             },
                            //                             child: Row(
                            //                               children: [
                            //                                 const SizedBox(
                            //                                   width: 60,
                            //                                 ),
                            //                                 _buildCommonDash(
                            //                                     index: 0),
                            //                                 _buildCommonText(
                            //                                     title:
                            //                                         'Level 3.1',
                            //                                     index: 0),
                            //                               ],
                            //                             )),
                            //                         ListTileTheme(
                            //                           contentPadding:
                            //                               const EdgeInsets.only(
                            //                                   right: 10),
                            //                           child: ExpansionTile(
                            //                             title:
                            //                                 Transform.translate(
                            //                                     offset:
                            //                                         const Offset(
                            //                                             36, 0),
                            //                                     child: Text(
                            //                                       'Level 3.2',
                            //                                       style: TextStyle(
                            //                                           color: notifier!
                            //                                               .getMainText,
                            //                                           fontSize:
                            //                                               13),
                            //                                     )),
                            //                             leading: Transform.translate(
                            //                                 offset:
                            //                                     const Offset(
                            //                                         60, 8),
                            //                                 child:
                            //                                     _buildCommonDash(
                            //                                         index: 0)),
                            //                           ),
                            //                         ),
                            //                       ],
                            //                     ),
                            //                   ),
                            //                 ],
                            //               ),
                            //             ),
                            //           ]),
                            //         ),
                            //       ],
                            //     ),
                            //     header: 'Menu Level',
                            //     iconPath: 'assets/more-horizontal-circle.svg'),
                            _buildSingleTile(
                                header: 'Staff Communication',
                                iconPath: 'assets/chats.svg',
                                index: 'chat',
                                onTap: () {
                                  // controller.changePage(44);
                                  Get.back();
                                }),
                            _buildSingleTile(
                                header: 'Feedback',
                                iconPath: 'assets/chat-exclamation.svg',
                                index: 'support',
                                onTap: () {
                                  // controller.changePage(45);
                                  Get.back();
                                }),
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

  Widget _buildSingleTile(
      {required String header,
      required String iconPath,
      required String index,
      required void Function() onTap}) {
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
        SizedBox(
          height: isPresent ? 15 : 10,
        ),
        Text(
          title,
          style: mainTextStyle.copyWith(
              fontSize: 14, color: notifier!.getMainText),
        ),
        SizedBox(
          height: isPresent ? 10 : 8,
        ),
      ],
    );
  }
}
