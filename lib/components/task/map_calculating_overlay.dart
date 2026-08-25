import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:Swift/controllers/map_calculating_controller.dart';
import 'package:Swift/core/theme/app_colors.dart';
import 'package:Swift/core/utils/responsive.dart';

class MapCalculatingOverlay extends GetView<MapCalculatingController> {
  const MapCalculatingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: Colors.white.withOpacity(0.55),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.horizontalPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PulsingPin(
                    controller: controller.pulseController,
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Menghitung Rute...',
                    style: TextStyle(
                      fontSize: context.scaled(18),
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mohon tunggu, kami sedang mengurutkan\n'
                    'lokasi pengiriman tercepat.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PulsingPin extends StatelessWidget {
  final AnimationController controller;

  const _PulsingPin({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      width: 110,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final t = controller.value;

          return Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: (1 - t).clamp(0.0, 1.0),
                child: Container(
                  width: 60 + (t * 50),
                  height: 60 + (t * 50),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.15),
                  ),
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                ),
              ),
              const Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 46,
              ),
            ],
          );
        },
      ),
    );
  }
}