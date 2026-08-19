class OptimizedRouteModel {
  final String status;
  final double totalDistanceKm;
  final double totalDurationMins;
  final int totalLegs;
  final List<RouteStopModel> stops;
  final List<RouteLegModel> legs;
  final String source;
  final String? warning;
  final String? routeId;

  OptimizedRouteModel({
    required this.status,
    required this.totalDistanceKm,
    required this.totalDurationMins,
    required this.totalLegs,
    required this.stops,
    required this.legs,
    required this.source,
    required this.warning,
    required this.routeId,
  });

  factory OptimizedRouteModel.fromJson(Map<String, dynamic> json) {
    return OptimizedRouteModel(
      status: json['status'] as String? ?? '',
      totalDistanceKm:
          (json['total_distance_km'] as num?)?.toDouble() ?? 0.0,
      totalDurationMins:
          (json['total_duration_mins'] as num?)?.toDouble() ?? 0.0,
      totalLegs: json['total_legs'] as int? ?? 0,

      stops: (json['stops'] as List? ?? [])
          .map(
            (item) => RouteStopModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),

      legs: (json['legs'] as List? ?? [])
          .map(
            (item) => RouteLegModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),

      source: json['source'] as String? ?? '',
      warning: json['warning'] as String?,
      routeId: json['route_id']?.toString(),
    );
  }
}

class RouteStopModel {
  final int stopOrder;
  final int? packageId;
  final String recipientName;
  final String serviceType;
  final double latitude;
  final double longitude;

  RouteStopModel({
    required this.stopOrder,
    required this.packageId,
    required this.recipientName,
    required this.serviceType,
    required this.latitude,
    required this.longitude,
  });

  factory RouteStopModel.fromJson(Map<String, dynamic> json) {
    return RouteStopModel(
      stopOrder: json['stop_order'] as int? ?? 0,
      packageId: json['package_id'] as int?,
      recipientName: json['recipient_name'] as String? ?? '',
      serviceType: json['service_type'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RouteLegModel {
  final int legIndex;
  final int stopSequenceNumber;
  final int? packageId;
  final String recipientName;
  final String serviceType;
  final String geometry;
  final double distanceKm;
  final double durationMins;

  RouteLegModel({
    required this.legIndex,
    required this.stopSequenceNumber,
    required this.packageId,
    required this.recipientName,
    required this.serviceType,
    required this.geometry,
    required this.distanceKm,
    required this.durationMins,
  });

  factory RouteLegModel.fromJson(Map<String, dynamic> json) {
    return RouteLegModel(
      legIndex: json['leg_index'] as int? ?? 0,
      stopSequenceNumber:
          json['stop_sequence_number'] as int? ?? 0,
      packageId: json['package_id'] as int?,
      recipientName: json['recipient_name'] as String? ?? '',
      serviceType: json['service_type'] as String? ?? '',
      geometry: json['geometry'] as String? ?? '',
      distanceKm:
          (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      durationMins:
          (json['duration_mins'] as num?)?.toDouble() ?? 0.0,
    );
  }
}