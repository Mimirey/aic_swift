import 'package:geolocator/geolocator.dart';

Future<Position?> getCurrentUserLocation() async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return null;

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return null;
  }
  if (permission == LocationPermission.deniedForever) return null;

  return Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
  );
}

double distanceToTargetInMeters(
  Position position,
  double targetLat,
  double targetLng,
) {
  return Geolocator.distanceBetween(
    position.latitude,
    position.longitude,
    targetLat,
    targetLng,
  );
}
