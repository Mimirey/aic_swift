import 'package:Swift/models/optimized_route_model.dart';

import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';
import '../models/package/package_model.dart';

class RouteService {
  RouteService._();

  static final RouteService instance = RouteService._();

  Future<OptimizedRouteModel> findOptimizedRoute({
    required double courierLatitude,
    required double courierLongitude,
    required List<PackageModel> packages,
    required double hubLatitude,
    required double hubLongitude,
  }) async {
    final deliveries = packages.map((pkg) {
      return {
        'package_id': int.parse(pkg.id),
        'recipient_name': pkg.customerName,
        'alamat': pkg.address,
        'latitude': pkg.latitude,
        'longitude': pkg.longitude,
        'service_type':
            pkg.serviceType == ServiceType.express
                ? 'EXPRESS'
                : 'REGULAR',
      };
    }).toList();

    final body = {
      'courier_position': {
        'latitude': courierLatitude,
        'longitude': courierLongitude,
      },
      'deliveries': deliveries,
      'hub_origin': {
        'latitude': hubLatitude,
        'longitude': hubLongitude,
      },
      'mode': 'motorcycle',
      'last_mile_precision': true,
      'dynamic_rerouting': true,
      'skip_traffic': true,
      'return_to_hub': true,
    };

    final json = await ApiClient.instance.post(
      ApiConstants.optimizedRoute,
      body: body,
      withAuth: true,
    );

    return OptimizedRouteModel.fromJson(json);
  }
}