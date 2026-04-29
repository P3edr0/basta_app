import 'package:flutter/material.dart';

import '../../responsiveness/responsive.dart';
import '../../theme/colors.dart';

class JackOutlineButton extends StatelessWidget {
  const JackOutlineButton({
    super.key,
    required this.child,
    required this.onTap,
    this.borderColor = secondaryColor,
    this.height = 32,
    this.radius = 30,
    this.borderWidth = 1,
    this.width,
    this.padding = 20,
  });
  final VoidCallback? onTap;
  final Widget child;
  final Color borderColor;
  final double? width;
  final double? height;
  final double radius;
  final double borderWidth;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final handledWidth = width != null ? Responsive.getSize(width!) : null;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: Responsive.getSize(height!),
        width: handledWidth,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: Responsive.getSize(padding)),
        decoration: BoxDecoration(
          color: transparent,
          border: Border.all(color: borderColor, width: borderWidth),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: child,
      ),
    );
  }
}
