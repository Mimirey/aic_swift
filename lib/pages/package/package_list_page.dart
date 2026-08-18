import 'package:Swift/core/utils/date_formatter.dart';
import 'package:flutter/material.dart';
import 'package:Swift/config/routes/route_names.dart';
import 'package:Swift/models/package/package_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../components/cards/package_card.dart';
import 'package:Swift/services/shipment_service.dart';
import 'package:Swift/models/shipment_model.dart';

class PackageListPage extends StatefulWidget {
  const PackageListPage({super.key});

  @override
  State<PackageListPage> createState() => _PackageListPageState();
}

class _PackageListPageState extends State<PackageListPage> {
  final _searchController = TextEditingController();
  List<PackageModel> _packages = [];
  List<PackageModel> _filtered = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPackages() async {
    try {
      final shipments = await ShipmentService.instance.getShipments();

      final packages = shipments.map(_shipmentToPackage).toList();

      if (!mounted) return;

      setState(() {
        _packages = packages;
        _filtered = packages;
        _isLoading = false;
      });
    } catch (e) {
      print('PACKAGE LIST ERROR: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filtered = _packages;
        return;
      }

      final lower = query.toLowerCase();

      _filtered = _packages
          .where(
            (p) =>
                p.resiNumber.toLowerCase().contains(lower) ||
                p.customerName.toLowerCase().contains(lower),
          )
          .toList();
    });
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
      longitude: shipment.paket.longitude
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Daftar Paket'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                DateFormatter.fullIndo(DateTime.now()),
                style: TextStyle(
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.w700,
                  fontSize: context.scaled(13),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.horizontalPadding,
              4,
              context.horizontalPadding,
              12,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari Paket...',
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: const Icon(
                  Icons.swap_vert_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                ? const Center(
                    child: Text(
                      'Paket tidak ditemukan',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      context.horizontalPadding,
                      4,
                      context.horizontalPadding,
                      24,
                    ),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final pkg = _filtered[index];

                      return PackageCard(package: pkg);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
