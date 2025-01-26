import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/static_data.dart';
import 'package:ige_hospital/static_data/static_data.dart';
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
                          "assets/applogo.svg",
                          height: 48,
                          width: 48,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SvgPicture.asset("assets/Buzz..svg",
                            height: 25,
                            width: 32,
                            color: notifier!.getTextColor1),
                        const SizedBox(
                          height: 5,
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
                            // _buildDivider(title: 'GENERAL'),
                            SizedBox(
                              height: isPresent ? 10 : 8,
                            ),
                            _buildSingleTile(
                                header: "Dashboards",
                                iconPath: "assets/home.svg",
                                index: 0,
                                onTap: () {
                                  // controller.changePage(0);
                                  Get.back();
                                }),
                            _buildExpansionTilt(
                                index: 0,
                                children: Row(
                                  children: [
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        SizedBox(
                                          height: isPresent ? 12 : 10,
                                        ),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(2);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 2),
                                                _buildCommonText(
                                                    title: 'General', index: 2),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(3);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 3),
                                                _buildCommonText(
                                                    title: 'Chart', index: 3),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                      ],
                                    ),
                                  ],
                                ),
                                header: 'Widgets',
                                iconPath: 'assets/grid-circle.svg'),
                            _buildDivider(title: 'APPLICATIONS'),
                            _buildExpansionTilt(
                                index: 1,
                                children: Row(
                                  children: [
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        SizedBox(
                                          height: isPresent ? 12 : 10,
                                        ),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(4);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 4),
                                                _buildCommonText(
                                                    title: 'Project List',
                                                    index: 4),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(5);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 5),
                                                _buildCommonText(
                                                    title: 'Create New',
                                                    index: 5),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                      ],
                                    ),
                                  ],
                                ),
                                header: 'Project',
                                iconPath: 'assets/octagon-check.svg'),
                            _buildExpansionTilt(
                                index: 2,
                                children: Row(
                                  children: [
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        SizedBox(
                                          height: isPresent ? 12 : 10,
                                        ),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(6);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 6),
                                                _buildCommonText(
                                                    title: 'Product', index: 6),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(7);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 7),
                                                _buildCommonText(
                                                    title: 'Product Page',
                                                    index: 7),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(8);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 8),
                                                _buildCommonText(
                                                    title: 'Invoice', index: 8),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(9);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 9),
                                                _buildCommonText(
                                                    title: 'Cart', index: 9),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(10);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 10),
                                                _buildCommonText(
                                                    title: 'Checkout',
                                                    index: 10),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(11);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 11),
                                                _buildCommonText(
                                                    title: 'Pricing',
                                                    index: 11),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                      ],
                                    ),
                                  ],
                                ),
                                header: 'E-Commerce',
                                iconPath: 'assets/shopping-basket.svg'),
                            _buildSingleTile(
                                header: "Chat",
                                iconPath: "assets/chats.svg",
                                index: 12,
                                onTap: () {
                                  // controller.changePage(12);
                                  Get.back();
                                }),
                            _buildExpansionTilt(
                                index: 3,
                                children: Row(
                                  children: [
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        SizedBox(
                                          height: isPresent ? 12 : 10,
                                        ),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(13);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 13),
                                                _buildCommonText(
                                                    title: 'User Profile',
                                                    index: 13),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(14);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 14),
                                                _buildCommonText(
                                                    title: 'User Edit',
                                                    index: 14),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(
                                              //   15,
                                              // );
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 15),
                                                _buildCommonText(
                                                    title: 'User Cards',
                                                    index: 15),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                      ],
                                    ),
                                  ],
                                ),
                                header: 'Users',
                                iconPath: 'assets/users.svg'),
                            _buildDivider(title: 'FORMS & TABLE'),
                            _buildExpansionTilt(
                                index: 4,
                                children: Row(
                                  children: [
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            SizedBox(
                                              height: isPresent ? 12 : 10,
                                            ),
                                            InkWell(
                                                onTap: () {
                                                  // controller.changePage(16);
                                                  Get.back();
                                                },
                                                child: Row(
                                                  children: [
                                                    _buildCommonDash(index: 16),
                                                    _buildCommonText(
                                                        title:
                                                            'Validation Form',
                                                        index: 16),
                                                  ],
                                                )),
                                            _buildSizeBoxWithHeight(),
                                            InkWell(
                                              onTap: () {
                                                // controller.changePage(17);
                                                Get.back();
                                              },
                                              child: Row(
                                                children: [
                                                  _buildCommonDash(index: 17),
                                                  _buildCommonText(
                                                      title: 'Checkbox & Radio',
                                                      index: 17),
                                                ],
                                              ),
                                            ),
                                            _buildSizeBoxWithHeight(),
                                            InkWell(
                                                onTap: () {
                                                  // controller.changePage(18);
                                                  Get.back();
                                                },
                                                child: Row(
                                                  children: [
                                                    _buildCommonDash(index: 18),
                                                    _buildCommonText(
                                                        title: 'Date Picker',
                                                        index: 18),
                                                  ],
                                                )),
                                            _buildSizeBoxWithHeight(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                header: 'Forms',
                                iconPath: 'assets/file-list.svg'),
                            _buildExpansionTilt(
                                index: 8,
                                children: Row(
                                  children: [
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        SizedBox(
                                          height: isPresent ? 12 : 10,
                                        ),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(19);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 19),
                                                _buildCommonText(
                                                    title: 'Basic Table',
                                                    index: 19),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(20);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 20),
                                                _buildCommonText(
                                                    title: 'Data Table',
                                                    index: 20),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                      ],
                                    ),
                                  ],
                                ),
                                header: 'Tables',
                                iconPath: 'assets/cabinet-filing.svg'),
                            _buildDivider(title: 'COMPONENTS'),
                            _buildExpansionTilt(
                                index: 5,
                                children: Row(
                                  children: [
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        SizedBox(
                                          height: isPresent ? 12 : 10,
                                        ),
                                        InkWell(
                                            onTap: () {
                                              // Get.offAll(const SingUpPage());
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 27),
                                                _buildCommonText(
                                                    title: 'Login & Signup',
                                                    index: 27),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // Get.offAll(
                                              //     const EmailVerification());
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 28),
                                                _buildCommonText(
                                                    title: 'OTP Verification',
                                                    index: 28),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // Get.offAll(
                                              //     const CompleteVerification());
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 29),
                                                _buildCommonText(
                                                    title: 'Email Verification',
                                                    index: 29),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // Get.offAll(
                                              //     const ForgotPassword());
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 30),
                                                _buildCommonText(
                                                    title: 'Forget Password',
                                                    index: 30),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                      ],
                                    ),
                                  ],
                                ),
                                header: 'Auth pages',
                                iconPath: 'assets/shield-lock.svg'),
                            _buildExpansionTilt(
                                index: 6,
                                children: Row(
                                  children: [
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        SizedBox(
                                          height: isPresent ? 12 : 10,
                                        ),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(21);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 21),
                                                _buildCommonText(
                                                    title: 'Avatars',
                                                    index: 21),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(22);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 22),
                                                _buildCommonText(
                                                    title: 'Modal', index: 22),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(23);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 23),
                                                _buildCommonText(
                                                    title: 'Alert', index: 23),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(24);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 24),
                                                _buildCommonText(
                                                    title: 'Badges', index: 24),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(25);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 25),
                                                _buildCommonText(
                                                    title: 'Breadcrumb',
                                                    index: 25),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(26);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 26),
                                                _buildCommonText(
                                                    title: 'Cards', index: 26),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(27);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 27),
                                                _buildCommonText(
                                                    title: 'Carousel',
                                                    index: 27),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(28);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 28),
                                                _buildCommonText(
                                                    title: 'Dropdowns',
                                                    index: 28),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(29);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 29),
                                                _buildCommonText(
                                                    title: 'Pagination',
                                                    index: 29),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(30);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 30),
                                                _buildCommonText(
                                                    title: 'Progress',
                                                    index: 30),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(31);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 31),
                                                _buildCommonText(
                                                    title: 'List group',
                                                    index: 31),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(32);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 32),
                                                _buildCommonText(
                                                    title: 'Spinners',
                                                    index: 32),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(33);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 33),
                                                _buildCommonText(
                                                    title: 'Tooltip',
                                                    index: 33),
                                              ],
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                                header: 'Ui Kits',
                                iconPath: 'assets/pen-tool.svg'),
                            _buildExpansionTilt(
                                index: 7,
                                children: Row(
                                  children: [
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        SizedBox(
                                          height: isPresent ? 12 : 10,
                                        ),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(34);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 34),
                                                _buildCommonText(
                                                    title: 'Default Style',
                                                    index: 34),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(35);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 35),
                                                _buildCommonText(
                                                    title: 'Flat Style',
                                                    index: 35),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(36);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 36),
                                                _buildCommonText(
                                                    title: 'Edge Style',
                                                    index: 36),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(37);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                _buildCommonDash(index: 37),
                                                _buildCommonText(
                                                    title: 'Raised Style',
                                                    index: 37),
                                              ],
                                            )),
                                        _buildSizeBoxWithHeight(),
                                      ],
                                    ),
                                  ],
                                ),
                                header: 'Buttons',
                                iconPath: 'assets/send.svg'),
                            _buildDivider(title: 'MISCELLANEOUS'),
                            _buildSingleTile(
                                header: 'FAQ',
                                iconPath: 'assets/chat-exclamation.svg',
                                index: 38,
                                onTap: () {
                                  // controller.changePage(38);
                                  Get.back();
                                }),
                            _buildExpansionTilt(
                                index: 8,
                                children: Row(
                                  children: [
                                    Expanded(
                                      child: Column(children: [
                                        InkWell(
                                            onTap: () {
                                              // controller.changePage(37);
                                              Get.back();
                                            },
                                            child: Row(
                                              children: [
                                                const SizedBox(
                                                  width: 16,
                                                ),
                                                _buildCommonDash(index: 0),
                                                _buildCommonText(
                                                    title: 'Level 1.1',
                                                    index: 0),
                                              ],
                                            )),
                                        ListTileTheme(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10),
                                          child: ExpansionTile(
                                            title: Transform.translate(
                                                offset: const Offset(-16, 0),
                                                child: Text(
                                                  'Level 1.2',
                                                  style: TextStyle(
                                                      color:
                                                          notifier!.getMainText,
                                                      fontSize: 13),
                                                )),
                                            leading: Transform.translate(
                                                offset: const Offset(5, 8),
                                                child:
                                                    _buildCommonDash(index: 0)),
                                            children: [
                                              InkWell(
                                                  onTap: () {
                                                    // controller.changePage(37);
                                                    Get.back();
                                                  },
                                                  child: Row(
                                                    children: [
                                                      const SizedBox(
                                                        width: 40,
                                                      ),
                                                      _buildCommonDash(
                                                          index: 0),
                                                      _buildCommonText(
                                                          title: 'Level 2.1',
                                                          index: 0),
                                                    ],
                                                  )),
                                              ListTileTheme(
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        right: 10),
                                                child: ExpansionTile(
                                                  title: Transform.translate(
                                                      offset:
                                                          const Offset(18, 0),
                                                      child: Text(
                                                        'Level 2.2',
                                                        style: TextStyle(
                                                            color: notifier!
                                                                .getMainText,
                                                            fontSize: 13),
                                                      )),
                                                  leading: Transform.translate(
                                                      offset:
                                                          const Offset(40, 8),
                                                      child: _buildCommonDash(
                                                          index: 0)),
                                                  children: [
                                                    InkWell(
                                                        onTap: () {
                                                          // controller
                                                          //     .changePage(37);
                                                          Get.back();
                                                        },
                                                        child: Row(
                                                          children: [
                                                            const SizedBox(
                                                              width: 60,
                                                            ),
                                                            _buildCommonDash(
                                                                index: 0),
                                                            _buildCommonText(
                                                                title:
                                                                    'Level 3.1',
                                                                index: 0),
                                                          ],
                                                        )),
                                                    ListTileTheme(
                                                      contentPadding:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                      child: ExpansionTile(
                                                        title:
                                                            Transform.translate(
                                                                offset:
                                                                    const Offset(
                                                                        36, 0),
                                                                child: Text(
                                                                  'Level 3.2',
                                                                  style: TextStyle(
                                                                      color: notifier!
                                                                          .getMainText,
                                                                      fontSize:
                                                                          13),
                                                                )),
                                                        leading: Transform.translate(
                                                            offset:
                                                                const Offset(
                                                                    60, 8),
                                                            child:
                                                                _buildCommonDash(
                                                                    index: 0)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ],
                                ),
                                header: 'Menu Level',
                                iconPath: 'assets/more-horizontal-circle.svg'),
                            _buildSingleTile(
                                header: 'Calendar',
                                iconPath: 'assets/calendar.svg',
                                index: 44,
                                onTap: () {
                                  // controller.changePage(44);
                                  Get.back();
                                }),
                            _buildSingleTile(
                                header: 'Maps',
                                iconPath: 'assets/map.svg',
                                index: 45,
                                onTap: () {
                                  // controller.changePage(45);
                                  Get.back();
                                }),
                            _buildSingleTile(
                                header: 'File Manager',
                                iconPath: 'assets/file-text.svg',
                                index: 46,
                                onTap: () {
                                  // controller.changePage(46);
                                  Get.back();
                                }),
                            _buildSingleTile(
                                header: 'Tabs & Pills',
                                iconPath: 'assets/sliders-horizontal-alt.svg',
                                index: 47,
                                onTap: () {
                                  // controller.changePage(47);
                                  Get.back();
                                }),
                            _buildSingleTile(
                                header: 'Notifications',
                                iconPath: 'assets/bell-notification.svg',
                                index: 48,
                                onTap: () {
                                  // controller.changePage(48);
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

  Widget _buildSizeBoxWithHeight() {
    return SizedBox(
      height: isPresent ? 25 : 20,
    );
  }

  Widget _buildCommonText({required String title, required int index}) {
    return Obx(
      () => Text(
        title,
        style: mediumGreyTextStyle.copyWith(
            fontSize: 13,
            color: controller.pageSelector.value == index
                ? appMainColor
                : notifier!.getMainText),
      ),
    );
  }

  Widget _buildCommonDash({required int index}) {
    return Obx(
      () => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset("assets/minus.svg",
              color: controller.pageSelector.value == index
                  ? appMainColor
                  : notifier!.getMainText,
              width: 6),
          const SizedBox(
            width: 25,
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTilt(
      {required Widget children,
      required String header,
      required String iconPath,
      required int index}) {
    return ListTileTheme(
      horizontalTitleGap: 12.0,
      dense: true,
      child: ExpansionTile(
        title: Text(
          header,
          style: mediumBlackTextStyle.copyWith(
              fontSize: 14, color: notifier!.getMainText),
        ),
        leading: SvgPicture.asset(iconPath,
            height: 18, width: 18, color: notifier!.getMainText),
        tilePadding:
            EdgeInsets.symmetric(vertical: isPresent ? 5 : 2, horizontal: 8),
        iconColor: appMainColor,
        collapsedIconColor: Colors.grey,
        children: <Widget>[children],
      ),
    );
  }

  Widget _buildSingleTile(
      {required String header,
      required String iconPath,
      required int index,
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
                  color: controller.pageSelector.value == index
                      ? appMainColor
                      : notifier!.getMainText),
            ),
            leading: SvgPicture.asset(iconPath,
                height: 18,
                width: 18,
                color: controller.pageSelector.value == index
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
