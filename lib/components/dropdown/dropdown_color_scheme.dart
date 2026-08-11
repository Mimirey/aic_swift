import 'package:flutter/material.dart';
import 'package:Swift/config/themes/app_colors.dart';

/// Create instance custom for different themes.
///
/// Example usage:
/// ```dart
/// CustomDropdown(
///   colorScheme: DropdownColorScheme(
///     fillColor: Colors.grey.shade50,
///     selectedItemColor: Colors.green,
///     selectedItemBackground: Colors.green.withValues(alpha: 0.1),
///     activeBorderColor: Colors.green,
///   ),
///   ...
/// )
/// ```
@immutable
class DropdownColorScheme {
  // Trigger
  /// Field background.
  final Color fillColor;

  /// Normal border.
  final Color borderColor;

  /// Active border.
  final Color activeBorderColor;

  /// Disabled border.
  final Color disabledBorderColor;

  /// Error border.
  final Color errorBorderColor;

  /// Value text.
  final Color valueTextColor;

  /// Hint text.
  final Color hintTextColor;

  /// Suffix icon.
  final Color suffixIconColor;

  // Popup
  /// Popup background.
  final Color popupFillColor;

  /// Popup border.
  final Color popupBorderColor;

  /// Popup shadow.
  final Color popupShadowColor;

  // Item
  /// Item text.
  final Color itemTextColor;

  /// Selected item text.
  final Color selectedItemTextColor;

  /// Selected item background.
  final Color selectedItemBackground;

  /// Selected item splash.
  final Color selectedItemSplashColor;

  /// Selected item highlight.
  final Color selectedItemHighlightColor;

  /// Item splash.
  final Color itemSplashColor;

  /// Item highlight.
  final Color itemHighlightColor;

  /// Check icon.
  final Color checkIconColor;

  // Search
  /// Icon search.
  final Color searchIconColor;

  // Helper & Error
  /// Helper text.
  final Color helperTextColor;

  /// Error text.
  final Color errorTextColor;

  const DropdownColorScheme({
    required this.fillColor,
    required this.borderColor,
    required this.activeBorderColor,
    required this.disabledBorderColor,
    required this.errorBorderColor,
    required this.valueTextColor,
    required this.hintTextColor,
    required this.suffixIconColor,
    required this.popupFillColor,
    required this.popupBorderColor,
    required this.popupShadowColor,
    required this.itemTextColor,
    required this.selectedItemTextColor,
    required this.selectedItemBackground,
    required this.selectedItemSplashColor,
    required this.selectedItemHighlightColor,
    required this.itemSplashColor,
    required this.itemHighlightColor,
    required this.checkIconColor,
    required this.searchIconColor,
    required this.helperTextColor,
    required this.errorTextColor,
  });

  factory DropdownColorScheme.defaults() {
    return DropdownColorScheme(
      fillColor: Colors.white,
      borderColor: Colors.grey.shade300,
      activeBorderColor: Colors.blue,
      disabledBorderColor: Colors.grey.shade200,
      errorBorderColor: AppColors.error,
      valueTextColor: Colors.black87,
      hintTextColor: Colors.grey.shade600,
      suffixIconColor: Colors.grey.shade700,
      popupFillColor: Colors.white,
      popupBorderColor: Colors.grey.shade300,
      popupShadowColor: Colors.black,
      itemTextColor: Colors.black87,
      selectedItemTextColor: Colors.blue,
      selectedItemBackground: Colors.blue.withValues(alpha: 0.1),
      selectedItemSplashColor: Colors.blue.withValues(alpha: 0.2),
      selectedItemHighlightColor: Colors.blue.withValues(alpha: 0.1),
      itemSplashColor: Colors.grey.withValues(alpha: 0.2),
      itemHighlightColor: Colors.grey.withValues(alpha: 0.1),
      checkIconColor: Colors.blue,
      searchIconColor: Colors.grey,
      helperTextColor: Colors.grey.shade600,
      errorTextColor: AppColors.error,
    );
  }

  DropdownColorScheme copyWith({
    Color? fillColor,
    Color? borderColor,
    Color? activeBorderColor,
    Color? disabledBorderColor,
    Color? errorBorderColor,
    Color? valueTextColor,
    Color? hintTextColor,
    Color? suffixIconColor,
    Color? popupFillColor,
    Color? popupBorderColor,
    Color? popupShadowColor,
    Color? itemTextColor,
    Color? selectedItemTextColor,
    Color? selectedItemBackground,
    Color? selectedItemSplashColor,
    Color? selectedItemHighlightColor,
    Color? itemSplashColor,
    Color? itemHighlightColor,
    Color? checkIconColor,
    Color? searchIconColor,
    Color? helperTextColor,
    Color? errorTextColor,
  }) {
    return DropdownColorScheme(
      fillColor: fillColor ?? this.fillColor,
      borderColor: borderColor ?? this.borderColor,
      activeBorderColor: activeBorderColor ?? this.activeBorderColor,
      disabledBorderColor: disabledBorderColor ?? this.disabledBorderColor,
      errorBorderColor: errorBorderColor ?? this.errorBorderColor,
      valueTextColor: valueTextColor ?? this.valueTextColor,
      hintTextColor: hintTextColor ?? this.hintTextColor,
      suffixIconColor: suffixIconColor ?? this.suffixIconColor,
      popupFillColor: popupFillColor ?? this.popupFillColor,
      popupBorderColor: popupBorderColor ?? this.popupBorderColor,
      popupShadowColor: popupShadowColor ?? this.popupShadowColor,
      itemTextColor: itemTextColor ?? this.itemTextColor,
      selectedItemTextColor:
          selectedItemTextColor ?? this.selectedItemTextColor,
      selectedItemBackground:
          selectedItemBackground ?? this.selectedItemBackground,
      selectedItemSplashColor:
          selectedItemSplashColor ?? this.selectedItemSplashColor,
      selectedItemHighlightColor:
          selectedItemHighlightColor ?? this.selectedItemHighlightColor,
      itemSplashColor: itemSplashColor ?? this.itemSplashColor,
      itemHighlightColor: itemHighlightColor ?? this.itemHighlightColor,
      checkIconColor: checkIconColor ?? this.checkIconColor,
      searchIconColor: searchIconColor ?? this.searchIconColor,
      helperTextColor: helperTextColor ?? this.helperTextColor,
      errorTextColor: errorTextColor ?? this.errorTextColor,
    );
  }

  /// Green
  factory DropdownColorScheme.green() {
    return DropdownColorScheme.defaults().copyWith(
      activeBorderColor: Colors.green.shade600,
      selectedItemTextColor: Colors.green.shade700,
      selectedItemBackground: Colors.green.withValues(alpha: 0.1),
      selectedItemSplashColor: Colors.green.withValues(alpha: 0.2),
      selectedItemHighlightColor: Colors.green.withValues(alpha: 0.1),
      checkIconColor: Colors.green.shade700,
    );
  }

  /// Indigo
  factory DropdownColorScheme.indigo() {
    return DropdownColorScheme.defaults().copyWith(
      activeBorderColor: Colors.indigo,
      selectedItemTextColor: Colors.indigo,
      selectedItemBackground: Colors.indigo.withValues(alpha: 0.1),
      selectedItemSplashColor: Colors.indigo.withValues(alpha: 0.2),
      selectedItemHighlightColor: Colors.indigo.withValues(alpha: 0.1),
      checkIconColor: Colors.indigo,
    );
  }

  // /// Dark Mode
  // factory DropdownColorScheme.dark() {
  //   return DropdownColorScheme(
  //     fillColor: const Color(0xFF1E1E1E),
  //     borderColor: Colors.grey.shade700,
  //     activeBorderColor: Colors.blueAccent,
  //     disabledBorderColor: Colors.grey.shade800,
  //     errorBorderColor: DarkAppColors.error,
  //     valueTextColor: Colors.white,
  //     hintTextColor: Colors.grey.shade400,
  //     suffixIconColor: Colors.grey.shade400,
  //     popupFillColor: const Color(0xFF2A2A2A),
  //     popupBorderColor: Colors.grey.shade700,
  //     popupShadowColor: Colors.black,
  //     itemTextColor: Colors.white70,
  //     selectedItemTextColor: Colors.blueAccent,
  //     selectedItemBackground: Colors.blueAccent.withValues(alpha: 0.15),
  //     selectedItemSplashColor: Colors.blueAccent.withValues(alpha: 0.25),
  //     selectedItemHighlightColor: Colors.blueAccent.withValues(alpha: 0.15),
  //     itemSplashColor: Colors.white.withValues(alpha: 0.05),
  //     itemHighlightColor: Colors.white.withValues(alpha: 0.03),
  //     checkIconColor: Colors.blueAccent,
  //     searchIconColor: Colors.grey.shade400,
  //     helperTextColor: Colors.grey.shade400,
  //     errorTextColor: DarkAppColors.error,
  //   );
  // }
}
