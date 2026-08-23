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
        // pulse ring di belakang, sejajar sama ujung bawah pin
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
    return CustomPaint(
      size: Size(size, size * 1.25),
      painter: _PinPainter(color: color),
    );
  }
}

class _PinPainter extends CustomPainter {
  final Color color;
  _PinPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final radius = w / 2;

    final path = Path()
      ..moveTo(w / 2, h) // ujung bawah pin (runcing)
      ..lineTo(w * 0.22, h * 0.55)
      ..arcToPoint(
        Offset(w * 0.78, h * 0.55),
        radius: Radius.circular(radius),
        clockwise: true,
      )
      ..close();

    final fillPaint = Paint()..color = color;
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);

    // lingkaran kecil putih di tengah kepala pin, biar ada aksen
    canvas.drawCircle(
      Offset(w / 2, h * 0.4),
      w * 0.15,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _PinPainter oldDelegate) =>
      oldDelegate.color != color;
}