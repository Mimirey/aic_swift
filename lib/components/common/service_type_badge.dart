import 'package:flutter/material.dart';
import 'package:Swift/models/package/package_model.dart';

class ServiceTypeBadge extends StatelessWidget {
  final ServiceType serviceType;

  const ServiceTypeBadge({super.key, required this.serviceType});

  @override
  Widget build(BuildContext context) {
    final isExpress = serviceType == ServiceType.express;
    final color = isExpress ? Colors.orange : Colors.blue;
    final label = isExpress ? 'EXPRESS' : 'REGULER';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}