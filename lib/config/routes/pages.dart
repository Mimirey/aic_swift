import 'package:get/get.dart';
import 'package:getx_setup/config/routes/routes.dart';
import 'package:getx_setup/pages/splash/splash_page.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
    // GetPage(
    //   name: AppRoutes.login,
    //   page: () => LoginPage(),
    //   binding: LoginBinding(),
    // ),
  ];
}
