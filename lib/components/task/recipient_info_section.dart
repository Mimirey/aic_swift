import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class RecipientInfoSection extends StatelessWidget {
  final String name;
  final String address;
  const RecipientInfoSection({super.key, required this.name, required this.address});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.person_outline, size: 18, color: AppColors.textPrimary),
          const SizedBox(width: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textPrimary),
          const SizedBox(width: 8),
          Expanded(child: Text(address, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
        ]),
      ],
    );
  }
}