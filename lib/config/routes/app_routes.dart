import 'package:Swift/bindings/login_binding.dart';
import 'package:Swift/bindings/map_binding.dart';
import 'package:Swift/bindings/map_calculating_binding.dart';
import 'package:Swift/bindings/package_list_binding.dart';
import 'package:Swift/pages/map/map_page.dart';
import 'package:Swift/pages/splash/splash_page.dart';
import 'package:get/get.dart';
import 'package:Swift/pages/login/login_page.dart';
import 'package:Swift/pages/map/map_calculating_page.dart';
import 'package:Swift/pages/package/package_list_page.dart';
import '../../enum/stage.dart';
import 'route_names.dart';

class AppPages {
  AppPages._();

  static final List<GetPage> pages = [
    GetPage(name: AppRoutes.login, page: () => const LoginPage(), binding: LoginBinding()),
    GetPage(name: AppRoutes.packageList, page: () => const PackageListPage(), binding: PackageListBinding()),
    GetPage(name: AppRoutes.map, page: () =>  MapPage(), binding: MapBinding()),
    GetPage(name: AppRoutes.mapCalculating, page: () => const MapCalculatingPage(), binding: MapCalculatingBinding()),
    GetPage(name: AppRoutes.splash, page: ()=> const SplashPage())
  ];
}