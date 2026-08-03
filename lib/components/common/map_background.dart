import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Wrapper FlutterMap pakai tile OpenStreetMap (gratis, tanpa API key).
///
/// Catatan penting:
/// - Tile server `tile.openstreetmap.org` punya usage policy & rate limit
///   buat production (lihat: https://operations.osmfoundation.org/policies/tiles/).
///   Aman-aman aja buat development/dummy, tapi kalau sudah rilis & trafiknya
///   naik, sebaiknya pindah ke provider tile gratis lain yang punya tier lebih
///   jelas (misalnya MapTiler / Stadia Maps / Mapbox free tier), tinggal ganti
///   `urlTemplate` di bawah.
/// - `userAgentPackageName` wajib diisi sesuai applicationId project kamu.
class MapBackground extends StatelessWidget {
  final LatLng center;
  final double zoom;
  final List<Marker> markers;
  final bool interactive;

  const MapBackground({
    super.key,
    required this.center,
    this.zoom = 14,
    this.markers = const [],
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.swift.delivery_app',
        ),
        if (markers.isNotEmpty) MarkerLayer(markers: markers),
        const RichAttributionWidget(
          attributions: [
            TextSourceAttribution('OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }
}
