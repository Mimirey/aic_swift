import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class RouteCalculatingOverlay extends StatefulWidget {
  const RouteCalculatingOverlay({super.key});

  @override
  State<RouteCalculatingOverlay> createState() => _RouteCalculatingOverlayState();
}

class _RouteCalculatingOverlayState extends State<RouteCalculatingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.white.withOpacity(0.9),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PulsingPin(controller: _controller),
              const SizedBox(height: 22),
              const Text('Menghitung Rute...',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
              const SizedBox(height: 8),
              const Text(
                'Mohon tunggu, kami sedang mengurutkan\nlokasi pengiriman tercepat.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
          final t = controller.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: (1 - t).clamp(0.0, 1.0),
                child: Container(
                  width: 60 + (t * 50),
                  height: 60 + (t * 50),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.15)),
                ),
              ),
              Container(
                width: 60, height: 60,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.background),
              ),
              const Icon(Icons.location_on, color: AppColors.primary, size: 46),
            ],
          );
        },
      ),
    );
  }
}