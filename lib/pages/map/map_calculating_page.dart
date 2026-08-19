import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:Swift/controllers/map_calculating_controller.dart';
import 'package:Swift/core/theme/app_colors.dart';
import 'package:Swift/core/utils/responsive.dart';
import 'package:Swift/components/common/map_background.dart';
import 'package:Swift/components/common/date_chip.dart';

class MapCalculatingPage extends GetView<MapCalculatingController> {
  const MapCalculatingPage({super.key});

  static const _dummyCenter = LatLng(-6.9932, 110.4203);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: MapBackground(
              center: _dummyCenter,
              zoom: 15,
              interactive: false,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(color: Colors.white.withOpacity(0.55)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.horizontalPadding,
                vertical: 8,
              ),
              child: const Align(
                alignment: Alignment.topLeft,
                child: DateChip(date: '30 Juli 2026'),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.horizontalPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PulsingPin(controller: controller.pulseController),
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
                    'Mohon tunggu, kami sedang mengurutkan\nlokasi pengiriman tercepat.',
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
        ],
      ),
    );
  }
}

/// Pin lokasi dengan efek halo "ping" yang membesar & memudar berulang.
class _PulsingPin extends StatelessWidget {
  final AnimationController controller;

  const _PulsingPin({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      width: 110,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final t = controller.value; // 0..1
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