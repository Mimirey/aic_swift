import 'package:flutter/material.dart';
import 'package:Swift/config/routes/route_names.dart';
import 'package:Swift/models/package/package_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../data/dummy_packages.dart';
import '../../components/cards/package_card.dart';

class PackageListPage extends StatefulWidget {
  const PackageListPage({super.key});

  @override
  State<PackageListPage> createState() => _PackageListPageState();
}

class _PackageListPageState extends State<PackageListPage> {
  final _searchController = TextEditingController();
  List<PackageModel> _filtered = dummyPackages;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filtered = dummyPackages;
        return;
      }
      final lower = query.toLowerCase();
      _filtered = dummyPackages
          .where((p) =>
              p.resiNumber.toLowerCase().contains(lower) ||
              p.customerName.toLowerCase().contains(lower))
          .toList();
    });
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
                '30 Juli 2026',
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
            padding: EdgeInsets.fromLTRB(context.horizontalPadding, 4, context.horizontalPadding, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari Paket...',
                prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                suffixIcon: const Icon(Icons.swap_vert_rounded, size: 20, color: AppColors.textSecondary),
              ),
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
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
                      return PackageCard(
                        package: pkg,
                        onTap: () {
                          // TODO: navigasi ke detail paket / mulai rute.
                          Navigator.of(context).pushNamed(AppRoutes.mapCalculating);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
