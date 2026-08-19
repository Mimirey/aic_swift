import 'package:get/get.dart';
import 'package:Swift/controllers/package_list_controller.dart';

class PackageListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PackageListController>(() => PackageListController());
  }
}