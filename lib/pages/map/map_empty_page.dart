import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../components/common/map_background.dart';
import '../../components/common/date_chip.dart';
import '../../components/common/empty_state_widget.dart';

class MapEmptyPage extends StatelessWidget {
  const MapEmptyPage({super.key});

  // Dummy center point (area Semarang). Ganti dengan lokasi kurir aktual
  // dari GPS/API begitu sudah terhubung.
  static const _dummyCenter = LatLng(-6.9932, 110.4203);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: MapBackground(center: _dummyCenter, zoom: 15),
          ),
          // Dim tipis di atas map biar konten overlay tetap kebaca
          Positioned.fill(
            child: IgnorePointer(
              child: Container(color: Colors.white.withOpacity(0.15)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 8),
              child: const Align(
                alignment: Alignment.topLeft,
                child: DateChip(date: '30 Juli 2026'),
              ),
            ),
          ),
          // Tombol map layer & lokasi saya (dekoratif, tinggal disambung logic)
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(right: context.horizontalPadding, top: 90),
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  children: [
                    _MapFab(icon: Icons.layers_outlined, onTap: () {}),
                    const SizedBox(height: 10),
                    _MapFab(icon: Icons.my_location_rounded, onTap: () {}),
                  ],
                ),
              ),
            ),
          ),
          // Panel bawah: empty state
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: 28,
                bottom: MediaQuery.of(context).padding.bottom + 24,
                left: context.horizontalPadding,
                right: context.horizontalPadding,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: const EmptyStateWidget(
                icon: Icons.inventory_2_outlined,
                title: 'Tidak Ada Pengiriman Hari Ini',
                subtitle: 'Belum ada paket yang ditugaskan ke akunmu hari ini.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapFab({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: AppColors.primaryDark),
        ),
      ),
    );
  }
}
