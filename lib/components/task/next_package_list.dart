import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/next_package_item.dart';

class NextPackageList extends StatelessWidget {
  final List<NextPackageItem> items;
  final VoidCallback? onSeeNextSession;
  const NextPackageList({super.key, required this.items, this.onSeeNextSession});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Paket Selanjutnya', style: TextStyle(fontWeight: FontWeight.w700)),
            const Text('Sesi 1', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.radio_button_checked, size: 14, color: AppColors.primaryLight),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.address, style: const TextStyle(fontSize: 12.5)),
                    Text(item.distanceLabel, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ]),
                ),
              ]),
            )),
        Center(
          child: TextButton(
            onPressed: onSeeNextSession,
            child: const Text('Lihat sesi berikutnya', style: TextStyle(fontSize: 12.5)),
          ),
        ),
      ],
    );
  }
}