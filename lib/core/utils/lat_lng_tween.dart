import 'package:flutter/animation.dart';
import 'package:latlong2/latlong.dart';

class LatLngTween extends Tween<LatLng> {
  LatLngTween({required LatLng super.begin, required LatLng super.end});

  @override
  LatLng lerp(double t) {
    final lat = begin!.latitude + (end!.latitude - begin!.latitude) * t;
    final lng = begin!.longitude + (end!.longitude - begin!.longitude) * t;
    return LatLng(lat, lng);
  }
}
