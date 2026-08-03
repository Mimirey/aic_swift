import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:getx_setup/config/routes/app_routes.dart';
import 'package:getx_setup/config/routes/route_names.dart';
import 'package:getx_setup/config/themes/app_themes.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await findSystemLocale();
  await initializeDateFormatting(Intl.systemLocale);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: AppThemes.lightTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.login,
      getPages: AppPages.pages,
    );
  }
}
