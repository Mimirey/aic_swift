import 'package:get/get.dart';
import 'package:Swift/controllers/map_calculating_controller.dart';

class MapCalculatingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MapCalculatingController>(() => MapCalculatingController());
  }
}