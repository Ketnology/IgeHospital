import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/app_bar.dart';
import 'package:ige_hospital/drawer.dart';
import 'package:ige_hospital/pages/page_mappings.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/static_data.dart';
import 'package:ige_hospital/static_data/static_data.dart';
import 'package:provider/provider.dart';

class MyHomepage extends StatefulWidget {
  const MyHomepage({super.key});

  @override
  State<MyHomepage> createState() => _MyHomepageState();
}

class _MyHomepageState extends State<MyHomepage> {
  AppConst obj = AppConst();
  final AppConst controller = Get.put(AppConst());

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColourNotifier>(context, listen: false);
    RxDouble? screenWidth = Get.width.obs;
    double? breakpoint = 600.0;

    if (screenWidth >= breakpoint) {
      return GetBuilder<AppConst>(builder: (controller) {
        return Scaffold(
          body: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  controller.showDrawer
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: 260,
                          child: const DrawerCode())
                      : const SizedBox(),
                  Expanded(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          const AppBarCode(),
                          Expanded(
                            child: Obx(() {
                              Widget selectedPage =
                                  pages[controller.selectedPageKey.value] ??
                                      Container();
                              return selectedPage;
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      });
    } else {
      return GetBuilder<AppConst>(builder: (controller) {
        return Scaffold(
          appBar: const AppBarCode(),
          drawer: const Drawer(width: 260, child: DrawerCode()),
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Obx(() {
              Widget selectedPage =
                  pages[controller.selectedPageKey.value] ?? Container();
              return selectedPage;
            }),
          ),
        );
      });
    }
  }
}
