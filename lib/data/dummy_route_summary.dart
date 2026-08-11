import '../models/route_summary_model.dart';
import 'dummy_packages.dart';

final dummyRouteSummary = RouteSummaryModel(
  totalPackages: dummyPackages.length, // nanti dari API, jumlah paket beneran
  distanceKm: 200,
  durationLabel: '2 Jam',
);