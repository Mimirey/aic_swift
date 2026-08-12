import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';

class CallRecipientButton extends StatelessWidget {
  final String phoneNumber;
  const CallRecipientButton({super.key, required this.phoneNumber});

  Future<void> _call() => launchUrl(Uri(scheme: 'tel', path: phoneNumber));

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.statusChipBg,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _call,
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(Icons.call_rounded, size: 18, color: AppColors.primaryDark),
        ),
      ),
    );
  }
}