import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/package/package_model.dart';
import '../common/service_type_badge.dart'; // tambahan import

class CurrentPackagePreview extends StatelessWidget {
  final String address;
  final ServiceType serviceType;
  final String resiNumber;

  const CurrentPackagePreview({
    super.key,
    required this.address,
    required this.serviceType,
    required this.resiNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.location_on, size: 18, color: AppColors.primaryLight),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ServiceTypeBadge(serviceType: serviceType),
                  const SizedBox(width: 6),
                  Text(
                    resiNumber,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
