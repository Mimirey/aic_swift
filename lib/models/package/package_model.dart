/// Tipe layanan pengiriman.
enum ServiceType { express, regular }

/// Status pengiriman paket.
enum DeliveryStatus { pending, onTheWay, delivered, failed }

extension ServiceTypeLabel on ServiceType {
  String get label {
    switch (this) {
      case ServiceType.express:
        return 'Express';
      case ServiceType.regular:
        return 'Reguler';
    }
  }
}

extension DeliveryStatusLabel on DeliveryStatus {
  String get label {
    switch (this) {
      case DeliveryStatus.pending:
        return 'Menunggu';
      case DeliveryStatus.onTheWay:
        return 'Dalam Perjalanan';
      case DeliveryStatus.delivered:
        return 'Sampai';
      case DeliveryStatus.failed:
        return 'Gagal';
    }
  }
}

/// Model paket kiriman. Field & nama sengaja dibuat mendekati bentuk
/// response API supaya nanti tinggal pakai `PackageModel.fromJson()`
/// tanpa banyak ubah di sisi UI.
class PackageModel {
  final String id;
  final String resiNumber;
  final ServiceType serviceType;
  final bool isCod;
  final double? codAmount;
  final String customerName;
  final String phoneNumber;
  final String address;
  final String? note;
  final DeliveryStatus status;
  final double latitude;
  final double longitude;

  const PackageModel({
    required this.id,
    required this.resiNumber,
    required this.serviceType,
    required this.isCod,
    this.codAmount,
    required this.customerName,
    required this.phoneNumber,
    required this.address,
    this.note,
    required this.status,
    required this.latitude,
    required this.longitude,
  });

  /// Siap dipakai begitu backend API sudah jalan.
  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'].toString(),
      resiNumber: json['resi_number'] as String,
      serviceType: (json['service_type'] == 'express')
          ? ServiceType.express
          : ServiceType.regular,
      isCod: json['is_cod'] as bool? ?? false,
      codAmount: (json['cod_amount'] as num?)?.toDouble(),
      customerName: json['customer_name'] as String,
      phoneNumber: json['phone_number'] as String,
      address: json['address'] as String,
      note: json['note'] as String?,
      status: DeliveryStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DeliveryStatus.pending,
      ),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'resi_number': resiNumber,
        'service_type': serviceType.name,
        'is_cod': isCod,
        'cod_amount': codAmount,
        'customer_name': customerName,
        'phone_number': phoneNumber,
        'address': address,
        'note': note,
        'status': status.name,
        'latitude': latitude,
        'longitude': longitude,
      };
}
