import 'package:get/get.dart';
import 'package:Swift/controllers/map_controller.dart';

class MapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MapPageController>(() => MapPageController());
  }
}