import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Swift/config/routes/route_names.dart';

class MapCalculatingController extends GetxController
    with SingleGetTickerProviderMixin {
  late final AnimationController pulseController;

  @override
  void onInit() {
    super.onInit();
    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void onClose() {
    pulseController.dispose();
    super.onClose();
  }
}