import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:getx_setup/components/text_field/date_input_formatter.dart';

class CustomTextField extends StatelessWidget {
  final Color? fillColor, borderColor;
  final bool isNumber, isDate, enabled, alignLabelWithHint;
  final String label, hint;
  final String? helperText, errorText, suffixText, prefixText;
  final double? marginTop, borderWidth;
  final TextEditingController controller;
  final TextInputType? textInputType;
  final bool? obscureText,
      readOnly,
      enableSuggestion,
      isShow,
      enableInteractiveSelection,
      useSuffixIcon,
      usePrefixIcon,
      useBorder,
      filled,
      autofocus,
      isError;
  final GestureTapCallback? onTap, onTapSuffixIcon, onTapPrefixIcon;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final Widget? suffixIcon, prefixIcon;
  final BoxConstraints? prefixIconConstraints;
  final FocusNode? focusNode;
  final TextStyle? helperStyle, errorStyle, suffixStyle, prefixStyle;
  final int? helperMaxLines, errorMaxLines, maxLines;
  final String initialValue;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    this.alignLabelWithHint = false,
    this.isNumber = false,
    this.isDate = false,
    this.enabled = true,
    this.label = "",
    this.hint = "",
    this.marginTop,
    required this.controller,
    this.obscureText,
    this.readOnly,
    this.autofocus,
    this.enableSuggestion,
    this.isShow,
    this.enableInteractiveSelection,
    this.onTap,
    this.onTapSuffixIcon,
    this.onTapPrefixIcon,
    this.suffixIcon,
    this.prefixIcon,
    this.focusNode,
    this.onChanged,
    this.useSuffixIcon = false,
    this.usePrefixIcon = false,
    this.useBorder = true,
    this.fillColor,
    this.borderColor,
    this.filled,
    this.isError,
    this.helperText,
    this.helperStyle,
    this.helperMaxLines,
    this.errorText,
    this.errorStyle,
    this.errorMaxLines,
    this.validator,
    this.suffixText,
    this.suffixStyle,
    this.textInputType,
    this.borderWidth = 0,
    this.prefixIconConstraints,
    this.onFieldSubmitted,
    this.initialValue = '',
    this.maxLines,
    this.textInputAction,
    this.prefixText,
    this.prefixStyle,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: marginTop ?? 0.0),
      child: TextFormField(
        enabled: enabled,
        textInputAction: textInputAction ?? TextInputAction.next,
        focusNode: focusNode,
        keyboardType:
            textInputType ??
            (isDate
                ? TextInputType.number
                : (isNumber ? TextInputType.number : TextInputType.text)),
        inputFormatters:
            inputFormatters ??
            (isDate
                ? [DateInputFormatter()]
                : isNumber
                ? [FilteringTextInputFormatter.digitsOnly]
                : []),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: controller,
        maxLines: maxLines ?? 1,
        decoration: InputDecoration(
          filled: filled ?? true,
          fillColor: fillColor ?? Colors.white,
          labelStyle: TextStyle(color: Colors.grey.shade700),
          hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.7)),
          labelText: label,
          alignLabelWithHint: alignLabelWithHint,
          hintText: hint,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          hintFadeDuration: Duration(milliseconds: 500),
          prefixText: prefixText,
          prefixStyle:
              prefixStyle ??
              TextStyle(
                fontSize: 16,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w600,
              ),
          suffixText: suffixText,
          suffixStyle:
              suffixStyle ??
              TextStyle(
                fontSize: 16,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w600,
              ),

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide(width: borderWidth ?? 0, color: Colors.red),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide(width: borderWidth ?? 0, color: Colors.red),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide(
              width: borderWidth ?? 0,
              color: Colors.orange,
            ),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide(
              width: borderWidth ?? 0,
              color: useBorder!
                  ? borderColor ?? Colors.grey.shade400
                  : Colors.transparent,
            ),
          ),

          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide(
              width: borderWidth ?? 0,
              color: Colors.grey.shade200,
            ),
          ),

          helperText: helperText,
          helperStyle:
              helperStyle ??
              TextStyle(color: Colors.grey.shade200, fontSize: 14, height: 1.4),
          helperMaxLines: helperMaxLines ?? 2,

          errorText: errorText,
          errorStyle:
              errorStyle ??
              TextStyle(color: Colors.red, fontSize: 14, height: 1.4),
          errorMaxLines: errorMaxLines ?? 2,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide(
              width: borderWidth ?? 0,
              color: useBorder!
                  ? borderColor ?? Colors.grey.shade400
                  : Colors.transparent,
            ),
          ),

          prefixIcon: usePrefixIcon!
              ? Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: GestureDetector(
                    onTap: onTapPrefixIcon,
                    child: prefixIcon,
                  ),
                )
              : null,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          suffixIcon: useSuffixIcon!
              ? Padding(
                  padding: const EdgeInsets.only(right: 14.0, left: 10.0),
                  child: GestureDetector(
                    onTap: onTapSuffixIcon,
                    child: suffixIcon,
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),

        enableInteractiveSelection: enableInteractiveSelection ?? true,
        enableSuggestions: enableSuggestion ?? false,
        obscureText: obscureText ?? false,
        readOnly: readOnly ?? false,
        autofocus: autofocus ?? false,
        onChanged: onChanged,
        onTap: onTap,
        onFieldSubmitted: onFieldSubmitted,
        validator: validator,
      ),
    );
  }
}
