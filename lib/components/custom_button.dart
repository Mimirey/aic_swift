import 'package:flutter/material.dart';
import 'package:Swift/components/custom_text.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final double? margin, height, width, borderRadius, fontSize, elevation;
  final Color? backgroundColor, foregroundColor;
  final VoidCallback? onPressed;
  final OutlinedBorder? shape;

  const CustomButton({
    super.key,
    required this.text,
    this.margin,
    this.backgroundColor,
    this.foregroundColor,
    this.onPressed,
    this.shape,
    this.height,
    this.width,
    this.borderRadius,
    this.fontSize,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: margin ?? 0.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: elevation ?? 1,
          padding: EdgeInsets.symmetric(
            vertical: height ?? 8.0,
            horizontal: width ?? 32.0,
          ),
          shape:
              shape ??
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 20.0),
              ),
        ),
        child: CustomText(
          text: text,
          style: TextStyle(fontSize: fontSize ?? 18),
        ),
      ),
    );
  }
}
