import 'dart:ffi';

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
      shipmentId: json['shipment_id'] as int,
      resi: json['resi'] as String? ?? '',
      paket: PackageInfoModel.fromJson(
        json['paket'] as Map<String, dynamic>,
      ),
      status: json['status'] as String? ?? 'assigned',
      cod: CodModel.fromJson(
        json['cod'] as Map<String, dynamic>,
      ),
      billing: BillingModel.fromJson(
        json['billing'] as Map<String, dynamic>,
      ),
      pickedUpAt: json['picked_up_at'] as String?,
      deliveredAt: json['delivered_at'] as String?,
      batchNo: json['batch_no'] as String? ?? '',
      kurirId: json['kurir_id'] as int,
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
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      jenisPengiriman: json['jenis_pengiriman'],
      serviceType: json['service_type'],
    );
  }
}

class CodModel {
  final String status;
  final bool is_cod;
  final double amount;
  final String? collectedAt;
  final String? remittedAt;

  CodModel({
    required this.status,
    required this.is_cod, 
    required this.amount,
    required this.collectedAt,
    required this.remittedAt,
  });

  factory CodModel.fromJson(Map<String, dynamic> json) {
    return CodModel(
      status: json['status'] as String? ?? 'pending',
      is_cod: json['is_cod'],
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
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
      status: json['status'] as String? ?? 'unpaid',
      paidAt: json['paid_at']as String?,
    );
  }
}