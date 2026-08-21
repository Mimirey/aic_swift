import 'dart:math';
import 'package:flutter/material.dart';

class UserLocationMarker extends StatelessWidget {
  final double? turns;

  const UserLocationMarker({super.key, this.turns});

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: turns ?? 0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
            ),
            if (turns != null)
              Positioned(
                top: 4,
                child: Transform.rotate(
                  angle: -pi / 2,
                  child: const Icon(
                    Icons.navigation,
                    color: Colors.white,
                    size: 18,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}