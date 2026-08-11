class RouteSummaryModel {
  final int totalPackages;
  final double distanceKm;
  final String durationLabel; // "2 Jam"

  const RouteSummaryModel({
    required this.totalPackages,
    required this.distanceKm,
    required this.durationLabel,
  });
}