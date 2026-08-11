import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class RecipientNoteCard extends StatelessWidget {
  final String note;
  const RecipientNoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.statusChipBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Catatan Penerima', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 4),
          Text(note, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}