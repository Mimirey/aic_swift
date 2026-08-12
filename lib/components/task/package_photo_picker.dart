import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../core/theme/app_colors.dart';

class PackagePhotoPicker extends StatelessWidget {
  final VoidCallback onTap;
  const PackagePhotoPicker({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          color: AppColors.primaryLight,
          strokeWidth: 1.4,
          dashPattern: const [6, 4],
          radius: const Radius.circular(14),
        ),
        child: Container(
          width: double.infinity,
          height: 130,
          decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(14)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.camera_alt_outlined, size: 30, color: AppColors.primaryLight),
              SizedBox(height: 8),
              Text('Foto Paket & Penerima',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
            ],
          ),
        ),
      ),
    );
  }
}