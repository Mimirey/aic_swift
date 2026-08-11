import '../models/next_package_item.dart';
import 'dummy_packages.dart';

final currentTaskPackage = dummyPackages.first;

final dummyNextPackages = List.generate(
  4,
  (i) => const NextPackageItem(
    address: 'Jl. Mawar No. 12, Kel. Palmerah, Kec. Palmerah',
    distanceLabel: '100m',
  ),
);