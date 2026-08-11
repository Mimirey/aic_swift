import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:Swift/components/custom_spacing.dart';
import 'package:Swift/components/custom_text.dart';

class CustomIconbutton extends StatelessWidget {
  final IconData? icon;
  final String assetPath;
  final double? iconWidth, iconHeight, fontSize;
  final BoxFit boxFit;
  final VoidCallback onTap;
  final String text;
  final Color? iconColor, foregroundColor, backgroundColor, splashColor;
  final Color borderColor;
  final double borderWidth, spacing, borderRadius, height, width, iconSize;
  final FontWeight? fontWeight, iconWeight;
  final bool useBorder, useDInfin, isCustom, useSvg;
  final ColorFilter? colorFilter;

  const CustomIconbutton({
    super.key,
    required this.onTap,
    required this.text,
    this.icon,
    this.iconColor,
    this.foregroundColor,
    this.backgroundColor,
    this.splashColor,
    this.fontWeight,
    this.borderColor = Colors.black,
    this.borderWidth = 1,
    this.spacing = 8,
    this.useBorder = false,
    this.borderRadius = 16,
    this.height = 14,
    this.width = 8,
    this.iconWeight,
    this.useDInfin = false,
    this.iconSize = 24,
    this.isCustom = false,
    this.useSvg = true,
    this.assetPath = "",
    this.boxFit = BoxFit.cover,
    this.iconWidth,
    this.iconHeight,
    this.fontSize, this.colorFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Ink(
        width: useDInfin ? double.infinity : null,
        decoration: BoxDecoration(
          border: useBorder
              ? Border.all(color: borderColor, width: borderWidth)
              : null,
          borderRadius: BorderRadius.circular(borderRadius),
          color: backgroundColor,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: height, horizontal: width),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                isCustom
                    ? useSvg
                          ? SvgPicture.asset(
                              assetPath,
                              colorFilter: colorFilter,
                              fit: boxFit,
                              width: iconWidth,
                              height: iconHeight,
                            )
                          : Image.asset(
                              assetPath,
                              fit: boxFit,
                              width: iconWidth,
                              height: iconHeight,
                            )
                    : Icon(
                        icon,
                        color: iconColor,
                        fontWeight: iconWeight,
                        size: iconSize,
                      ),
                CustomSpacing(width: spacing),
                CustomText(
                  text: text,
                  style: TextStyle(
                    fontSize: fontSize ?? 18,
                    color: foregroundColor,
                    fontWeight: fontWeight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
