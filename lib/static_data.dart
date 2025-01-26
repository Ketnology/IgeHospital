import 'package:get/get.dart';

class AppConst extends GetxController implements GetxService {
  bool showDrawer = true;

  updateShowDrawer() {
    showDrawer = !showDrawer;
    update();
  }

  RxInt pageSelector = 0.obs;

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

//
}
