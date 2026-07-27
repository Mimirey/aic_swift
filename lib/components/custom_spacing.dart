import 'package:flutter/widgets.dart';

class CustomSpacing extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;

  const CustomSpacing({super.key, this.width, this.height, this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: child,
    );
  }
}