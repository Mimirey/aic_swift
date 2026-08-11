import '../models/next_package_item.dart';
import 'dummy_packages.dart';

final currentTaskPackage = dummyPackages.first;
final dummyNextPackages = dummyPackages
    .skip(1) // lewatin currentTaskPackage
    .map((p) => NextPackageItem(
          address: p.address,
          distanceLabel: '100m', 
        ))
    .toList();