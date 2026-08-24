import 'package:Swift/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PackageMapMarker extends StatelessWidget {
  final bool isActive;
  const PackageMapMarker({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    if (!isActive) {
      return _buildPin(size: 26, color: AppColors.primary.withOpacity(0.7));
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned(
          bottom: 2,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          ),
        ),
        _buildPin(size: 40, color: AppColors.primary),
      ],
    );
  }

  Widget _buildPin({required double size, required Color color}) {
    return Icon(
      Icons.location_on,
      size: size,
      color: color,
    );
  }
}