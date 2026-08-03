import 'package:flutter/material.dart';

/// Extension kecil buat bantu responsive layout tanpa perlu package tambahan.
/// Dipakai di semua page biar aman dari layar kecil (SE/mini) sampai layar
/// gede (Pro Max / tablet kecil).
extension ResponsiveContext on BuildContext {
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  /// < 360 dianggap layar sempit (misal iPhone SE, Android kecil)
  bool get isCompactWidth => screenWidth < 360;

  /// > 700 dianggap layar lebar (tablet kecil / fold)
  bool get isWideScreen => screenWidth > 700;

  /// Padding horizontal adaptif: makin lebar layar, makin besar padding-nya,
  /// biar konten gak terlalu mepet atau terlalu melar.
  double get horizontalPadding {
    if (isWideScreen) return screenWidth * 0.08;
    if (isCompactWidth) return 16;
    return 20;
  }

  /// Skala font sederhana relatif terhadap lebar layar (basis desain 375px).
  double scaled(double value) {
    final factor = (screenWidth / 375).clamp(0.85, 1.15);
    return value * factor;
  }
}
