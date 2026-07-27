import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomIconbuttonCircle extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isCustomIcon;
  final bool isCustom;
  final bool useSvg;
  final String? prefixIconPath;
  final String? assetPath;
  final IconData? prefixIcon;
  final Color? iconColor, backgroundColor, splashColor;
  final double iconSize;
  final double? iconWidth;
  final double? iconHeight;
  final double width, height;
  final EdgeInsetsGeometry? padding;

  const CustomIconbuttonCircle({
    super.key,
    required this.onPressed,
    this.isCustomIcon = false,
    this.isCustom = false,
    this.useSvg = false,
    this.prefixIconPath,
    this.assetPath,
    this.prefixIcon,
    this.iconColor,
    this.backgroundColor,
    this.splashColor,
    this.iconSize = 24,
    this.iconWidth,
    this.iconHeight,
    this.width = 48,
    this.height = 48,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: onPressed,
        splashColor: splashColor,
        child: Ink(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: Center(child: _buildIcon()),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (useSvg || isCustomIcon) {
      return SvgPicture.asset(
        assetPath ?? prefixIconPath ?? "",
        width: iconWidth ?? iconSize,
        height: iconHeight ?? iconSize,
        colorFilter: iconColor != null
            ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
            : null,
      );
    } else if (isCustom) {
      return Image.asset(
        assetPath ?? prefixIconPath ?? "",
        width: iconWidth ?? iconSize,
        height: iconHeight ?? iconSize,
        color: iconColor,
      );
    } else {
      return Icon(prefixIcon ?? Icons.menu, color: iconColor, size: iconSize);
    }
  }
}
