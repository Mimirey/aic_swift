import 'package:Swift/models/package/package_model.dart';
import 'package:Swift/models/shipment_model.dart';

class ShipmentMapper {
  static PackageModel toPackage(ShipmentModel shipment) {
    final paket = shipment.paket;

    return PackageModel(
      id: shipment.shipmentId.toString(),
      resiNumber: shipment.resi,

      serviceType: paket.serviceType.toUpperCase() == 'EXPRESS'
          ? ServiceType.express
          : ServiceType.regular,

      isCod: shipment.cod.amount > 0,
      codAmount: shipment.cod.amount,

      customerName: paket.nama,
      phoneNumber: paket.nomorTelepon,
      address: paket.alamat,

      note: null,

      status: _mapStatus(shipment.status),

      latitude: paket.latitude,
      longitude: paket.longitude,
    );
  }

  static DeliveryStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return DeliveryStatus.delivered;

      case 'on_the_way':
        return DeliveryStatus.onTheWay;

      case 'failed':
        return DeliveryStatus.failed;

      case 'assigned':
      default:
        return DeliveryStatus.pending;
    }
  }
}