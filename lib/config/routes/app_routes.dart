import 'package:Swift/pages/map/map_page.dart';
import 'package:get/get.dart';
import 'package:Swift/pages/login/login_page.dart';
import 'package:Swift/pages/map/map_calculating_page.dart';
import 'package:Swift/pages/package/package_list_page.dart';
import '../../enum/stage.dart';
import 'route_names.dart';

class AppPages {
  AppPages._();

  static final List<GetPage> pages = [
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
    GetPage(name: AppRoutes.packageList, page: () => const PackageListPage()),
    GetPage(name: AppRoutes.map, page: () =>  MapPage()),
    GetPage(name: AppRoutes.mapCalculating, page: () => const MapCalculatingPage()),
  ];
}