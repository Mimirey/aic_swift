
import 'package:intl/intl.dart';

extension CurrencyTextParser on String {
  int? toCurrencyInt() {
    final isNegative = trim().startsWith('-');
    final digitsOnly = replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) return null;

    final value = int.parse(digitsOnly);
    return isNegative ? -value : value;
  }

  double? toCurrencyDouble({String? locale}) {
    if (trim().isEmpty) return null;

    final currentLocale = locale ?? Intl.systemLocale;

    final cleaned = replaceAll(RegExp(r'[^0-9\-,.]'), '');
    if (cleaned.isEmpty) return null;

    try {
      final result = NumberFormat.decimalPattern(currentLocale).parse(cleaned);
      return result.toDouble();
    } on FormatException {
      final digitsOnly = cleaned.replaceAll(RegExp(r'[^0-9\-]'), '');
      if (digitsOnly.isEmpty) return null;
      return double.tryParse(digitsOnly);
    }
  }

  num? toCurrencyNum({String? locale}) {
    final asDouble = toCurrencyDouble(locale: locale);
    if (asDouble == null) return null;
    return asDouble == asDouble.roundToDouble() ? asDouble.toInt() : asDouble;
  }
}
