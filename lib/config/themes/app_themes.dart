import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:getx_setup/config/themes/app_colors.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    fontFamily: 'DMSans',
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.bgColor,
    colorScheme: ColorScheme.light(
      surface: AppColors.bgColor,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: SupportAppColors.normalOrange,
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bgColor,
      elevation: 0,
      surfaceTintColor: AppColors.bgColor,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      iconTheme: IconThemeData(color: Color(0xFF323232)),
      titleTextStyle: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF323232),
      ),
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 1,
      shadowColor: Color(0x1A000000),
    ),
    dividerTheme: const DividerThemeData(
      color: SupportAppColors.greyMidColor,
      thickness: 1,
    ),
    iconTheme: const IconThemeData(color: Color(0xFF323232)),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF323232)),
      bodyMedium: TextStyle(color: Color(0xFF323232)),
      bodySmall: TextStyle(color: Color(0xFF6C6C6C)),
    ),
  );
}
