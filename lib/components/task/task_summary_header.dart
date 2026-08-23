import 'package:Swift/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TaskSummaryHeader extends StatelessWidget {
  final Widget leading; // <- ganti dari packageLabel: String
  final Widget trailing;
  final String resiNumber;

  const TaskSummaryHeader({
    super.key,
    required this.leading,
    required this.trailing,
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
            leading,
            trailing,
          ],
        ),
        const SizedBox(height: 4),
        Text('Resi: $resiNumber', style: const TextStyle(fontSize: 13, color: AppColors.primaryLight)),
        const Divider(height: 24),
      ],
    );
  }
}