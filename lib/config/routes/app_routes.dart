import 'package:get/get.dart';
import 'package:getx_setup/pages/login/login_page.dart';
import 'package:getx_setup/pages/map/map_calculating_page.dart';
import 'package:getx_setup/pages/map/map_empty_page.dart';
import 'package:getx_setup/pages/package/package_list_page.dart';
import 'route_names.dart';

class AppPages {
  AppPages._();

  static final List<GetPage> pages = [
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
    GetPage(name: AppRoutes.packageList, page: () => const PackageListPage()),
    GetPage(name: AppRoutes.mapEmpty, page: () => const MapEmptyPage()),
    GetPage(name: AppRoutes.mapCalculating, page: () => const MapCalculatingPage()),
  ];
}