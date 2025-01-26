import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/app_bar.dart';
import 'package:ige_hospital/darwer.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/static_data.dart';
import 'package:ige_hospital/static_data/static_data.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
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
                      child: const SizedBox())
                      : const SizedBox(),
                  Expanded(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          const AppBarCode(),
                          Expanded(
                            child: const SizedBox(),
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
      return GetBuilder<AppConst>(builder: (controller){
        return Scaffold(
          appBar: const AppBarCode(),
          drawer: const Drawer(width: 260, child: DrawerCode()),
        );
      });
    }
  }
}
