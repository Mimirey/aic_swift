import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String safeString(dynamic value, {String fallback = '-'}) {
  if (value == null) return fallback;
  if (value is bool || value == false) return fallback;
  if (value is String && value.trim().isEmpty) return fallback;
  return value.toString();
}

bool safeBool(dynamic value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  return value.toString().toLowerCase() == 'true' || value.toString() == '1';
}

String safeDate(
  dynamic value, {
  String format = 'dd MMM yyyy',
  bool useLocale = true,
  String fallback = '-',
}) {
  if (value == null) return fallback;

  try {
    DateTime? date;

    if (value is DateTime) {
      date = value.toLocal();
    } else if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return fallback;
      date = DateTime.parse(trimmed).toLocal();
    } else {
      date = DateTime.parse(value.toString().trim()).toLocal();
    }

    final locale = useLocale ? Intl.systemLocale : null;
    return DateFormat(format, locale).format(date);
  } catch (e) {
    debugPrint('safeDate error: $e | value: $value');
    return fallback;
  }
}
