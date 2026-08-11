import 'package:flutter/material.dart';
import 'package:Swift/models/package/package_model.dart';
import '../../core/theme/app_colors.dart';
import '../badges/status_badge.dart';

class PackageCard extends StatelessWidget {
  final PackageModel package;
  final VoidCallback? onTap;

  const PackageCard({super.key, required this.package, this.onTap});

  String _formatCurrency(double amount) {
    final str = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final posFromRight = str.length - i;
      buffer.write(str[i]);
      if (posFromRight > 1 && posFromRight % 3 == 1) buffer.write('.');
    }
    return 'Rp $buffer';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header gelap: nomor resi + badge layanan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(
                  color: AppColors.primaryDark,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Resi : ${package.resiNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlineBadge(label: package.serviceType.label),
                    if (package.isCod) ...[
                      const SizedBox(width: 6),
                      const OutlineBadge(label: 'COD'),
                    ],
                  ],
                ),
              ),
              // Body putih: info customer
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Kalau layar sempit, nama & telepon ditumpuk vertikal
                        // biar gak overflow.
                        final isNarrow = constraints.maxWidth < 260;
                        final nameWidget = Text(
                          package.customerName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        );
                        final phoneWidget = Text(
                          package.phoneNumber,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        );
                        if (isNarrow) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              nameWidget,
                              const SizedBox(height: 2),
                              phoneWidget,
                            ],
                          );
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(child: nameWidget),
                            const SizedBox(width: 8),
                            phoneWidget,
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    Text(
                      package.address,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.primaryLight),
                    ),
                    if (package.note != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '"${package.note}"',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontStyle: FontStyle.italic,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                    if (package.isCod && package.codAmount != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tagihan COD : ${_formatCurrency(package.codAmount!)}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.codAmount,
                            ),
                          ),
                          StatusChip(label: package.status.label),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
