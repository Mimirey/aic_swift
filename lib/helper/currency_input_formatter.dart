import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final String? locale;
  final bool isIDR;

  CurrencyInputFormatter({this.locale = 'id_ID', this.isIDR = true});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final rawText = newValue.text.split(',').first;
    final digits = rawText.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final value = int.parse(digits);

    final effectiveLocale = isIDR ? 'id_ID' : (locale ?? Intl.systemLocale);
    var formatted = NumberFormat.decimalPattern(effectiveLocale).format(value);

    if (isIDR) {
      formatted = '$formatted,00';
    }

    final cursorOffset = isIDR ? formatted.length - 3 : formatted.length;

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: cursorOffset.clamp(0, formatted.length),
      ),
    );
  }
}
