import 'dart:async';
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
import '../components/common/user_location_marker.dart';

enum TaskSheetStage { collapsed, peek, full }

enum RouteState { empty, assigned, calculating, onRoute, validating }

class MapPageController extends GetxController
    with GetTickerProviderStateMixin {
  final _sheetController = DraggableScrollableController();
  StreamSubscription<Position>? _positionSub;
  static const double _arrivalThresholdMeters = 50;

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

  // Services
  final trackingService = TrackingService.instance;
  final shipmentService = ShipmentService.instance;
  final routeService = RouteService.instance;

  // Map controllers
  final mapController = MapController();
  late final AnimatedMapController animatedMapController;

  // Getters
  PackageModel? get currentPackage =>
      deliveryQueue.isNotEmpty ? deliveryQueue.first : null;
  List<PackageModel> get upcomingPackages => deliveryQueue.skip(1).toList();
  TaskSheetStage get currentStage => stage.value;
  RouteState get currentRouteState => routeState.value;

  static const collapsedSize = 0.18;
  static const peekSize = 0.5;
  static const fullSize = 0.85;

  final RxBool isUserInteracting = false.obs;

  @override
  void onInit() {
    super.onInit();
    animatedMapController = AnimatedMapController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
    mapController.mapEventStream.listen((event) {
      if (event is MapEventMoveStart) {
        isUserInteracting.value = true; // User mulai geser/zoom
      } else if (event is MapEventMoveEnd) {
        isUserInteracting.value = false; // User selesai geser/zoom
      }
    });

    _sheetController.addListener(_onSheetChanged);
    _loadCurrentLocation();
    _connectTracking();
    _loadShipments();
    _startWatchingArrival();
  }

  @override
  void onClose() {
    _positionSub?.cancel();
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    animatedMapController.dispose();
    trackingService.disconnect();
    super.onClose();
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

  Future<void> _loadShipments() async {
    try {
      isLoadingShipments.value = true;
      final loadedShipments = await shipmentService.getShipments();
      final packages = loadedShipments.map(_shipmentToPackage).toList();

      shipments.value = loadedShipments;
      deliveryQueue.value = packages;

      if (packages.isEmpty) {
        routeState.value = RouteState.empty;
      } else {
        routeState.value = RouteState.assigned;
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

  PackageModel _shipmentToPackage(ShipmentModel shipment) {
    return PackageModel(
      id: shipment.paket.id.toString(),
      resiNumber: shipment.resi,
      serviceType: shipment.paket.serviceType.toLowerCase() == 'express'
          ? ServiceType.express
          : ServiceType.regular,
      isCod: shipment.cod.status != 'pending' || shipment.cod.amount > 0,
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
      print('=== LOADING OPTIMIZED ROUTE ===');
      print(
        'Courier position: ${currentPosition.value!.latitude}, ${currentPosition.value!.longitude}',
      );
      print('Packages to deliver: ${deliveryQueue.length}');

      final route = await routeService.findOptimizedRoute(
        courierLatitude: currentPosition.value!.latitude,
        courierLongitude: currentPosition.value!.longitude,
        packages: deliveryQueue,
        hubLatitude: -6.8048,
        hubLongitude: 110.8385,
      );

      print('Route received:');
      print('  Status: ${route.status}');
      print('  Total legs: ${route.totalLegs}');
      print('  Total stops: ${route.stops.length}');
      print('  Total distance: ${route.totalDistanceKm} km');
      print('  Total duration: ${route.totalDurationMins} mins');

      final points = _decodeRoute(route);

      optimizedRoute.value = route;
      routePoints.value = points;
      loadingRoute.value = false;

      // Auto-fit map ke route
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

  List<LatLng> _decodeRoute(OptimizedRouteModel route) {
    final List<LatLng> points = [];

    print('=== DECODE ROUTE DEBUG ===');
    print('Route status: ${route.status}');
    print('Total legs: ${route.totalLegs}');
    print('Legs count: ${route.legs.length}');
    print('Stops count: ${route.stops.length}');

    // Print semua stops untuk verifikasi
    print('Stops:');
    for (final stop in route.stops) {
      print(
        '  Stop ${stop.stopOrder}: ${stop.recipientName} at ${stop.latitude}, ${stop.longitude}',
      );
    }
    // Decode geometry dari setiap leg
    for (int i = 0; i < route.legs.length; i++) {
      final leg = route.legs[i];
      if (leg.packageId == null) {
        continue;
      }

      print('Leg ${leg.legIndex}:');
      print('  Package ID: ${leg.packageId}');
      print('  Package: ${leg.recipientName}');
      print('  Geometry length: ${leg.geometry.length}');
      print('  Distance: ${leg.distanceKm} km');

      if (leg.geometry.isEmpty) {
        // Cari stop berdasarkan packageId, bukan berdasarkan index.
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

        if (decoded.isNotEmpty) {
          print(
            '  Leg start: '
            '${decoded.first.latitude}, '
            '${decoded.first.longitude}',
          );
          print(
            '  Leg end: '
            '${decoded.last.latitude}, '
            '${decoded.last.longitude}',
          );
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
    // Jika tidak ada points dari legs, gunakan stops
    if (points.isEmpty && route.stops.isNotEmpty) {
      print('No points from legs, using stops...');
      for (final stop in route.stops) {
        points.add(LatLng(stop.latitude, stop.longitude));
        print('  Stop point: ${stop.latitude}, ${stop.longitude}');
      }
    }
    print('Total decoded points: ${points.length}');
    if (points.isNotEmpty) {
      print(
        'Overall start: ${points.first.latitude}, ${points.first.longitude}',
      );
      print('Overall end: ${points.last.latitude}, ${points.last.longitude}');
    }
    print('=== END DECODE ROUTE DEBUG ===');
    return points;
  }

  void _fitMapToRoute(List<LatLng> points) {
    if (points.isEmpty) return;

    // Hitung bounds
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

    // Hitung zoom level
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

    print('=== FIT MAP ===');
    print('Bounds: $minLat, $minLon to $maxLat, $maxLon');
    print('Center: $centerLat, $centerLon');
    print('Zoom: $zoom');
    print('=== END FIT ===');

    // Animate ke center route
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

      // Hitung jarak antar titik
      final dist1 = Distance().as(LengthUnit.Meter, prev, curr);
      final dist2 = Distance().as(LengthUnit.Meter, curr, next);

      // Jika jarak terlalu jauh (> 100km), skip titik ini
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
    await _loadOptimizedRoute();

    if (routePoints.isEmpty) {
      routeState.value = RouteState.assigned;
      return;
    }

    routeState.value = RouteState.onRoute;
    _startWatchingArrival();
  }

  void _startWatchingArrival() {
    _positionSub?.cancel();
    _positionSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 1,
            // timeLimit: Duration(seconds: 2),
          ),
        ).listen((position) {
          currentPosition.value = position;
          if (position.accuracy > 20) {
            return;
          }
          if (routeState.value != RouteState.onRoute) {
            return;
          }
          trackingService.sendPosition(
            lat: position.latitude,
            lon: position.longitude,
            bearing: position.heading,
            speed: position.speed,
          );

          final distance = distanceToTargetInMeters(
            position,
            currentPackage!.latitude,
            currentPackage!.longitude,
          );

          if (distance <= _arrivalThresholdMeters) {
            routeState.value = RouteState.validating;
            _positionSub?.cancel();
          }
        });
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

  void handleConfirmPackage() {
    if (currentPackage == null) return;

    deliveryQueue.removeAt(0);
    capturedPhotos.clear();
    routeState.value = deliveryQueue.isEmpty
        ? RouteState.empty
        : RouteState.onRoute;
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

  List<Marker> buildMarkers() {
    final packageMarkers = deliveryQueue.map((pkg) {
      final isActive = currentPackage != null && pkg.id == currentPackage!.id;

      return Marker(
        point: LatLng(pkg.latitude, pkg.longitude),
        width: isActive ? 34 : 16,
        height: isActive ? 34 : 16,
        child: PackageMapMarker(isActive: isActive),
      );
    }).toList();

    if (currentPosition.value != null) {
      packageMarkers.add(
        Marker(
          point: LatLng(
            currentPosition.value!.latitude,
            currentPosition.value!.longitude,
          ),
          width: 40,
          height: 40,
          child: const UserLocationMarker(),
        ),
      );
    }

    // Debug: Tambahkan marker untuk titik awal dan akhir route
    if (routePoints.isNotEmpty) {
      // Marker titik awal route (hijau)
      packageMarkers.add(
        Marker(
          point: routePoints.first,
          width: 25,
          height: 25,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
          ),
        ),
      );

      // Marker titik akhir route (merah)
      packageMarkers.add(
        Marker(
          point: routePoints.last,
          width: 25,
          height: 25,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.stop, color: Colors.white, size: 18),
          ),
        ),
      );
    }

    return packageMarkers;
  }

  DraggableScrollableController get sheetController => _sheetController;
}


