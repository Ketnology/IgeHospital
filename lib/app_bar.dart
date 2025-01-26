import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/static_data.dart';
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              enabled: false,
                              child: SizedBox(
                                  height: 42,
                                  child: TextField(
                                    style:
                                        TextStyle(color: notifier.getMainText),
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.only(top: 5),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: notifier.getBorderColor,
                                              width: 2)),
                                      disabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: notifier.getBorderColor,
                                              width: 2)),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: notifier.getBorderColor,
                                              width: 2)),
                                      hintStyle: TextStyle(
                                          color: notifier.getMainText),
                                      hintText: "Search..",
                                    ),
                                  )))
                        ],
                      )
                    : InkWell(
                        onTap: () {
                          setState(() {
                            search = !search;
                          });
                        },
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
                      notifier.isavalable(true);
                    } else {
                      notifier.isavalable(false);
                    }
                  },
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
                    //
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
                    //
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
                    // _buildPopupAdminMenuItem(),
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
          ],
        );
        return Text('appBar');
      });
    });
  }
}
