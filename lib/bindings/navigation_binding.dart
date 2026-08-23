import 'package:Swift/controllers/navigation_controller.dart';
import 'package:get/get.dart';

class NavigationBinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut<NavigationController>(()=> NavigationController());
  }
  
}