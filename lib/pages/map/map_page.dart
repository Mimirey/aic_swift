import 'package:Swift/components/common/animated_user_marker_layer.dart';
import 'package:Swift/components/common/service_type_badge.dart';
import 'package:Swift/components/common/slide_to_action_button.dart';
import 'package:Swift/components/task/route_calculating_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' hide MapController;
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:Swift/config/routes/route_names.dart';
import 'package:Swift/components/common/sheet_drag_handle.dart';
import 'package:Swift/components/task/task_summary_header.dart';
import 'package:Swift/components/task/recipient_info_section.dart';
import 'package:Swift/components/task/recipient_note_card.dart';
import 'package:Swift/components/task/next_package_list.dart';
import 'package:Swift/data/dummy_next_packages.dart';
import 'package:Swift/components/buttons/primary_button.dart';
import 'package:Swift/components/task/call_recipient_button.dart';
import 'package:Swift/components/task/current_package_preview.dart';
import 'package:Swift/components/task/package_photo_picker.dart';
import 'package:Swift/components/task/photo_preview_strip.dart';
import 'package:Swift/components/task/photo_viewer_sheet.dart';
import 'package:Swift/components/task/route_info_chip.dart';
import 'package:Swift/components/task/task_assigned_header.dart';
import 'package:Swift/core/theme/app_colors.dart';
import 'package:Swift/core/utils/date_formatter.dart';
import 'package:Swift/core/utils/responsive.dart';
import 'package:Swift/components/common/map_background.dart';
import 'package:Swift/components/common/date_chip.dart';
import 'package:Swift/components/common/empty_state_widget.dart';
import 'package:Swift/controllers/map_controller.dart';

import '../../components/common/cod_badge.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final MapPageController controller;

  // double sheetSize = MapPageController.collapsedSize;

  @override
  void initState() {
    super.initState();

    controller = Get.find<MapPageController>();

    // controller.sheetController.addListener(_updateSheetPosition);
  }

  @override
  void dispose() {
    // controller.sheetController.removeListener(_updateSheetPosition);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // ==========================================================
          // MAP
          // ==========================================================
          Positioned.fill(
            child: Builder(
              builder: (_) {
                final initialPosition = controller.currentPosition.value;

                final initialCenter = initialPosition != null
                    ? LatLng(
                        initialPosition.latitude,
                        initialPosition.longitude,
                      )
                    : const LatLng(-6.8048, 110.8385);

                return MapBackground(
                  center: initialCenter,
                  zoom: 15,
                  controller: controller.animatedMapController.mapController,

                  polylinesLayer: Obx(
                    () => PolylineLayer(
                      polylines: controller.getRoutePolylines(),
                    ),
                  ),

                  markersLayer: Stack(
                    children: [
                      Obx(
                        () => MarkerLayer(
                          markers: controller.buildPackageMarkers(),
                        ),
                      ),

                      AnimatedUserMarkerLayer(
                        positionRx: controller.currentPosition,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ==========================================================
          // WHITE OVERLAY
          // ==========================================================
          Positioned.fill(
            child: IgnorePointer(
              child: Container(color: Colors.white.withOpacity(0.15)),
            ),
          ),

          // ==========================================================
          // DATE CHIP
          // ==========================================================
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.horizontalPadding,
                vertical: 8,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: DateChip(date: DateFormatter.fullIndo(DateTime.now())),
              ),
            ),
          ),

          // ==========================================================
          // DRAGGABLE SHEET
          // ==========================================================
          DraggableScrollableSheet(
            controller: controller.sheetController,
            initialChildSize: MapPageController.collapsedSize,
            minChildSize: MapPageController.collapsedSize,
            maxChildSize: MapPageController.fullSize,
            snap: true,
            snapSizes: [
              MapPageController.collapsedSize,
              MapPageController.peekSize,
              MapPageController.fullSize,
            ],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: ListView(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    context.horizontalPadding,
                    0,
                    context.horizontalPadding,
                    24,
                  ),
                  children: [
                    const SheetDragHandle(),
                    Obx(() => _buildSheetContent(context)),
                  ],
                ),
              );
            },
          ),

          // FAB
          // FAB
          AnimatedBuilder(
            animation: controller.sheetController,
            builder: (context, child) {
              final currentSize = controller.sheetController.isAttached
                  ? controller.sheetController.size
                  : MapPageController.collapsedSize;
              return Positioned(
                right: context.horizontalPadding,
                bottom: (screenHeight * currentSize) + 12,
                child: child!,
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MapFab(
                  icon: Icons.inventory_2_rounded,
                  onTap: () => Get.toNamed(AppRoutes.packageList),
                  size: 50,
                ),
                const SizedBox(height: 10),
                _MapFab(
                  icon: Icons.my_location_rounded,
                  onTap: () => controller.handleRelocate(),
                  size: 50,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== SHEET CONTENT ==========
  Widget _buildSheetContent(BuildContext context) {
    switch (controller.routeState.value) {
      case RouteState.empty:
        return SizedBox(
          height:
              MediaQuery.of(context).size.height * 0.5, // sesuaikan proporsinya
          child: const Center(
            child: EmptyStateWidget(
              icon: Icons.inventory_2_outlined,
              title: 'Tidak Ada Pengiriman Hari Ini',
              subtitle: 'Belum ada paket yang ditugaskan ke akunmu hari ini.',
            ),
          ),
        );

      case RouteState.assigned:
        return _buildAssignedContent();

      case RouteState.onRoute:
        return _buildOnRouteContent();

      case RouteState.validating:
        return _buildValidatingContent();

      case RouteState.calculating:
        return const SizedBox.shrink();

      default:
        return const SizedBox.shrink();
    }
  }

  // ========== ASSIGNED CONTENT ==========
  Widget _buildAssignedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TaskAssignedHeader(totalPackages: controller.deliveryQueue.length),
        const SizedBox(height: 14),
        Row(
          children: [
            RouteInfoChip(
              label: 'Estimasi Perjalanan',
              value: controller.optimizedRoute.value != null
                  ? '${controller.optimizedRoute.value!.totalDistanceKm.toStringAsFixed(1)} km'
                  : '-',
            ),
            const SizedBox(width: 10),
            RouteInfoChip(
              label: 'Durasi Perjalanan',
              value: controller.optimizedRoute.value != null
                  ? '${controller.optimizedRoute.value!.totalDurationMins.toStringAsFixed(0)} menit'
                  : '-',
            ),
          ],
        ),
        const Divider(height: 30, color: Color.fromRGBO(46, 111, 184, 1)),
        const Text(
          'Daftar Paket',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 10),
        ...controller.deliveryQueue.map(
          (pkg) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: CurrentPackagePreview(
              address: pkg.address,
              serviceType: pkg.serviceType,
              resiNumber: pkg.resiNumber,
              isCod: pkg.isCod,
            ),
          ),
        ),
        const SizedBox(height: 18),
        PrimaryButton(
          label: 'Mulai Optimasi Rute',
          onPressed: controller.startRoute,
        ),
      ],
    );
  }

  // ========== ON-ROUTE CONTENT ==========
  Widget _buildOnRouteContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TaskSummaryHeader(
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ServiceTypeBadge(
                serviceType: controller.currentPackage!.serviceType,
              ),
              if (controller.currentPackage!.isCod) ...[
                const SizedBox(width: 6),
                const CodBadge(),
              ],
            ],
          ),
          trailing: Obx(
            () => Text(
              controller.estimatedArrivalText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryLight,
              ),
            ),
          ),
          resiNumber: controller.currentPackage!.resiNumber,
        ),
        const SizedBox(height: 10),
        Obx(
          () => Row(
            children: [
              RouteInfoChip(
                label: 'Kecepatan',
                value: '${controller.currentSpeedKmh.toStringAsFixed(0)} km/h',
              ),
              const SizedBox(width: 10),
              RouteInfoChip(
                label: 'Sisa Jarak',
                value: controller.navController.remainingDistanceM.value > 0
                    ? '${(controller.navController.remainingDistanceM.value / 1000).toStringAsFixed(1)} km'
                    : '-',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        RecipientInfoSection(
          name: controller.currentPackage!.customerName,
          address: controller.currentPackage!.address,
        ),
        if (controller.currentPackage!.note != null)
          RecipientNoteCard(note: controller.currentPackage!.note!),
        const SizedBox(height: 14),
        NextPackageList(
          items: controller.upcomingPackageItems,
          onSeeNextSession: () {},
        ),
        const SizedBox(height: 16),
        SlideToActionButton(
          label: 'Geser untuk Hubungi Penerima',
          icon: Icons.arrow_forward_rounded,
          onConfirm: controller.handleWhatsApp,
        ),
      ],
    );
  }

  // ========== VALIDATING CONTENT ==========
  Widget _buildValidatingContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TaskSummaryHeader(
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ServiceTypeBadge(
                serviceType: controller.currentPackage!.serviceType,
              ),
              if (controller.currentPackage!.isCod) ...[
                const SizedBox(width: 6),
                const CodBadge(),
              ],
            ],
          ),
          resiNumber: controller.currentPackage!.resiNumber,
          trailing: Row(
            children: [
              CallRecipientButton(
                phoneNumber: controller.currentPackage!.phoneNumber,
              ),
            ],
          ),
        ),
        RecipientInfoSection(
          name: controller.currentPackage!.customerName,
          address: controller.currentPackage!.address,
        ),
        if (controller.currentPackage!.note != null)
          RecipientNoteCard(note: controller.currentPackage!.note!),
        if (controller.currentPackage!.isCod &&
            controller.currentPackage!.codAmount != null) ...[
          const SizedBox(height: 4),
          Text(
            'Tagihan COD: ${controller.formatCurrency(controller.currentPackage!.codAmount!)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.codAmount,
            ),
          ),
        ],
        const SizedBox(height: 14),
        PackagePhotoPicker(onTap: controller.handleCapturePhoto),
        const SizedBox(height: 10),
        Obx(
          () => PhotoPreviewStrip(
            photos: controller.capturedPhotos.toList(),
            onTapPhoto: (index) => showPhotoViewer(
              Get.context!,
              controller.capturedPhotos,
              index,
              onDelete: (i) => controller.capturedPhotos.removeAt(i),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => PrimaryButton(
            label: 'Konfirmasi Paket',
            onPressed: controller.capturedPhotos.isEmpty
                ? null
                : controller.handleConfirmPackage,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () {},
            child: const Text(
              'Laporan Kendala',
              style: TextStyle(fontSize: 12.5, color: AppColors.primaryLight),
            ),
          ),
        ),
      ],
    );
  }

  // ========== ANIMATED SECTION ==========
  // Widget _buildAnimatedSection({
  //   required bool showWhen,
  //   required Widget child,
  // }) {
  //   return AnimatedCrossFade(
  //     duration: const Duration(milliseconds: 250),
  //     crossFadeState: showWhen
  //         ? CrossFadeState.showSecond
  //         : CrossFadeState.showFirst,
  //     firstChild: const SizedBox(width: double.infinity, height: 0),
  //     secondChild: child,
  //   );
  // }
}

// ========== MAP FAB ==========
class _MapFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _MapFab({required this.icon, required this.onTap, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Icon(icon, size: size * 0.55, color: AppColors.primaryLight),
          ),
        ),
      ),
    );
  }
}
