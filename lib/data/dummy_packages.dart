import 'package:Swift/models/package/package_model.dart';

/// Data dummy sementara. Titik koordinat pakai area Semarang
/// biar map dummy-nya realistis untuk testing rute.
///
/// Nanti tinggal ganti pemanggilannya jadi:
/// `final packages = await packageRepository.fetchTodayPackages();`
final List<PackageModel> dummyPackages = [
  PackageModel(
    id: '1',
    resiNumber: 'JP12345678',
    serviceType: ServiceType.express,
    isCod: true,
    codAmount: 125000,
    customerName: 'Usman Anak Myra',
    phoneNumber: '085127638784',
    address: 'Jl. Mawar No. 12, Kel. Palmerah, Kec. Palmerah',
    note: 'Titip di Pos Satpam kalau tidak ada orang',
    status: DeliveryStatus.delivered,
    latitude: -6.9932,
    longitude: 110.4203,
  ),
  PackageModel(
    id: '2',
    resiNumber: 'JP12345679',
    serviceType: ServiceType.express,
    isCod: false,
    customerName: 'Dewi Kartika',
    phoneNumber: '081234567890',
    address: 'Jl. Anggrek IV No. 5, Kel. Mugassari',
    note: 'Hubungi dulu sebelum sampai',
    status: DeliveryStatus.onTheWay,
    latitude: -6.9975,
    longitude: 110.4110,
  ),
  PackageModel(
    id: '3',
    resiNumber: 'JP12345680',
    serviceType: ServiceType.regular,
    isCod: false,
    customerName: 'Bagas Pratama',
    phoneNumber: '087812345678',
    address: 'Jl. Mayjend Sutoyo No. 21, Kec. Candisari',
    note: null,
    status: DeliveryStatus.pending,
    latitude: -6.9890,
    longitude: 110.4300,
  ),
  PackageModel(
    id: '4',
    resiNumber: 'JP12345681',
    serviceType: ServiceType.express,
    isCod: true,
    codAmount: 89000,
    customerName: 'Sinta Ayu',
    phoneNumber: '089911223344',
    address: 'Jl. Menteri Supeno No. 8',
    note: 'Titip di Pos Satpam kalau tidak ada orang',
    status: DeliveryStatus.pending,
    latitude: -6.9950,
    longitude: 110.4250,
  ),
];
