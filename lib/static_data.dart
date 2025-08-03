import 'package:get/get.dart';
import 'package:ige_hospital/pages/page_mappings.dart';
import 'package:ige_hospital/provider/permission_service.dart';

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

  // Patient data storage for vital signs navigation
  String selectedPatientId = '';
  String selectedPatientName = '';

  changeCurrentIndex({int? index}) {
    selectCategory = index ?? 0;
    update();
  }

  //Switch
  RxBool switchIsTrue = false.obs;

  void changePage(String newPageKey) {
    Get.log("AppConst - Attempting to change page to: '$newPageKey'");

    // Check if user has permission to access this page
    try {
      final permissionService = Get.find<PermissionService>();
      if (!permissionService.canAccessPage(newPageKey)) {
        Get.log("AppConst - Access denied to page: '$newPageKey'");
        Get.snackbar(
          'Access Denied',
          'You do not have permission to access this page.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    } catch (e) {
      Get.log("AppConst - Error checking permissions: $e");
      // Continue anyway if permission service is not available
    }

    // Page mapping with keywords
    if (pages.containsKey(newPageKey)) {
      Get.log("AppConst - Page found, changing to: '$newPageKey'");
      selectedPageKey.value = newPageKey;
    } else {
      Get.log("AppConst - Page key '$newPageKey' not found in pages map.");
      Get.log("AppConst - Available pages: ${pages.keys}");

      // Fallback to overview if page not found
      if (pages.containsKey('')) {
        selectedPageKey.value = '';
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    Get.log("AppConst - Initialized with default page");
    // Start with overview page
    selectedPageKey.value = '';
  }
}
