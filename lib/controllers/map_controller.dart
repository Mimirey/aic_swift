import 'dart:async';
import 'package:Swift/controllers/navigation_controller.dart';
import 'dart:io';
import 'package:Swift/core/utils/location_service.dart';
import 'package:Swift/core/utils/whatsapp_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:Swift/models/optimized_route_model.dart';
import 'package:Swift/models/package/package_model.dart';
import 'package:Swift/services/tracking_service.dart';
import 'package:Swift/services/shipment_service.dart';
import 'package:Swift/models/shipment_model.dart';
import 'package:Swift/services/route_service.dart';
import 'package:Swift/config/routes/route_names.dart';
import 'package:Swift/core/network/api_exception.dart';
import '../components/common/package_map_marker.dart';
import '../core/theme/app_colors.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';

import '../models/next_package_item.dart';

enum TaskSheetStage { collapsed, peek, full }

enum RouteState { empty, assigned, calculating, onRoute, validating }

class _RouteSegment {
  final String packageId;
  final List<LatLng> points;

  _RouteSegment(this.packageId, this.points);
}

class MapPageController extends GetxController
    with GetTickerProviderStateMixin, WidgetsBindingObserver {
  final _sheetController = DraggableScrollableController();
  StreamSubscription<Position>? _positionSub;
  static const double _arrivalThresholdMeters = 50;
  final RxList<_RouteSegment> _routeSegments = <_RouteSegment>[].obs;
  // Reactive state
  final RxList<PackageModel> deliveryQueue = <PackageModel>[].obs;
  final RxList<ShipmentModel> shipments = <ShipmentModel>[].obs;
  final RxBool isLoadingShipments = false.obs;
  final Rx<TaskSheetStage> stage = TaskSheetStage.collapsed.obs;
  final Rx<Position?> currentPosition = Rxn<Position>();
  final Rx<RouteState> routeState = RouteState.empty.obs;
  final RxList<XFile> capturedPhotos = <XFile>[].obs;
  final Rx<OptimizedRouteModel?> optimizedRoute = Rxn<OptimizedRouteModel>();
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final RxBool loadingRoute = false.obs;
  final RxBool showRouteVisuals = false.obs;

  // Services
  final trackingService = TrackingService.instance;
  final shipmentService = ShipmentService.instance;
  final routeService = RouteService.instance;

  // Map controllers
  final mapController = MapController();
  late final AnimatedMapController animatedMapController;

  Position? _lastEmittedPosition;
  DateTime? _lastEmittedTime;
  bool _hasCenteredOnUser = false;

  static const double _vehicleSpeedThresholdKmh = 8.0;
  static const double _vehicleSpeedThresholdMps =
      _vehicleSpeedThresholdKmh / 3.6;

  // Getters
  PackageModel? get currentPackage =>
      deliveryQueue.isNotEmpty ? deliveryQueue.first : null;
  List<PackageModel> get upcomingPackages => deliveryQueue.skip(1).toList();
  List<NextPackageItem> get upcomingPackageItems {
    return upcomingPackages.map((pkg) {
      final index = deliveryQueue.indexOf(pkg);
      return NextPackageItem(
        address: pkg.address,
        distanceLabel: _distanceLabelForIndex(index),
      );
    }).toList();
  }

  TaskSheetStage get currentStage => stage.value;
  RouteState get currentRouteState => routeState.value;
  double get currentSpeedKmh {
    final position = currentPosition.value;
    if (position == null) return 0.0;
    final speed = position.speed < 0 ? 0.0 : position.speed; // m/s
    return speed * 3.6; // konversi ke km/h
  }

  late final NavigationController navController;
  DateTime? _lastNavSentAt;
  static const _navMinInterval = Duration(seconds: 3);

  static const collapsedSize = 0.18;
  static const peekSize = 0.5;
  static const fullSize = 0.85;
  Timer? _interactionTimer;
  final RxBool isUserInteracting = false.obs;

  int? _legIndexForPackage(String packageId) {
    final leg = optimizedRoute.value?.legs.firstWhereOrNull(
      (l) => l.packageId?.toString() == packageId,
    );
    return leg?.legIndex;
  }

  Timer? _refreshTimer;
  static const _refreshInterval = Duration(seconds: 60);
  final AudioPlayer _audioPlayer = AudioPlayer();
  Future<void> _notifyArrival() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
      Vibration.vibrate(
        pattern: [0, 400, 200, 400],
      ); 
    }
    try {
      await _audioPlayer.play(AssetSource('sounds/notification1.mp3'));
    } catch (e) {
      print('ERROR play sound: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    if (!Get.isRegistered<NavigationController>()) {
      Get.put(NavigationController());
    }
    navController = Get.find<NavigationController>();
    animatedMapController = AnimatedMapController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
    mapController.mapEventStream.listen((event) {
      final isUserGesture =
          event.source != MapEventSource.mapController &&
          event.source != MapEventSource.custom;

      if (isUserGesture) {
        isUserInteracting.value = true;
        _interactionTimer?.cancel();
        _interactionTimer = Timer(const Duration(seconds: 3), () {
          isUserInteracting.value = false;
        });
      }
    });
    ever(navController.activePolyline, (encoded) {
      if (encoded == null || currentPackage == null) return;
      try {
        final decoded = PolylinePoints.decodePolyline(encoded);
        final newPoints = decoded
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList();

        if (newPoints.isEmpty) return;

        final activeIndex = _routeSegments.indexWhere(
          (seg) => seg.packageId == currentPackage!.id,
        );

        if (activeIndex != -1) {
          final updatedSegments = List<_RouteSegment>.from(_routeSegments);
          updatedSegments[activeIndex] = _RouteSegment(
            currentPackage!.id,
            newPoints,
          );
          _routeSegments.value = updatedSegments;
        }
        _lastTrimIndex = null;

        // routePoints tetap diupdate buat keperluan lain (fit camera, marker start/end)
        routePoints.value = newPoints;
      } catch (e) {
        print('ERROR decode reroute polyline: $e');
      }
    });
    ever(navController.offRoute, (isOff) {
      if (isOff == true &&
          routeState.value == RouteState.onRoute &&
          !_isRecalculating) {
        recalculateRouteOrder();
      }
    });

    _sheetController.addListener(_onSheetChanged);
    _initSequence();
    _connectTracking();
    _startWatchingArrival();
    _centerOnFirstFix();
    _startAutoRefresh();
  }

  Future<void> _initSequence() async {
    await _loadCurrentLocation();
    await _loadShipments();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionSub?.cancel();
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    animatedMapController.dispose();
    trackingService.disconnect();
    navController.stopNavigation();
    _interactionTimer?.cancel();
    _refreshTimer?.cancel();
    _audioPlayer.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (routeState.value == RouteState.empty ||
          routeState.value == RouteState.assigned) {
        _loadShipments();
      }
    }
  }

  double _dynamicMinDistance(double speedMps) {
    if (speedMps < _vehicleSpeedThresholdMps) {
      return 1.0;
    }
    final scaled = speedMps * 1.5;
    return scaled.clamp(3.0, 15.0);
  }

  Duration _dynamicMaxInterval(double speedMps) {
    if (speedMps < _vehicleSpeedThresholdMps) {
      return const Duration(seconds: 1);
    }
    return const Duration(seconds: 2);
  }

  bool _shouldEmitUpdate(Position newPosition) {
    if (_lastEmittedPosition == null || _lastEmittedTime == null) return true;

    final distance = Distance().as(
      LengthUnit.Meter,
      LatLng(_lastEmittedPosition!.latitude, _lastEmittedPosition!.longitude),
      LatLng(newPosition.latitude, newPosition.longitude),
    );
    final elapsed = DateTime.now().difference(_lastEmittedTime!);

    final speed = newPosition.speed < 0 ? 0.0 : newPosition.speed;

    final minDistance = _dynamicMinDistance(speed);
    final maxInterval = _dynamicMaxInterval(speed);

    return distance >= minDistance || elapsed >= maxInterval;
  }

  void _onSheetChanged() {
    final size = _sheetController.size;
    final newStage = size >= 0.85
        ? TaskSheetStage.full
        : size >= 0.35
        ? TaskSheetStage.peek
        : TaskSheetStage.collapsed;
    if (newStage != stage.value) {
      stage.value = newStage;
    }
  }

  void _updateRouteSegmentsFromQueue() {
    final existingSegments = _routeSegments
        .where((seg) => deliveryQueue.any((pkg) => pkg.id == seg.packageId))
        .toList();
    existingSegments.sort((a, b) {
      final indexA = deliveryQueue.indexWhere((pkg) => pkg.id == a.packageId);
      final indexB = deliveryQueue.indexWhere((pkg) => pkg.id == b.packageId);
      return indexA.compareTo(indexB);
    });

    _routeSegments.value = existingSegments;
  }

  List<Polyline> getRoutePolylines() {
    if (!showRouteVisuals.value || _routeSegments.isEmpty) return [];
    final polylines = <Polyline>[];
    for (final seg in _routeSegments) {
      final index = deliveryQueue.indexWhere((pkg) => pkg.id == seg.packageId);

      double opacity;
      if (index == 0) {
        opacity = 1.0;
      } else if (index == 1) {
        opacity = 0.8;
      } else {
        opacity = 0.5;
      }
      polylines.add(
        Polyline(
          points: seg.points,
          strokeWidth: 6,
          color: AppColors.primaryLight.withOpacity(opacity),
          borderStrokeWidth: 3,
          borderColor: Colors.white.withOpacity(opacity),
        ),
      );
    }
    return polylines;
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      // Cuma refresh kalau lagi ga di tengah proses antar (biar ga ganggu delivery queue yang lagi jalan)
      if (routeState.value == RouteState.empty ||
          routeState.value == RouteState.assigned) {
        _loadShipments();
      }
    });
  }

  String get estimatedArrivalText {
    final remainingS = navController.remainingTimeS.value;
    final remainingM = navController.remainingDistanceM.value;

    final isImplausible =
        remainingS > 0 &&
        remainingM > 0 &&
        (remainingS / (remainingM / 1000)) >
            300; // >300 detik/km ≈ di bawah 12 km/jam

    if (remainingS > 0 && !isImplausible) {
      final minutes = (remainingS / 60).ceil();
      return '$minutes Menit';
    }
    if (currentPackage != null) {
      final activeLeg = optimizedRoute.value?.legs.firstWhereOrNull(
        (l) => l.packageId?.toString() == currentPackage!.id,
      );
      if (activeLeg != null) {
        return '${activeLeg.durationMins.toStringAsFixed(0)} Menit';
      }
    }

    return '-';
  }

  Future<void> _connectTracking() async {
    try {
      await trackingService.connect();
      trackingService.ping();
    } catch (e) {
      print('TRACKING ERROR: $e');
    }
  }

  Future<void> _loadCurrentLocation() async {
    final position = await getCurrentUserLocation();
    if (position != null) {
      currentPosition.value = position;
    }
  }

  void _centerOnFirstFix() {
    ever<Position?>(currentPosition, (position) {
      if (position == null || _hasCenteredOnUser) return;
      _hasCenteredOnUser = true;
      if (isUserInteracting.value) return;
      try {
        animatedMapController.mapController.move(
          LatLng(position.latitude, position.longitude),
          15,
        );
      } catch (e) {
        print('Initial center error: $e');
      }
    });
  }

  Future<void> _loadShipments() async {
    try {
      isLoadingShipments.value = true;
      final loadedShipments = await shipmentService.getShipments();

      final activeShipments = loadedShipments
          .where(
            (s) =>
                s.status != 'delivered' &&
                s.status != 'failed' &&
                s.status != 'returned',
          )
          .toList();

      final packages = activeShipments
          .map(_shipmentToPackage)
          .toList(); // <- ganti
      shipments.value = activeShipments; // <- ganti
      deliveryQueue.value = packages;

      if (packages.isEmpty) {
        routeState.value = RouteState.empty;
      } else {
        routeState.value = RouteState.assigned;
        showRouteVisuals.value = false;
        await _loadOptimizedRoute();
      }
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        Get.offAllNamed(AppRoutes.login);
        return;
      }
      print('LOAD SHIPMENTS ERROR: $e');
    } catch (e) {
      print('LOAD SHIPMENTS ERROR: $e');
    } finally {
      isLoadingShipments.value = false;
    }
  }

  Future<void> recalculateRouteOrder() async {
    if (routeState.value != RouteState.onRoute || _isRecalculating) return;

    _isRecalculating = true;
    try {
      await _loadOptimizedRoute();

      // Sinkronkan ulang leg aktif ke WS navigation session
      if (currentPackage != null) {
        final routeId = optimizedRoute.value?.routeId;
        final legIndex = _legIndexForPackage(currentPackage!.id);
        if (routeId != null &&
            legIndex != null &&
            navController.isNavigating.value) {
          navController.beginNavigation(routeId, legIndex: legIndex);
          navController.offRoute.value = false;
        }
      }

      // Get.snackbar(
      //   'Urutan Diperbarui',
      //   'Rute pengiriman disesuaikan dengan posisimu',
      //   snackPosition: SnackPosition.TOP,
      // );
    } finally {
      _isRecalculating = false;
    }
  }

  PackageModel _shipmentToPackage(ShipmentModel shipment) {
    return PackageModel(
      id: shipment.paket.id.toString(),
      resiNumber: shipment.resi,
      serviceType: shipment.paket.serviceType.toLowerCase() == 'express'
          ? ServiceType.express
          : ServiceType.regular,
      isCod: shipment.cod.is_cod,
      codAmount: shipment.cod.amount,
      customerName: shipment.paket.nama,
      phoneNumber: shipment.paket.nomorTelepon,
      address: shipment.paket.alamat,
      note: null,
      status: _mapShipmentStatus(shipment.status),
      latitude: shipment.paket.latitude,
      longitude: shipment.paket.longitude,
    );
  }

  DeliveryStatus _mapShipmentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return DeliveryStatus.pending;
      case 'picked_up':
        return DeliveryStatus.onTheWay;
      case 'delivered':
        return DeliveryStatus.delivered;
      default:
        return DeliveryStatus.pending;
    }
  }

  Future<void> _loadOptimizedRoute() async {
    if (deliveryQueue.isEmpty || currentPosition.value == null) {
      print('ERROR: Cannot load route - queue empty or position null');
      return;
    }
    loadingRoute.value = true;

    try {
      final route = await routeService.findOptimizedRoute(
        courierLatitude: currentPosition.value!.latitude,
        courierLongitude: currentPosition.value!.longitude,
        packages: deliveryQueue,
        hubLatitude: -6.8048,
        hubLongitude: 110.8385,
      );

      final stopPackageIds = route.stops
          .map((stop) => stop.packageId?.toString())
          .whereType<String>() // filter yang null
          .toList();

      if (stopPackageIds.isNotEmpty) {
        final sortedQueue = <PackageModel>[];
        for (final id in stopPackageIds) {
          final found = deliveryQueue.firstWhereOrNull((pkg) => pkg.id == id);
          if (found != null) {
            sortedQueue.add(found);
          }
        }
        for (final pkg in deliveryQueue) {
          if (!sortedQueue.contains(pkg)) {
            sortedQueue.add(pkg);
          }
        }
        deliveryQueue.value = sortedQueue;
        for (int i = 0; i < deliveryQueue.length; i++) {
        }
      }
      final segments = <_RouteSegment>[];
      for (final leg in route.legs) {
        if (leg.packageId == null) continue;
        final decoded = PolylinePoints.decodePolyline(leg.geometry);
        final pointsLeg = decoded
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList();

        if (pointsLeg.isNotEmpty) {
          segments.add(_RouteSegment(leg.packageId!.toString(), pointsLeg));
        }
      }
      if (segments.isEmpty && route.stops.isNotEmpty) {
        for (final stop in route.stops) {
          if (stop.packageId != null) {
            segments.add(
              _RouteSegment(stop.packageId!.toString(), [
                LatLng(stop.latitude, stop.longitude),
              ]),
            );
          }
        }
      }
      if (segments.isNotEmpty && currentPosition.value != null) {
        final userLatLng = LatLng(
          currentPosition.value!.latitude,
          currentPosition.value!.longitude,
        );
        final firstPoints = segments.first.points;
        if (firstPoints.isNotEmpty) {
          final distance = Distance().as(
            LengthUnit.Meter,
            userLatLng,
            firstPoints.first,
          );
          if (distance > 10) {
            segments[0] = _RouteSegment(segments.first.packageId, [
              userLatLng,
              ...firstPoints,
            ]);
          }
        }
      }
      _lastTrimIndex = null;
      _routeSegments.value = segments;

      final points = _decodeRoute(route);
      if (currentPosition.value != null && points.isNotEmpty) {
        final userLatLng = LatLng(
          currentPosition.value!.latitude,
          currentPosition.value!.longitude,
        );
        final distance = Distance().as(
          LengthUnit.Meter,
          userLatLng,
          points.first,
        );
        if (distance > 10) {
          points.insert(0, userLatLng);
        }
      }

      optimizedRoute.value = route;
      routePoints.value = points;
      loadingRoute.value = false;

      if (points.isNotEmpty) {
        print('Fitting map to route...');
        _fitMapToRoute(points);
      } else {
        print('WARNING: No route points to fit');
      }
    } on ApiException catch (e) {
      loadingRoute.value = false;
      if (e.statusCode == 401) {
        Get.offAllNamed(AppRoutes.login);
        return;
      }
      Get.snackbar(
        'Error',
        'Gagal mengambil rute: ${e.message}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('ERROR loading route: $e');
      loadingRoute.value = false;
      Get.snackbar(
        'Error',
        'Gagal mengambil rute: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  int? _lastTrimIndex;
  // DateTime? _driftStartTime;
  // static const _driftDistanceThreshold = 150.0;
  // static const _driftDurationThreshold = Duration(seconds: 20);
  bool _isRecalculating = false;

  // void _checkForRouteDrift(LatLng userPos) {
  //   if (currentPackage == null || deliveryQueue.length < 2 || _isRecalculating)
  //     return;

  //   final distanceToCurrent = Distance().as(
  //     LengthUnit.Meter,
  //     userPos,
  //     LatLng(currentPackage!.latitude, currentPackage!.longitude),
  //   );

  //   final closerPackage = deliveryQueue.skip(1).firstWhereOrNull((pkg) {
  //     final d = Distance().as(
  //       LengthUnit.Meter,
  //       userPos,
  //       LatLng(pkg.latitude, pkg.longitude),
  //     );
  //     return d < distanceToCurrent - _driftDistanceThreshold;
  //   });

  //   if (closerPackage == null) {
  //     _driftStartTime = null;
  //     return;
  //   }

  //   if (navController.offRoute.value) {
  //     print('DEBUG: off_route BE + closer package -> trigger langsung');
  //     _driftStartTime = null;
  //     recalculateRouteOrder();
  //     return;
  //   }

  //   _driftStartTime ??= DateTime.now();
  //   final driftDuration = DateTime.now().difference(_driftStartTime!);
  //   if (driftDuration >= _driftDurationThreshold) {
  //     _driftStartTime = null;
  //     recalculateRouteOrder();
  //   }
  // }

  void _trimRouteToPosition(LatLng userPosition) {
    if (_routeSegments.isEmpty || currentPackage == null) return;

    final activeIndex = _routeSegments.indexWhere(
      (seg) => seg.packageId == currentPackage!.id,
    );
    if (activeIndex == -1) return;

    final segment = _routeSegments[activeIndex];
    final points = segment.points;
    if (points.length < 2) return;

    final distanceCalc = Distance();
    final searchStart = _lastTrimIndex ?? 0;
    const searchWindow =
        30; // maksimal maju 30 titik per update, sesuaikan kalau perlu

    int closestIndex = searchStart;
    double closestDistance = double.infinity;

    final searchEnd = (searchStart + searchWindow).clamp(0, points.length - 1);
    for (int i = searchStart; i <= searchEnd; i++) {
      final d = distanceCalc.as(LengthUnit.Meter, userPosition, points[i]);
      if (d < closestDistance) {
        closestDistance = d;
        closestIndex = i;
      }
    }

    if (closestDistance > 100) return;

    _lastTrimIndex = closestIndex;

    final trimmedPoints = [userPosition, ...points.sublist(closestIndex)];

    final updatedSegments = List<_RouteSegment>.from(_routeSegments);
    updatedSegments[activeIndex] = _RouteSegment(
      segment.packageId,
      trimmedPoints,
    );
    _routeSegments.value = updatedSegments;
  }

  String _distanceLabelForIndex(int index) {
    // Coba ambil jarak asli dari hasil optimasi rute (jarak jalan, bukan garis lurus)
    final legs = optimizedRoute.value?.legs;
    if (legs != null) {
      // index di sini relatif ke deliveryQueue, cari leg yang packageId-nya cocok
      final packageId = deliveryQueue[index].id;
      final leg = legs.firstWhereOrNull(
        (l) => l.packageId?.toString() == packageId,
      );
      if (leg != null) {
        return _formatDistance(leg.distanceKm * 1000); // distanceKm -> meter
      }
    }

    // Fallback: hitung garis lurus antar titik kalau data leg ga ketemu
    final from = index == 0
        ? currentPosition.value != null
              ? LatLng(
                  currentPosition.value!.latitude,
                  currentPosition.value!.longitude,
                )
              : null
        : LatLng(
            deliveryQueue[index - 1].latitude,
            deliveryQueue[index - 1].longitude,
          );

    if (from == null) return '-';

    final to = LatLng(
      deliveryQueue[index].latitude,
      deliveryQueue[index].longitude,
    );
    final meters = Distance().as(LengthUnit.Meter, from, to);
    return _formatDistance(meters);
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.toStringAsFixed(0)} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  List<LatLng> _decodeRoute(OptimizedRouteModel route) {
    final List<LatLng> points = [];
    for (final stop in route.stops) {
    }
    for (int i = 0; i < route.legs.length; i++) {
      final leg = route.legs[i];
      if (leg.packageId == null) {
        continue;
      }
      if (leg.geometry.isEmpty) {
        final stop = route.stops.cast<RouteStopModel?>().firstWhere(
          (stop) => stop?.packageId == leg.packageId,
          orElse: () => null,
        );
        if (stop != null) {
          points.add(LatLng(stop.latitude, stop.longitude));
        }
        continue;
      }

      try {
        final decoded = PolylinePoints.decodePolyline(leg.geometry);
        for (final point in decoded) {
          if (point.latitude == 0 && point.longitude == 0) {
            continue;
          }
          if (point.latitude < -90 ||
              point.latitude > 90 ||
              point.longitude < -180 ||
              point.longitude > 180) {
            continue;
          }
          points.add(LatLng(point.latitude, point.longitude));
        }
      } catch (e) {
        print('ERROR decoding geometry: $e');

        final stop = route.stops.cast<RouteStopModel?>().firstWhere(
          (stop) => stop?.packageId == leg.packageId,
          orElse: () => null,
        );
        if (stop != null) {
          points.add(LatLng(stop.latitude, stop.longitude));
        }
      }
    }
    if (points.isEmpty && route.stops.isNotEmpty) {
      print('No points from legs, using stops...');
      for (final stop in route.stops) {
        points.add(LatLng(stop.latitude, stop.longitude));
      }
    }
    return points;
  }

  void _fitMapToRoute(List<LatLng> points) {
    if (points.isEmpty) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLon = points.first.longitude;
    double maxLon = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLon) minLon = point.longitude;
      if (point.longitude > maxLon) maxLon = point.longitude;
    }

    final centerLat = (minLat + maxLat) / 2;
    final centerLon = (minLon + maxLon) / 2;

    final latDiff = maxLat - minLat;
    final lonDiff = maxLon - minLon;
    final maxDiff = latDiff > lonDiff ? latDiff : lonDiff;

    double zoom = 15;
    if (maxDiff > 0.5)
      zoom = 10;
    else if (maxDiff > 0.2)
      zoom = 11;
    else if (maxDiff > 0.1)
      zoom = 12;
    else if (maxDiff > 0.05)
      zoom = 13;
    else if (maxDiff > 0.01)
      zoom = 14;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (routeState.value == RouteState.onRoute ||
          routeState.value == RouteState.calculating) {
        animatedMapController.animateTo(
          dest: LatLng(centerLat, centerLon),
          zoom: zoom,
        );
      }
    });
  }

  List<LatLng> _filterOutlierPoints(List<LatLng> points) {
    if (points.length < 3) return points;

    final filtered = <LatLng>[points.first];

    for (int i = 1; i < points.length - 1; i++) {
      final prev = filtered.last;
      final curr = points[i];
      final next = points[i + 1];

      final dist1 = Distance().as(LengthUnit.Meter, prev, curr);
      final dist2 = Distance().as(LengthUnit.Meter, curr, next);

      if (dist1 > 100000 || dist2 > 100000) {
        print('SKIP outlier point: $curr (dist1: $dist1, dist2: $dist2)');
        continue;
      }

      filtered.add(curr);
    }

    filtered.add(points.last);
    return filtered;
  }

  void startRoute() async {
    routeState.value = RouteState.calculating;
    Get.toNamed(AppRoutes.mapCalculating);
    await _loadOptimizedRoute();
    

    if (routePoints.isEmpty) {
      routeState.value = RouteState.assigned;
      return;
    }

    await _markAllAsPickedUp();
    showRouteVisuals.value = true;
    routeState.value = RouteState.onRoute;
    _startWatchingArrival();

    final routeId = optimizedRoute.value?.routeId;
    print('DEBUG: routeId dari HTTP response = $routeId');
    if (routeId != null) {
      final connected = await navController.connect();
      if (connected) {
        navController.beginNavigation(routeId);
      } else {
        print('NAV: gagal connect ke navigation service');
      }
    }

    Get.back();
  }

  void _startWatchingArrival() {
    _positionSub?.cancel();

    final locationSettings = Platform.isAndroid
        ? AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
            intervalDuration: const Duration(seconds: 1),
          )
        : AppleSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
            activityType: ActivityType.fitness,
            pauseLocationUpdatesAutomatically: false,
          );

    _positionSub =
        Geolocator.getPositionStream(
          locationSettings: locationSettings,
        ).listen((position) {
          currentPosition.value = position;

          if (!_shouldEmitUpdate(position)) return;
          _lastEmittedPosition = position;
          _lastEmittedTime = DateTime.now();

          // if (!isUserInteracting.value &&
          //     routeState.value == RouteState.onRoute) {
          //   try {
          //     final currentZoom =
          //         animatedMapController.mapController.camera.zoom;
          //     animatedMapController.animateTo(
          //       dest: LatLng(position.latitude, position.longitude),
          //       zoom: currentZoom,
          //     );
          //   } catch (e) {
          //     print('Auto-follow error: $e');
          //   }
          // }

          if (position.accuracy > 20) return;
          if (routeState.value != RouteState.onRoute) return;
          _trimRouteToPosition(LatLng(position.latitude, position.longitude));
          // _checkForRouteDrift(LatLng(position.latitude, position.longitude));
          trackingService.sendPosition(
            lat: position.latitude,
            lon: position.longitude,
            bearing: position.heading,
            speed: position.speed,
          );

          final routeId = optimizedRoute.value?.routeId;
          if (navController.isNavigating.value && routeId != null) {
            final now = DateTime.now();
            if (_lastNavSentAt == null ||
                now.difference(_lastNavSentAt!) >= _navMinInterval) {
              _lastNavSentAt = now;
              navController.sendLocationUpdate(
                lat: position.latitude,
                lng: position.longitude,
                bearing: position.heading,
                speed: position.speed,
                currentRouteId: routeId,
              );
            }
          }

          final distance = distanceToTargetInMeters(
            position,
            currentPackage!.latitude,
            currentPackage!.longitude,
          );

          if (distance <= _arrivalThresholdMeters) {
            routeState.value = RouteState.validating;
            _notifyArrival();
          }
        });
  }

  Future<void> _markAllAsPickedUp() async {
    for (final pkg in deliveryQueue) {
      final shipment = shipments.firstWhereOrNull(
        (s) => s.paket.id.toString() == pkg.id,
      );
      if (shipment == null) continue;

      // Skip kalau udah bukan 'assigned' (misal abis di-refresh ulang / retry)
      if (shipment.status != 'assigned') continue;

      try {
        await shipmentService.updateShipmentStatus(
          shipmentId: shipment.shipmentId,
          status: 'picked_up',
        );
      } catch (e) {
        print('ERROR set picked_up untuk shipment ${shipment.shipmentId}: $e');
      }
    }
  }

  Future<void> handleCapturePhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (photo == null) return;
    capturedPhotos.add(photo);
  }

  void handleConfirmPackage() async {
    if (currentPackage == null) return;

    if (capturedPhotos.isEmpty) {
      Get.snackbar(
        'Foto Wajib Diisi',
        'Ambil foto bukti pengiriman dulu sebelum konfirmasi',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: AppColors.textPrimary,
        icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
      );
      return;
    }

    final confirmedPackage = currentPackage!;
    final shipment = shipments.firstWhereOrNull(
      (s) => s.paket.id.toString() == confirmedPackage.id,
    );

    if (shipment != null) {
      try {
        await shipmentService.updateShipmentStatus(
          shipmentId: shipment.shipmentId,
          status: 'delivered',
        );
      } on ApiException catch (e) {
        Get.snackbar('Error', 'Gagal update status: ${e.message}');
        return;
      } catch (e) {
        print('ERROR update status: $e');
        Get.snackbar('Error', 'Gagal update status paket');
        return;
      }
    }

    deliveryQueue.removeAt(0);
    _updateRouteSegmentsFromQueue();
    _lastTrimIndex = null;
    // _driftStartTime = null;
    capturedPhotos.clear();
    routeState.value = deliveryQueue.isEmpty
        ? RouteState.empty
        : RouteState.onRoute;
    await _refreshShipmentStatuses();
    if (currentPackage != null) {
      final routeId = optimizedRoute.value?.routeId;
      final legIndex = _legIndexForPackage(currentPackage!.id);
      if (routeId != null &&
          legIndex != null &&
          navController.isNavigating.value) {
        navController.beginNavigation(routeId, legIndex: legIndex);
      }
    }
  }

  Future<void> _refreshShipmentStatuses() async {
    try {
      final refreshed = await shipmentService.getShipments();
      shipments.value = refreshed
          .where(
            (s) =>
                s.status != 'delivered' &&
                s.status != 'failed' &&
                s.status != 'returned',
          )
          .toList();
    } catch (e) {
      print('ERROR refresh shipments setelah update status: $e');
    }
  }

  Future<void> handleRelocate() async {
    final position = await getCurrentUserLocation();
    if (position == null) return;

    animatedMapController.animateTo(
      dest: LatLng(position.latitude, position.longitude),
      zoom: 16,
    );
  }

  void handleWhatsApp() {
    if (currentPackage != null) {
      openWhatsApp(currentPackage!.phoneNumber);
    }
  }

  String formatCurrency(double amount) {
    final str = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final posFromRight = str.length - i;
      buffer.write(str[i]);
      if (posFromRight > 1 && posFromRight % 3 == 1) buffer.write('.');
    }
    return 'Rp $buffer';
  }

  List<Marker> buildPackageMarkers() {
    final packageMarkers = deliveryQueue.map((pkg) {
      final isActive =
          showRouteVisuals.value &&
          currentPackage != null &&
          pkg.id == currentPackage!.id;
      final size = isActive ? 40.0 : 26.0;
      final height = size * 1.25;
      return Marker(
        point: LatLng(pkg.latitude, pkg.longitude),
        width: size,
        height: height,
        alignment: Alignment.topCenter,
        child: PackageMapMarker(isActive: isActive),
      );
    }).toList();

    // if (showRouteVisuals.value) {
    // final activeSegment = currentPackage != null
    //     ? _routeSegments.firstWhereOrNull(
    //         (seg) => seg.packageId == currentPackage!.id,
    //       )
    //     : null;

    // if (activeSegment != null && activeSegment.points.isNotEmpty) {
    //   packageMarkers.add(
    //     Marker(
    //       point: activeSegment.points.first,
    //       width: 25,
    //       height: 25,
    //       child: Container(
    //         decoration: BoxDecoration(
    //           color: Colors.green,
    //           shape: BoxShape.circle,
    //           border: Border.all(color: Colors.white, width: 2),
    //         ),
    //         child: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
    //       ),
    //     ),
    //   );

    //   packageMarkers.add(
    //     Marker(
    //       point: activeSegment.points.last,
    //       width: 25,
    //       height: 25,
    //       child: Container(
    //         decoration: BoxDecoration(
    //           color: Colors.red,
    //           shape: BoxShape.circle,
    //           border: Border.all(color: Colors.white, width: 2),
    //         ),
    //         child: const Icon(Icons.stop, color: Colors.white, size: 18),
    //       ),
    //     ),
    //   );
    // }
    // }

    return packageMarkers;
  }

  DraggableScrollableController get sheetController => _sheetController;
}
