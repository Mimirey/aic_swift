import 'package:flutter/material.dart';
import 'package:Swift/components/dropdown/custom_dropdown.dart';
import 'package:Swift/config/themes/app_colors.dart';

class DropdownFormField<T> extends FormField<T> {
  DropdownFormField({
    super.key,
    required T? value,
    required List<T> items,
    required String hint,
    required ValueChanged<T> onChanged,
    required String Function(T) itemLabel,
    bool Function(T a, T b)? compareFn,
    String? helperText,
    void Function()? onEmpty,
    String emptyText = 'Data tidak tersedia',
    List<int> disabledIndexes = const [],
    super.validator,
  }) : super(
         initialValue: value,
         autovalidateMode: AutovalidateMode.onUserInteraction,
         builder: (FormFieldState<T> state) {
           return CustomDropdown<T>(
             value: state.value,
             items: items,
             hint: hint,
             itemLabel: itemLabel,
             compareFn: compareFn,
             helperText: state.hasError ? null : helperText,
             errorText: state.errorText,
             errorStyle: TextStyle(
               color: AppColors.error.withValues(alpha: 0.8),
             ),
             errorOutline: AppColors.error.withValues(alpha: 0.8),
             onEmpty: onEmpty,
             emptyText: emptyText,
             onChanged: (T newValue) {
               state.didChange(newValue);
               onChanged(newValue);
             },
             disabledIndexes: disabledIndexes,
           );
         },
       );
}

