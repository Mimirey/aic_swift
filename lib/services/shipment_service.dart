import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';
import '../models/shipment_model.dart';

class ShipmentService {
  ShipmentService._();
  static final ShipmentService instance = ShipmentService._();

  Future<List<ShipmentModel>> getShipments() async {
    final response = await ApiClient.instance.get(
      ApiConstants.shipments,
      withAuth: true,
    );

    final data = response['data'] as List;

    return data
        .map((item) => ShipmentModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateShipmentStatus({
    required int shipmentId,
    required String status,
  }) async {
    await ApiClient.instance.patch(
      '${ApiConstants.shipments}/$shipmentId/status',
      body: {'status': status},
      withAuth: true,
    );
  }
}
