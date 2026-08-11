import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CurrentPackagePreview extends StatelessWidget {
  final String address;
  const CurrentPackagePreview({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.location_on, size: 18, color: AppColors.primaryLight),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Paket Sekarang', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primaryLight)),
              Text(address, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}