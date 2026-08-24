import 'package:flutter/material.dart';
import 'package:Swift/core/theme/app_colors.dart';

class CodBadge extends StatelessWidget {
  const CodBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.codAmount.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'COD',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.codAmount,
        ),
      ),
    );
  }
}