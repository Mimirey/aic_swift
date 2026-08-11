import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TaskAssignedHeader extends StatelessWidget {
  final int totalPackages;
  const TaskAssignedHeader({super.key, required this.totalPackages});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kamu dapat Tugas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          'Paket yang harus kamu antarkan berjumlah $totalPackages Paket',
          style: const TextStyle(fontSize: 13, color: AppColors.primaryLight, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}