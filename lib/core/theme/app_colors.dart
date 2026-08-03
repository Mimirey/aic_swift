import 'package:flutter/material.dart';

/// Palet warna utama aplikasi Swift.
/// Disesuaikan dari mockup: navy blue sebagai primary, aksen biru terang,
/// background abu muda, dan warna-warna status paket.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0F3D73); // navy blue utama
  static const Color primaryDark = Color(0xFF0A2C54); // header card, sign in button
  static const Color primaryLight = Color(0xFF2E6FB8); // aksen / link

  static const Color background = Color(0xFFF4F6FA);
  static const Color surface = Colors.white;

  static const Color textPrimary = Color(0xFF1A1F36);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnPrimary = Colors.white;

  static const Color border = Color(0xFFE3E6ED);
  static const Color inputFill = Color(0xFFF7F8FB);

  static const Color badgeOutline = Colors.white; // border badge Express/COD di header card
  static const Color statusChipBg = Color(0xFFEAF1FB);
  static const Color statusChipText = Color(0xFF1E5AA8);

  static const Color codAmount = Color(0xFFD64545);

  static const Color mapOverlay = Color(0x99101828); // overlay gelap tipis di atas map
}
