import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/pages/home.dart';

class AppConst extends GetxController implements GetxService {
  bool showDrawer = true;

  updateShowDrawer() {
    showDrawer = !showDrawer;
    update();
  }

  RxString selectedPageKey = "".obs;

  RxInt selectColor = 0.obs;
  RxInt selectedTile = 0.obs;

  RxInt gridCounter = 4.obs;

  RxInt newGridCounter = 4.obs;

  RxDouble size = 550.0.obs;

  RxDouble size2 = 350.0.obs;

  int selectCategory = 0;

  int gridCounter1 = 4;
  int gridCount = 4;

  gridUpdate(int value) {
    gridCounter1 = value;
  }

  gridUpdate1(int value) {
    gridCounter1 = value;
    update();
  }

  changeCurrentIndex({int? index}) {
    selectCategory = index ?? 0;
    update();
  }

  //Switch
  RxBool switchIsTrue = false.obs;

  // Page mapping with keywords
  final Map<String, Widget> pages = {
    '': const DefaultPage(),
    'overview': const DefaultPage(),
    'appointment': const DefaultPage(),
  };

  void changePage(String newPageKey) {
    if (pages.containsKey(newPageKey)) {
      selectedPageKey.value = newPageKey;
    } else {
      print("Page key '$newPageKey' not found in pages map.");
    }
  }

}
