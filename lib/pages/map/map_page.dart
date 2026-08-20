import 'package:Swift/components/common/slide_to_action_button.dart';
import 'package:Swift/components/common/user_location_marker.dart';
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
import 'package:Swift/components/common/package_map_marker.dart';
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

class MapPage extends GetView<MapPageController> {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ========== MAP BACKGROUND ==========
          Positioned.fill(
            child: Obx(() {
              final position = controller.currentPosition.value;
              return MapBackground(
                center: position != null
                    ? LatLng(position.latitude, position.longitude)
                    : const LatLng(-6.8048, 110.8385),
                zoom: 15,
                markers: controller.buildMarkers(),
                controller: controller.animatedMapController.mapController,
                polylines: controller.getRoutePolylines(),
              );
            }),
          ),

          // ========== OVERLAY PUTIH ==========
          Positioned.fill(
            child: IgnorePointer(
              child: Container(color: Colors.white.withOpacity(0.15)),
            ),
          ),

          // ========== DATE CHIP ==========
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

          // ========== FABs ==========
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                right: context.horizontalPadding,
                top: 90,
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  children: [
                    _MapFab(
                      icon: Icons.inventory_2_rounded,
                      onTap: () => Get.toNamed(AppRoutes.packageList),
                    ),
                    const SizedBox(height: 10),
                    _MapFab(
                      icon: Icons.my_location_rounded,
                      onTap: controller.handleRelocate,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ========== DRAGGABLE SHEET ==========
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
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(
                    context.horizontalPadding,
                    0,
                    context.horizontalPadding,
                    24,
                  ),
                  children: [
                    const SheetDragHandle(),
                    Obx(() => _buildSheetContent()),
                  ],
                ),
              );
            },
          ),

          // ========== OVERLAY CALCULATING ==========
          Obx(() {
            if (controller.routeState.value == RouteState.calculating) {
              return const RouteCalculatingOverlay();
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  // ========== SHEET CONTENT ==========
  Widget _buildSheetContent() {
    switch (controller.routeState.value) {
      case RouteState.empty:
        return const EmptyStateWidget(
          icon: Icons.inventory_2_outlined,
          title: 'Tidak Ada Pengiriman Hari Ini',
          subtitle: 'Belum ada paket yang ditugaskan ke akunmu hari ini.',
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
        CurrentPackagePreview(address: controller.currentPackage!.address),
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
          packageLabel: 'Package 1',
          trailing: const Text(
            '40 Menit',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryLight,
            ),
          ),
          resiNumber: controller.currentPackage!.resiNumber,
        ),
        _buildAnimatedSection(
          showWhen: controller.stage.value != TaskSheetStage.collapsed,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RecipientInfoSection(
                name: controller.currentPackage!.customerName,
                address: controller.currentPackage!.address,
              ),
              if (controller.currentPackage!.note != null)
                RecipientNoteCard(note: controller.currentPackage!.note!),
            ],
          ),
        ),
        _buildAnimatedSection(
          showWhen: controller.stage.value == TaskSheetStage.full,
          child: NextPackageList(
            items: controller.upcomingPackages.map(toNextPackageItem).toList(),
            onSeeNextSession: () {},
          ),
        ),
        _buildAnimatedSection(
          showWhen: controller.stage.value != TaskSheetStage.collapsed,
          child: Column(
            children: [
              const SizedBox(height: 16),
              SlideToActionButton(
                label: 'Geser untuk Hubungi Penerima',
                icon: Icons.arrow_forward_rounded,
                onConfirm: controller.handleWhatsApp,
              ),
            ],
          ),
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
          packageLabel: 'Package 1',
          resiNumber: controller.currentPackage!.resiNumber,
          trailing: CallRecipientButton(
            phoneNumber: controller.currentPackage!.phoneNumber,
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
  Widget _buildAnimatedSection({
    required bool showWhen,
    required Widget child,
  }) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 250),
      crossFadeState: showWhen
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      firstChild: const SizedBox(width: double.infinity, height: 0),
      secondChild: child,
    );
  }
}

// ========== MAP FAB ==========
class _MapFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapFab({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: AppColors.primaryLight),
        ),
      ),
    );
  }
}
