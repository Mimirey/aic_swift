import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Swift/models/package/package_model.dart';
import 'package:Swift/models/shipment_model.dart';
import 'package:Swift/services/shipment_service.dart';

class PackageListController extends GetxController {
  final searchController = TextEditingController();
  final shipmentService = ShipmentService.instance;
  // Reactive state
  final RxList<PackageModel> packages = <PackageModel>[].obs;
  final RxList<PackageModel> filteredPackages = <PackageModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPackages();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> _loadPackages() async {
    try {
      isLoading.value = true;
      final shipments = await shipmentService.getShipments();
      final loadedPackages = shipments.map(_shipmentToPackage).toList();

      packages.value = loadedPackages;
      filteredPackages.value = loadedPackages;
    } catch (e) {
      print('PACKAGE LIST ERROR: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat daftar paket',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPackages() async {
    await _loadPackages();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    
    if (query.trim().isEmpty) {
      filteredPackages.value = packages;
      return;
    }

    final lower = query.toLowerCase();
    filteredPackages.value = packages.where((p) {
      return p.resiNumber.toLowerCase().contains(lower) ||
          p.customerName.toLowerCase().contains(lower);
    }).toList();
  }

  PackageModel _shipmentToPackage(ShipmentModel shipment) {
    return PackageModel(
      id: shipment.paket.id.toString(),
      resiNumber: shipment.resi,
      serviceType: shipment.paket.serviceType.toLowerCase() == 'express'
          ? ServiceType.express
          : ServiceType.regular,
      isCod: shipment.cod.amount > 0,
      codAmount: shipment.cod.amount,
      customerName: shipment.paket.nama,
      phoneNumber: shipment.paket.nomorTelepon,
      address: shipment.paket.alamat,
      note: null,
      status: _mapStatus(shipment.status),
      latitude: shipment.paket.latitude,
      longitude: shipment.paket.longitude,
    );
  }

  DeliveryStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return DeliveryStatus.delivered;
      case 'picked_up':
        return DeliveryStatus.onTheWay;
      case 'assigned':
        return DeliveryStatus.pending;
      default:
        return DeliveryStatus.pending;
    }
  }
}