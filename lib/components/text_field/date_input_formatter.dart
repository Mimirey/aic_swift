import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Extract only digits
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Limit to 8 digits (ddmmyyyy)
    if (digitsOnly.length > 8) {
      return oldValue;
    }

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Build formatted string
    String formatted = '';
    int cursorPos = 0;

    // Day (dd)
    if (digitsOnly.length >= 1) {
      formatted += digitsOnly[0];
      cursorPos = 1;
    }
    if (digitsOnly.length >= 2) {
      formatted += digitsOnly[1];
      cursorPos = 2;
    }

    // First slash after day
    if (digitsOnly.length >= 3) {
      formatted += '/';
      cursorPos = 3; // Position after /
    }

    // Month (mm)
    if (digitsOnly.length >= 3) {
      formatted += digitsOnly[2];
      cursorPos = 4;
    }
    if (digitsOnly.length >= 4) {
      formatted += digitsOnly[3];
      cursorPos = 5;
    }

    // Second slash after month
    if (digitsOnly.length >= 5) {
      formatted += '/';
      cursorPos = 6; // Position after /
    }

    // Year (yyyy)
    if (digitsOnly.length >= 5) {
      formatted += digitsOnly[4];
      cursorPos = 7;
    }
    if (digitsOnly.length >= 6) {
      formatted += digitsOnly[5];
      cursorPos = 8;
    }
    if (digitsOnly.length >= 7) {
      formatted += digitsOnly[6];
      cursorPos = 9;
    }
    if (digitsOnly.length >= 8) {
      formatted += digitsOnly[7];
      cursorPos = 10;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPos),
    );
  }
}
