import 'package:get/get.dart';
import 'package:ige_hospital/pages/page_mappings.dart';

class AppConst extends GetxController implements GetxService {
  bool showDrawer = true;

  updateShowDrawer() {
    showDrawer = !showDrawer;
    update();
  }

  RxString selectedPageKey = "".obs;

  RxInt selectColor = 0.obs;
  RxInt gridCounter = 4.obs;
  RxDouble size = 550.0.obs;
  int selectCategory = 0;

  changeCurrentIndex({int? index}) {
    selectCategory = index ?? 0;
    update();
  }

  //Switch
  RxBool switchIsTrue = false.obs;

  void changePage(String newPageKey) {
    // Page mapping with keywords
    if (pages.containsKey(newPageKey)) {
      selectedPageKey.value = newPageKey;
    } else {
      print("Page key '$newPageKey' not found in pages map.");
    }
  }

}
