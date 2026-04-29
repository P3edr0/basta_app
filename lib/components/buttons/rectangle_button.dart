import 'package:flutter/material.dart';

import '../../responsiveness/responsive.dart';
import '../../theme/colors.dart';

class JackRectangleButton extends StatelessWidget {
  const JackRectangleButton({
    super.key,
    required this.child,
    required this.onTap,
    this.isSelected = false,
  });
  final VoidCallback onTap;
  final Widget child;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: Responsive.getSize(10)),
        height: Responsive.getSize(32),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      ),
    );
  }
}
