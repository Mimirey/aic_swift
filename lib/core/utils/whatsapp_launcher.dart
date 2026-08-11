import 'package:url_launcher/url_launcher.dart';

String _toWhatsAppFormat(String phoneNumber) {
  final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
  if (digitsOnly.startsWith('0')) return '62${digitsOnly.substring(1)}';
  if (digitsOnly.startsWith('62')) return digitsOnly;
  return '62$digitsOnly';
}

Future<void> openWhatsApp(String phoneNumber, {String? message}) async {
  final formatted = _toWhatsAppFormat(phoneNumber);
  final query = message != null ? '?text=${Uri.encodeComponent(message)}' : '';
  final uri = Uri.parse('https://wa.me/$formatted$query');

  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched) {
    throw Exception('Gagal membuka WhatsApp untuk nomor $phoneNumber');
  }
}