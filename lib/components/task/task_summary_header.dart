import 'package:Swift/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TaskSummaryHeader extends StatelessWidget {
  final String packageLabel;   // "Package 1"
  final String etaLabel;       // "40 Menit"
  final String resiNumber;

  const TaskSummaryHeader({
    super.key,
    required this.packageLabel,
    required this.etaLabel,
    required this.resiNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(packageLabel, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            Text(etaLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryLight)),
          ],
        ),
        const SizedBox(height: 4),
        Text('Resi: $resiNumber', style: const TextStyle(fontSize: 13, color: AppColors.primaryLight)),
        const Divider(height: 24),
      ],
    );
  }
}