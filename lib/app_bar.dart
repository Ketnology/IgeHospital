import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/static_data.dart';
import 'package:ige_hospital/static_data/static_data.dart';
import 'package:provider/provider.dart';

class AppBarCode extends StatefulWidget implements PreferredSizeWidget {
  const AppBarCode({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<AppBarCode> createState() => _AppBarCodeState();
}

class _AppBarCodeState extends State<AppBarCode> {
  bool search = false;
  bool darkMood = false;
  final AppConst controller = Get.put(AppConst());

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);
    final screenWidth = Get.width;
    bool isPresent = false;

    const breakpoint = 600.0;

    if (screenWidth >= breakpoint) {
      setState(() {
        isPresent = true;
      });
    }

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return GetBuilder<AppConst>(builder: (controller) {
        return AppBar(
          shape: RoundedRectangleBorder(
              side: BorderSide(color: notifier.getBorderColor)),
          backgroundColor: notifier.getPrimaryColor,
          elevation: 1,
          leading: isPresent
              ? InkWell(
                  onTap: () {
                    controller.updateShowDrawer();
                  },
                  child: SizedBox(
                    height: 27,
                    width: 27,
                    child: Center(
                      child: SvgPicture.asset(
                        "assets/menu-left.svg",
                        height: 25,
                        width: 25,
                        color: notifier.getIconColor,
                      ),
                    ),
                  ),
                )
              : InkWell(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: SizedBox(
                    height: 27,
                    width: 27,
                    child: Center(
                      child: SvgPicture.asset(
                        "assets/menu-left.svg",
                        height: 25,
                        width: 25,
                        color: notifier.getIconColor,
                      ),
                    ),
                  ),
                ),
          title: search
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 42,
                      width: Get.width * 0.3,
                      child: TextField(
                        style: TextStyle(color: notifier.getMainText),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(top: 5),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: notifier.getBorderColor, width: 2)),
                          disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: notifier.getBorderColor, width: 2)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: notifier.getBorderColor, width: 2)),
                          hintStyle: TextStyle(color: notifier.getMainText),
                          hintText: "Search..",
                          prefixIcon: SizedBox(
                            height: 16,
                            width: 16,
                            child: Center(
                                child: SvgPicture.asset(
                              "assets/search.svg",
                              height: 16,
                              width: 16,
                              color: notifier.getIconColor,
                            )),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                constraints.maxWidth < 600
                    ? PopupMenuButton(
                        constraints: BoxConstraints(
                          minWidth: Get.width,
                          maxWidth: MediaQuery.of(context).size.width,
                        ),
                        color: notifier.getContainer,
                        offset: const Offset(-5, 55),
                        icon: SvgPicture.asset(
                          "assets/search.svg",
                          width: 20,
                          height: 20,
                          color: notifier.getIconColor,
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            enabled: false,
                            child: SizedBox(
                              height: 42,
                              child: TextField(
                                style: TextStyle(color: notifier.getMainText),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(top: 5),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: notifier.getBorderColor,
                                          width: 2)),
                                  disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: notifier.getBorderColor,
                                          width: 2)),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: notifier.getBorderColor,
                                          width: 2)),
                                  hintStyle:
                                      TextStyle(color: notifier.getMainText),
                                  hintText: "Search..",
                                  prefixIcon: SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: Center(
                                      child: SvgPicture.asset(
                                        "assets/search.svg",
                                        height: 16,
                                        width: 16,
                                        color: notifier.getIconColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    : InkWell(
                        onTap: () {
                          setState(() {
                            search = !search;
                          });
                        },
                        child: SvgPicture.asset(
                          search ? "assets/times.svg" : "assets/search.svg",
                          width: search ? 16 : 20,
                          height: search ? 16 : 20,
                          color: notifier.getIconColor,
                        ),
                      ),
                constraints.maxWidth < 600
                    ? const SizedBox()
                    : const SizedBox(
                        width: 10,
                      ),
                const SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      darkMood = !darkMood;
                    });

                    if (notifier.isDark == false) {
                      notifier.isAvaliable(true);
                    } else {
                      notifier.isAvaliable(false);
                    }
                  },
                  child: SvgPicture.asset(
                    darkMood ? "assets/sun.svg" : "assets/moon.svg",
                    width: 20,
                    height: 20,
                    color: notifier.getIconColor,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                PopupMenuButton(
                  color: notifier.getContainer,
                  shadowColor: Colors.grey.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  tooltip: "Cart",
                  offset: const Offset(0, 50),
                  icon: SvgPicture.asset(
                    "assets/shopping-basket.svg",
                    width: 20,
                    height: 20,
                    color: notifier.getIconColor,
                  ),
                  itemBuilder: (ctx) => [
                    _buildPopupCartMenuItem(),
                  ],
                ),
                PopupMenuButton(
                  color: notifier.getContainer,
                  shadowColor: Colors.grey.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  tooltip: "Notifications",
                  offset: const Offset(0, 50),
                  icon: SvgPicture.asset(
                    "assets/bell-notification.svg",
                    width: 20,
                    height: 20,
                    color: notifier.getIconColor,
                  ),
                  itemBuilder: (ctx) => [
                    _buildPopupNotificationsMenuItem12(),
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
                PopupMenuButton(
                  shadowColor: Colors.grey.withOpacity(0.5),
                  tooltip: '',
                  offset: Offset(0, constraints.maxWidth >= 800 ? 50 : 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                  constraints: const BoxConstraints(
                    maxWidth: 200,
                    minWidth: 200,
                  ),
                  color: notifier.getContainer,
                  child: constraints.maxWidth <= 800
                      ? Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              Center(child: Image.asset('assets/profile.png')),
                        )
                      : Transform.translate(
                          offset: const Offset(0, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CircleAvatar(
                                      backgroundImage:
                                          AssetImage('assets/profile.png'),
                                      backgroundColor: Colors.white,
                                      radius: 18),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Buzz",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              overflow: TextOverflow.ellipsis,
                                              color: notifier.getMainText)),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("admin",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  color: notifier.getMaingey)),
                                          Icon(
                                            Icons.arrow_drop_down_outlined,
                                            size: 12,
                                            color: notifier.getContainer,
                                          )
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                  itemBuilder: (ctx) => [
                    _buildPopupAdminMenuItem(),
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
          ],
        );
      });
    });
  }

  PopupMenuItem _buildPopupCartMenuItem() {
    return PopupMenuItem(
      enabled: false,
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Text(
            "Cart",
            style: TextStyle(
                color: notifier!.getMainText,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
          const SizedBox(
            height: 25,
          ),
          Divider(
            height: 1,
            color: notifier!.getBorderColor,
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
              height: 100,
              width: 300,
              child: Row(
                children: [
                  Container(
                    height: 70,
                    width: 60,
                    decoration: BoxDecoration(
                        image: const DecorationImage(
                            image: AssetImage(
                                "assets/dance-shoes-png-transparent-dance-shoes-images-5-min.png"),
                            fit: BoxFit.fill),
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    height: 80,
                    width: 178,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Nike Shoes",
                                style: TextStyle(
                                    fontSize: 13,
                                    color: notifier!.getMainText)),
                            const SizedBox(
                              width: 10,
                            ),
                            SvgPicture.asset(
                              "assets/times.svg",
                              height: 10,
                              width: 10,
                              color: Colors.red,
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Wrap(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.grey.shade200,
                              child: Center(
                                  child:
                                      Text("-", style: mediumBlackTextStyle)),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text("0",
                                  style: mediumBlackTextStyle.copyWith(
                                      color: notifier!.getMainText)),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.grey.shade200,
                              child: Center(
                                  child:
                                      Text("+", style: mediumBlackTextStyle)),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        const Text("\$800",
                            style: TextStyle(
                                fontSize: 14,
                                color: appMainColor,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              )),
          Divider(
            height: 1,
            color: notifier!.getBorderColor,
          ),
          SizedBox(
              height: 100,
              width: 300,
              child: Row(
                children: [
                  Container(
                    height: 70,
                    width: 60,
                    decoration: BoxDecoration(
                        image: const DecorationImage(
                            image: AssetImage(
                                "assets/fashion-shoes-sneakers-removebg-preview-min.png"),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    height: 80,
                    width: 178,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Jorden Shoes",
                                style: TextStyle(
                                    fontSize: 13,
                                    color: notifier!.getMainText)),
                            const SizedBox(width: 10),
                            SvgPicture.asset(
                              "assets/times.svg",
                              height: 10,
                              width: 10,
                              color: Colors.red,
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Wrap(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.grey.shade200,
                              child: Center(
                                  child:
                                      Text("-", style: mediumBlackTextStyle)),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text("0",
                                  style: mediumBlackTextStyle.copyWith(
                                      color: notifier!.getMainText)),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.grey.shade200,
                              child: Center(
                                  child:
                                      Text("+", style: mediumBlackTextStyle)),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        const Text("\$1900",
                            style: TextStyle(
                                fontSize: 14,
                                color: appMainColor,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              )),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Order Total :",
                  style: mediumBlackTextStyle.copyWith(
                      color: notifier!.getMainText)),
              Text("\$2700.00",
                  style: mediumBlackTextStyle.copyWith(
                      color: notifier!.getMainText))
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          const Text(
            "GO TO YOUR CART",
            style: TextStyle(
                color: appMainColor,
                decoration: TextDecoration.underline,
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 15,
          ),
          ElevatedButton(
              onPressed: () {
                controller.changePage('11');
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: appMainColor,
                  fixedSize: const Size(140, 35)),
              child: const Text(
                "CHECK OUT",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w200),
              )),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  PopupMenuItem _buildPopupAdminMenuItem() {
    return PopupMenuItem(
      enabled: false,
      padding: const EdgeInsets.all(0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 305,
            width: 155,
            child: Center(
              child: Table(
                columnWidths: const {
                  0: FixedColumnWidth(20),
                },
                children: [
                  row(title: 'Profile', icon: 'assets/user.svg', index: 'profile'),
                  row(title: 'Chat', icon: 'assets/chat-dots.svg', index: 'chat'),
                  row(title: 'Email', icon: 'assets/envelope.svg', index: 'dashboard'),
                  row(
                      title: 'Todo',
                      icon: 'assets/clipboard-check.svg',
                      index: ''),
                  row(title: 'Setting', icon: 'assets/settings.svg', index: 'settings'),
                  row(
                      title: 'Price',
                      icon: 'assets/credit-card.svg',
                      index: 'price'),
                  row(title: 'Faq', icon: 'assets/chat-info.svg', index: 'faq'),
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SvgPicture.asset(
                        "assets/tool.svg",
                        width: 18,
                        height: 18,
                        color: notifier!.getIconColor,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 5, left: 20, top: 12, right: 20),
                          child: Text("RTL",
                              style: mediumBlackTextStyle.copyWith(
                                  color: notifier!.getMainText)),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Obx(() => Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: SizedBox(
                                height: 20,
                                width: 50,
                                child: Transform.scale(
                                  scale: 0.8,
                                  child: Switch(
                                    value: controller.switchIsTrue.value,
                                    onChanged: (bool value) {
                                      controller.switchIsTrue.value = value;
                                      Future.delayed(
                                        const Duration(milliseconds: 300),
                                        () {
                                          if (value == true) {
                                            Get.updateLocale(
                                                const Locale('ur', 'PK'));
                                            Get.back();
                                          } else {
                                            Get.updateLocale(
                                                const Locale('en', 'US'));
                                            Get.back();
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            )),
                      ],
                    )
                  ]),
                  row(title: 'Logout', icon: 'assets/log-out.svg', index: ''),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool light1 = true;

  TableRow row(
      {required String title, required String icon, required String index}) {
    return TableRow(children: [
      TableRowInkWell(
        onTap: () {
          controller.changePage(index);
          Get.back();
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: SvgPicture.asset(icon,
              width: 18, height: 18, color: notifier!.getIconColor),
        ),
      ),
      TableRowInkWell(
        onTap: () {
          controller.changePage(index);
          Get.back();
        },
        child: Padding(
          padding:
              const EdgeInsets.only(bottom: 5, left: 20, top: 12, right: 20),
          child: Text(title,
              style:
                  mediumBlackTextStyle.copyWith(color: notifier!.getMainText)),
        ),
      ),
    ]);
  }
}

PopupMenuItem _buildPopupNotificationsMenuItem12() {
  return PopupMenuItem(
    padding: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15, top: 5),
          child: Row(
            children: [
              Text(
                "Notifications",
                style: TextStyle(
                    color: notifier!.getMainText,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              const Spacer(),
            ],
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Divider(
          height: 1,
          color: notifier!.getBorderColor,
        ),
        const SizedBox(
          height: 7,
        ),
        _buildCommonTile(
            colorSub: notifier!.getsubcolors,
            width: 13,
            height: 13,
            padding: const EdgeInsets.all(5),
            colors: notifier!.getTextColor1,
            title: 'Google',
            backgroundImage: 'assets/google-min.png',
            subTile:
                "Hey, I just found out what's causing the\nserver to crash!",
            color: Colors.grey.shade300),
        const SizedBox(
          height: 5,
        ),
        Divider(
          height: 1,
          color: notifier!.getBorderColor,
        ),
        _buildCommonTile(
            colorSub: notifier!.getsubcolors,
            colors: notifier!.getTextColor1,
            fontWeight: FontWeight.w800,
            backcolor: notifier!.getbacknoticolor,
            title: 'Dai Jiang',
            backgroundImage: 'assets/avatar.png',
            subTile: "What about some coffee this afternoon to discuss?",
            color: const Color(0xff0d6efd)),
        Divider(
          height: 1,
          color: notifier!.getBorderColor,
        ),
        const SizedBox(
          height: 5,
        ),
        _buildCommonTile(
            colorSub: notifier!.getsubcolors,
            height: 13,
            width: 13,
            padding: const EdgeInsets.all(5),
            colors: notifier!.getTextColor1,
            title: 'Snapchat',
            backgroundImage: 'assets/005-snapchat.png',
            subTile:
                "I finally got the present i mentioned to\nsteven, you'll love it",
            color: Colors.grey.shade300),
        const SizedBox(
          height: 5,
        ),
        Divider(
          height: 1,
          color: notifier!.getBorderColor,
        ),
        const SizedBox(
          height: 5,
        ),
        _buildCommonTile(
            colorSub: notifier!.getsubcolors,
            colors: notifier!.getTextColor1,
            title: 'Trashae Hubbard',
            backgroundImage: "assets/avatar1.png",
            subTile:
                "Hey, I just found out what's causing the\nserver to crash!",
            color: Colors.grey.shade300),
        const SizedBox(
          height: 5,
        ),
        Divider(
          height: 1,
          color: notifier!.getBorderColor,
        ),
        const SizedBox(height: 5),
        Center(
          child: Text(
            "View All",
            style: TextStyle(color: notifier!.getTextColor1),
          ),
        )
      ],
    ),
  );
}

Widget _buildCommonTile(
    {required String title,
    required String subTile,
    EdgeInsetsGeometry? padding,
    required Color color,
    required String backgroundImage,
    Color? backcolor,
    FontWeight? fontWeight,
    Color? colors,
    double? width,
    double? height,
    required Color colorSub}) {
  return Container(
    color: backcolor,
    child: Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        children: [
          // Padding(
          //   padding: const EdgeInsets.only(left: 15),
          //   child: Container(
          //     width: 7,
          //     height: 7,
          //     decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(100), color: color),
          //   ),
          // ),
          Flexible(
            flex: 3,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              trailing: Text(
                "just now",
                style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                    overflow: TextOverflow.ellipsis),
              ),
              title: Text(
                title,
                style: TextStyle(
                    color: colors,
                    fontSize: 16,
                    overflow: TextOverflow.ellipsis),
              ),
              subtitle: Text(subTile,
                  style: TextStyle(
                      color: colorSub,
                      fontWeight: fontWeight,
                      overflow: TextOverflow.ellipsis),),
              leading: Material(
                // elevation: 3,
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  height: 35,
                  width: 35,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  padding: padding,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      backgroundImage,
                      width: width,
                      height: height,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
