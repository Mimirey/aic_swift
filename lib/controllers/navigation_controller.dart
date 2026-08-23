import 'dart:async';
import 'dart:developer' as developer;

import 'package:Swift/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  final NavigationService _navService = NavigationService.instance;
  StreamSubscription? _messageSub;

  final RxBool isConnected = false.obs;
  final RxBool isNavigating = false.obs;
  final RxnInt currentRouteId = RxnInt();

  final RxDouble remainingDistanceM = 0.0.obs;
  final RxDouble remainingTimeS = 0.0.obs;
  final RxDouble progressPct = 0.0.obs;

  final RxBool offRoute = false.obs;
  final RxnString activePolyline = RxnString();

  Future<bool> connect() async {
    final ok = await _navService.connect();
    isConnected.value = ok;
    if (ok) {
      _messageSub = _navService.messages.listen(_handleMessage);
    }

    return ok;
  }

  void _handleMessage(Map<String, dynamic> msg) {
    final type = msg['type'] as String?;
    switch (type) {
      case 'ack':
        if (msg.containsKey('polyline')) {
          activePolyline.value = msg['polyline'] as String?;
        }
        break;

      case 'route_progress':
        remainingDistanceM.value = (msg['remaining_distance_m'] as num)
            .toDouble();
        remainingTimeS.value = (msg['remaining_time_s'] as num).toDouble();
        progressPct.value = (msg['progress_pct'] as num).toDouble();
        offRoute.value = false;
        break;

      case 'off_route_warning':
        offRoute.value = true;
        final distance = (msg['distance_m'] as num).toDouble();
        Get.snackbar(
          'Keluar Jalur',
          'Kamu ${distance.toStringAsFixed(0)}m dari rute',
          snackPosition: SnackPosition.TOP,
        );
        break;

      case 'auto_rerouted':
        offRoute.value = false;
        activePolyline.value = msg['polyline'] as String?;
        Get.snackbar(
          'Rute Diperbarui',
          'Rute otomatis diperbarui',
          snackPosition: SnackPosition.TOP,
        );
        break;

      case 'reroute_available':
        final savingS = (msg['saving_s'] as num?)?.toDouble() ?? 0;
        Get.snackbar(
          'Rute Lebih Cepat Tersedia',
          'Hemat ${savingS.toStringAsFixed(0)} detik',
          mainButton: TextButton(
            onPressed: () => activePolyline.value = msg['polyline'] as String?,
            child: const Text('Pakai', style: TextStyle(color: Colors.white)),
          ),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 8),
        );
        break;

      default:
        print('Unknown message type: $type');
    }
  }

  void beginNavigation(int routeId, {int legIndex = 0}) {
  developer.log('beginNavigation dipanggil dengan routeId=$routeId', name: 'NavController'); // tambahan
  currentRouteId.value = routeId;
  _navService.startNavigation(routeId: routeId, legIndex: legIndex);
  isNavigating.value = true;
}

  void sendLocationUpdate({
    required double lat,
    required double lng,
    required double bearing,
    required double speed,
    required int currentRouteId,
  }) {
    if (!isNavigating.value) return;
    _navService.sendLocationUpdate(
      lat: lat,
      lng: lng,
      bearing: bearing,
      speed: speed,
      currentRouteId: currentRouteId,
    );
  }

  void stopNavigation() {
    isNavigating.value = false;
    _navService.disconnect();
    isConnected.value = false;
  }

  @override
  void onClose() {
    _messageSub?.cancel();
    _navService.disconnect();
    super.onClose();
  }
}
