import 'dart:async';
import 'package:Swift/components/common/user_location_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class AnimatedUserMarkerLayer extends StatefulWidget {
  final Rx<Position?> positionRx;

  const AnimatedUserMarkerLayer({super.key, required this.positionRx});

  @override
  State<AnimatedUserMarkerLayer> createState() =>
      _AnimatedUserMarkerLayerState();
}

class _AnimatedUserMarkerLayerState extends State<AnimatedUserMarkerLayer>
    with SingleTickerProviderStateMixin {
  static const double _movingSpeedMps = 1.5;
  static const Duration _compassThrottle = Duration(milliseconds: 100);

  static const Duration _minAnimDuration = Duration(milliseconds: 250);
  static const Duration _maxAnimDuration = Duration(milliseconds: 1200);

  late final AnimationController _controller;
  LatLng? _lastPosition;
  DateTime? _lastPositionTime;
  double? _lastHeading;
  double _accumulatedTurns = 0;
  double? _lastSpeed;
  bool _hasCompass = false;
  double? _compassHeading;
  LatLngTween? _tween;
  Worker? _worker;
  StreamSubscription<CompassEvent>? _compassSub;
  DateTime? _lastCompassUpdate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    final initial = widget.positionRx.value;
    if (initial != null) {
      _lastPosition = LatLng(initial.latitude, initial.longitude);
      _lastPositionTime = DateTime.now();
      _lastSpeed = initial.speed;
    }

    _startCompass();
    _worker = ever<Position?>(widget.positionRx, _onPosition);
  }

  void _startCompass() {
    final events = FlutterCompass.events;
    if (events == null) return;
    _compassSub = events.listen((event) {
      final heading = event.heading;
      if (heading == null) return;
      _hasCompass = true;
      _compassHeading = heading;
      _onCompassHeading(heading);
    }, onError: (Object _) {});
  }

  void _onCompassHeading(double heading) {
    if (_lastSpeed != null && _lastSpeed! > _movingSpeedMps) return;

    final now = DateTime.now();
    if (_lastCompassUpdate != null &&
        now.difference(_lastCompassUpdate!) < _compassThrottle) {
      return;
    }
    _lastCompassUpdate = now;

    _updateHeading(heading);
    if (mounted) setState(() {});
  }

  void _onPosition(Position? newPos) {
    if (newPos == null) return;
    final newLatLng = LatLng(newPos.latitude, newPos.longitude);
    final from = _lastPosition ?? newLatLng;
    _lastSpeed = newPos.speed;

    final now = DateTime.now();
    Duration animDuration = _maxAnimDuration;
    if (_lastPositionTime != null) {
      final elapsed = now.difference(_lastPositionTime!);
      if (elapsed < _minAnimDuration) {
        animDuration = _minAnimDuration;
      } else if (elapsed > _maxAnimDuration) {
        animDuration = _maxAnimDuration;
      } else {
        animDuration = elapsed;
      }
    }
    _lastPositionTime = now;

    final moving = newPos.speed > _movingSpeedMps;
    double? heading;
    if (moving) {
      heading = newPos.heading > 0 ? newPos.heading : null;
      if (heading == null && _lastPosition != null) {
        final bearing = Distance().bearing(_lastPosition!, newLatLng);
        if (bearing.isFinite && bearing > 0) heading = bearing;
      }
    } else if (_hasCompass) {
      heading = _compassHeading;
    }

    if (heading != null) _updateHeading(heading);

    _tween = LatLngTween(begin: from, end: newLatLng);
    _lastPosition = newLatLng;
    _controller.duration = animDuration;

    if (mounted) setState(() {});

    _controller
      ..reset()
      ..forward();
  }

  void _updateHeading(double heading) {
    final prev = _lastHeading;
    _lastHeading = heading;
    if (prev == null) {
      _accumulatedTurns = heading / 360;
    } else {
      var delta = (heading - prev) % 360;
      if (delta > 180) delta -= 360;
      _accumulatedTurns += delta / 360;
    }
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    _worker?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_lastPosition == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final animatedPos = _tween != null
            ? _tween!.evaluate(_controller)
            : _lastPosition!;

        return MarkerLayer(
          markers: [
            Marker(
              point: animatedPos,
              width: 40,
              height: 40,
              child: RepaintBoundary(
                child: UserLocationMarker(
                  turns: _hasCompass ? _accumulatedTurns : null,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
