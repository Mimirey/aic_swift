import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Badge outline putih, dipakai di atas background gelap (contoh: header
/// card paket) untuk label "Express" / "COD".
class OutlineBadge extends StatelessWidget {
  final String label;

  const OutlineBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.badgeOutline, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Badge terisi warna muda, dipakai buat status pengiriman ("Sampai", dst)
/// di atas background putih.
class StatusChip extends StatelessWidget {
  final String label;

  const StatusChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.statusChipBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.statusChipText,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
