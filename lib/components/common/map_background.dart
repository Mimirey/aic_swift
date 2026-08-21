import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapBackground extends StatelessWidget {
  final MapController? controller;
  final LatLng center;
  final double zoom;
  final Widget? markersLayer;
  final Widget? polylinesLayer;
  final bool interactive;

  const MapBackground({
    super.key,
    this.controller,
    required this.center,
    this.zoom = 14,
    this.markersLayer,
    this.polylinesLayer,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        minZoom: 3,
        maxZoom: 19,
        cameraConstraint: CameraConstraint.contain(
          bounds: LatLngBounds(const LatLng(-85, -180), const LatLng(85, 180)),
        ),
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.swift.delivery_app',
        ),
        if (polylinesLayer != null) polylinesLayer!,
        if (markersLayer != null) markersLayer!,
        const RichAttributionWidget(
          attributions: [TextSourceAttribution('OpenStreetMap contributors')],
        ),
      ],
    );
  }
}
