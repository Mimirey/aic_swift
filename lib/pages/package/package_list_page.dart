import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Swift/core/theme/app_colors.dart';
import 'package:Swift/core/utils/date_formatter.dart';
import 'package:Swift/core/utils/responsive.dart';
import 'package:Swift/components/cards/package_card.dart';
import 'package:Swift/controllers/package_list_controller.dart';

class PackageListPage extends GetView<PackageListController> {
  const PackageListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Get.back(),
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
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
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
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredPackages.isEmpty) {
                return const Center(
                  child: Text(
                    'Paket tidak ditemukan',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: controller.refreshPackages,
                child: controller.filteredPackages.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 150),
                          Center(
                            child: Text(
                              'Paket tidak ditemukan',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          context.horizontalPadding,
                          4,
                          context.horizontalPadding,
                          24,
                        ),
                        itemCount: controller.filteredPackages.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final pkg = controller.filteredPackages[index];
                          return PackageCard(package: pkg);
                        },
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
