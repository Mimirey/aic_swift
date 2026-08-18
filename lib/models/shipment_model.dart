class ShipmentModel {
  final int shipmentId;
  final String resi;
  final PackageInfoModel paket;
  final String status;
  final CodModel cod;
  final BillingModel billing;
  final String? pickedUpAt;
  final String? deliveredAt;
  final String batchNo;
  final int kurirId;

  ShipmentModel({
    required this.shipmentId,
    required this.resi,
    required this.paket,
    required this.status,
    required this.cod,
    required this.billing,
    required this.pickedUpAt,
    required this.deliveredAt,
    required this.batchNo,
    required this.kurirId,
  });

  factory ShipmentModel.fromJson(Map<String, dynamic> json) {
    return ShipmentModel(
      shipmentId: json['shipment_id'],
      resi: json['resi'],
      paket: PackageInfoModel.fromJson(json['paket']),
      status: json['status'],
      cod: CodModel.fromJson(json['cod']),
      billing: BillingModel.fromJson(json['billing']),
      pickedUpAt: json['picked_up_at'],
      deliveredAt: json['delivered_at'],
      batchNo: json['batch_no'],
      kurirId: json['kurir_id'],
    );
  }
}

class PackageInfoModel {
  final int id;
  final String nama;
  final String nomorTelepon;
  final String alamat;
  final double latitude;
  final double longitude;
  final String jenisPengiriman;
  final String serviceType;

  PackageInfoModel({
    required this.id,
    required this.nama,
    required this.nomorTelepon,
    required this.alamat,
    required this.latitude,
    required this.longitude,
    required this.jenisPengiriman,
    required this.serviceType,
  });

  factory PackageInfoModel.fromJson(Map<String, dynamic> json) {
    return PackageInfoModel(
      id: json['id'],
      nama: json['nama'],
      nomorTelepon: json['nomor_telepon'] ?? '',
      alamat: json['alamat'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      jenisPengiriman: json['jenis_pengiriman'],
      serviceType: json['service_type'],
    );
  }
}

class CodModel {
  final String status;
  final double amount;
  final String? collectedAt;
  final String? remittedAt;

  CodModel({
    required this.status,
    required this.amount,
    required this.collectedAt,
    required this.remittedAt,
  });

  factory CodModel.fromJson(Map<String, dynamic> json) {
    return CodModel(
      status: json['status'],
      amount: (json['amount'] as num).toDouble(),
      collectedAt: json['collected_at'],
      remittedAt: json['remitted_at'],
    );
  }
}

class BillingModel {
  final double ongkir;
  final String status;
  final String? paidAt;

  BillingModel({
    required this.ongkir,
    required this.status,
    required this.paidAt,
  });

  factory BillingModel.fromJson(Map<String, dynamic> json) {
    return BillingModel(
      ongkir: (json['ongkir'] as num).toDouble(),
      status: json['status'],
      paidAt: json['paid_at'],
    );
  }
}