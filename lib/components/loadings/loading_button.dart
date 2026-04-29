import 'package:flutter/material.dart';

import '../../responsiveness/responsive.dart';
import '../../theme/colors.dart';

class BasLoadingButton extends StatelessWidget {
  const BasLoadingButton({
    super.key,
    this.color = secondaryColor,
    this.size = 30,
    this.strokeWidget = 4,
  });
  final Color? color;
  final double size;
  final double strokeWidget;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Responsive.getSize(size + 10),
      width: Responsive.getSize(size + 10),
      child: Center(
        child: SizedBox(
          width: Responsive.getSize(size),
          height: Responsive.getSize(size),
          child: CircularProgressIndicator(
            strokeWidth: strokeWidget,
            color: color,
          ),
        ),
      ),
    );
  }
}
