import 'dart:async';
import 'package:Swift/components/common/slide_to_action_button.dart';
import 'package:Swift/components/common/user_location_marker.dart';
import 'package:Swift/components/task/route_calculating_overlay.dart';
import 'package:Swift/core/utils/location_service.dart';
import 'package:Swift/core/utils/whatsapp_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:Swift/config/routes/route_names.dart';
import 'package:Swift/components/common/sheet_drag_handle.dart';
import 'package:Swift/components/task/task_summary_header.dart';
import 'package:Swift/components/task/recipient_info_section.dart';
import 'package:Swift/components/task/recipient_note_card.dart';
import 'package:Swift/components/task/next_package_list.dart';
import 'package:Swift/data/dummy_next_packages.dart';
import '../../components/buttons/primary_button.dart';
import '../../components/common/package_map_marker.dart';
import '../../components/task/call_recipient_button.dart';
import '../../components/task/current_package_preview.dart';
import '../../components/task/package_photo_picker.dart';
import '../../components/task/photo_preview_strip.dart';
import '../../components/task/photo_viewer_sheet.dart';
import '../../components/task/route_info_chip.dart';
import '../../components/task/task_assigned_header.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/responsive.dart';
import '../../components/common/map_background.dart';
import '../../components/common/date_chip.dart';
import '../../components/common/empty_state_widget.dart';
import '../../data/dummy_packages.dart';
import '../../data/dummy_route_summary.dart';
import '../../models/package/package_model.dart';

enum TaskSheetStage { collapsed, peek, full }

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapPageState();
}

enum RouteState { empty, assigned, calculating, onRoute, validating }

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  final _sheetController = DraggableScrollableController();
  StreamSubscription<Position>? _positionSub;
  static const double _arrivalThresholdMeters = 500000;
  late List<PackageModel> _deliveryQueue;
  PackageModel? get _currentPackage =>
      _deliveryQueue.isNotEmpty ? _deliveryQueue.first : null;
  List<PackageModel> get _upcomingPackages => _deliveryQueue.skip(1).toList();

  void _startWatchingArrival() {
    _positionSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((position) {
          if (_routeState != RouteState.onRoute)
            return; // cuma cek kalau lagi dalam perjalanan
          final distance = distanceToTargetInMeters(
            position,
            _currentPackage!.latitude,
            _currentPackage!.longitude,
          );
          if (distance <= _arrivalThresholdMeters) {
            setState(() => _routeState = RouteState.validating);
            _positionSub?.cancel();
          }
        });
  }

  void _handleConfirmPackage() {
    if (_currentPackage == null) return;
    setState(() {
      _deliveryQueue.removeAt(0); 
      _capturedPhotos
          .clear(); 
      _routeState = _deliveryQueue.isEmpty
          ? RouteState.empty
          : RouteState.onRoute;
    });
  }

  late final _animatedMapController = AnimatedMapController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
    curve: Curves.easeInOut,
  );

  TaskSheetStage _stage = TaskSheetStage.collapsed;
  Position? _currentPosition;
  final _mapController = MapController();
  static const _collapsedSize = 0.18;
  static const _peekSize = 0.5;
  static const _fullSize = 0.85;
  static const _dummyCenter = LatLng(-6.9932, 110.4203);
  RouteState _routeState = dummyPackages.isEmpty
      ? RouteState.empty
      : RouteState.assigned;

  final List<XFile> _capturedPhotos = [];
  Future<void> _handleCapturePhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (photo == null) return;
    setState(() => _capturedPhotos.add(photo));
  }

  String _formatCurrency(double amount) {
    final str = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final posFromRight = str.length - i;
      buffer.write(str[i]);
      if (posFromRight > 1 && posFromRight % 3 == 1) buffer.write('.');
    }
    return 'Rp $buffer';
  }

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetChanged);
    _loadCurrentLocation();
    _deliveryQueue = List.of(dummyPackages);
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    _animatedMapController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    final position = await getCurrentUserLocation();
    if (!mounted || position == null) return;
    setState(() => _currentPosition = position);
  }

  Future<void> _handleRelocate() async {
    final position = await getCurrentUserLocation();
    if (position == null || !mounted) return;

    _animatedMapController.animateTo(
      dest: LatLng(position.latitude, position.longitude),
      zoom: 16,
    );
  }

  void _onSheetChanged() {
    final size = _sheetController.size;
    final newStage = size >= 0.85
        ? TaskSheetStage.full
        : size >= 0.35
        ? TaskSheetStage.peek
        : TaskSheetStage.collapsed;
    if (newStage != _stage) setState(() => _stage = newStage);
  }

  List<Marker> _buildMarkers() {
    final packageMarkers = dummyPackages.map((pkg) {
      final isActive = pkg.id == _currentPackage!.id;
      return Marker(
        point: LatLng(pkg.latitude, pkg.longitude),
        width: isActive ? 34 : 16,
        height: isActive ? 34 : 16,
        child: PackageMapMarker(isActive: isActive),
      );
    }).toList();
    if (_currentPosition != null) {
      packageMarkers.add(
        Marker(
          point: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          width: 40,
          height: 40,
          child: const UserLocationMarker(),
        ),
      );
    }
    return packageMarkers;
  }

  @override
  Widget build(BuildContext context) {
    final hasPackages = dummyPackages.isNotEmpty;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: MapBackground(
              center: _dummyCenter,
              zoom: 15,
              markers: _buildMarkers(),
              controller: _animatedMapController.mapController,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(color: Colors.white.withOpacity(0.15)),
            ),
          ),
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
                      onTap: _handleRelocate,
                    ),
                  ],
                ),
              ),
            ),
          ),
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: _collapsedSize,
            minChildSize: _collapsedSize,
            maxChildSize: _fullSize,
            snap: true,
            snapSizes: const [_collapsedSize, _peekSize, _fullSize],
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
                    if (_routeState == RouteState.empty)
                      const EmptyStateWidget(
                        icon: Icons.inventory_2_outlined,
                        title: 'Tidak Ada Pengiriman Hari Ini',
                        subtitle:
                            'Belum ada paket yang ditugaskan ke akunmu hari ini.',
                      )
                    else if (_routeState == RouteState.assigned) ...[
                      TaskAssignedHeader(
                        totalPackages: dummyRouteSummary.totalPackages,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          RouteInfoChip(
                            label: 'Estimasi Perjalanan',
                            value: '${dummyRouteSummary.distanceKm.toInt()} km',
                          ),
                          const SizedBox(width: 10),
                          RouteInfoChip(
                            label: 'Durasi Perjalanan',
                            value: dummyRouteSummary.durationLabel,
                          ),
                        ],
                      ),
                      const Divider(
                        height: 30,
                        color: Color.fromRGBO(46, 111, 184, 1),
                      ),
                      const Text(
                        'Daftar Paket',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      CurrentPackagePreview(
                        address: _currentPackage!.address,
                      ),
                      const SizedBox(height: 18),
                      PrimaryButton(
                        label: 'Mulai Optimasi Rute',
                        onPressed: () {
                          setState(() => _routeState = RouteState.calculating);
                          Future.delayed(const Duration(seconds: 2), () {
                            if (!mounted) return;
                            setState(() => _routeState = RouteState.onRoute);
                            _startWatchingArrival();
                          });
                        },
                      ),
                    ] else if (_routeState == RouteState.onRoute) ...[
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
                        resiNumber: _currentPackage!.resiNumber,
                      ),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 250),
                        crossFadeState: _stage != TaskSheetStage.collapsed
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: const SizedBox(
                          width: double.infinity,
                          height: 0,
                        ),
                        secondChild: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RecipientInfoSection(
                              name: _currentPackage!.customerName,
                              address: _currentPackage!.address,
                            ),
                            if (_currentPackage!.note != null)
                              RecipientNoteCard(note: _currentPackage!.note!),
                          ],
                        ),
                      ),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 250),
                        crossFadeState: _stage == TaskSheetStage.full
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: const SizedBox(
                          width: double.infinity,
                          height: 0,
                        ),
                        secondChild: NextPackageList(
                          items: _upcomingPackages.map(toNextPackageItem).toList(),
                          onSeeNextSession: () {},
                        ),
                      ),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 250),
                        crossFadeState: _stage != TaskSheetStage.collapsed
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: const SizedBox(
                          width: double.infinity,
                          height: 0,
                        ),
                        secondChild: Column(
                          children: [
                            SizedBox(height: 16),
                            SlideToActionButton(
                              label: 'Geser untuk Hubungi Penerima',
                              icon: Icons.arrow_forward_rounded,
                              onConfirm: () =>
                                  openWhatsApp(_currentPackage!.phoneNumber),
                            ),
                          ],
                        ),
                      ),
                    ] else if (_routeState == RouteState.validating) ...[
                      TaskSummaryHeader(
                        packageLabel: 'Package 1',
                        resiNumber: _currentPackage!.resiNumber,
                        trailing: CallRecipientButton(
                          phoneNumber: _currentPackage!.phoneNumber,
                        ),
                      ),
                      RecipientInfoSection(
                        name: _currentPackage!.customerName,
                        address: _currentPackage!.address,
                      ),
                      if (_currentPackage!.note != null)
                        RecipientNoteCard(note: _currentPackage!.note!),
                      if (_currentPackage!.isCod &&
                          _currentPackage!.codAmount != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Tagihan COD: ${_formatCurrency(_currentPackage!.codAmount!)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.codAmount,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      PackagePhotoPicker(onTap: _handleCapturePhoto),
                      const SizedBox(height: 10),
                      PhotoPreviewStrip(
                        photos: _capturedPhotos,
                        onTapPhoto: (index) => showPhotoViewer(
                          context,
                          _capturedPhotos,
                          index,
                          onDelete: (i) =>
                              setState(() => _capturedPhotos.removeAt(i)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'Konfirmasi Paket',
                        onPressed:  _capturedPhotos.isEmpty ? null : _handleConfirmPackage,
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Laporan Kendala',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          if (_routeState == RouteState.calculating)
            const RouteCalculatingOverlay(),
        ],
      ),
    );
  }
}

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
