import 'package:flutter/material.dart';

import '../../responsiveness/responsive.dart';
import '../../theme/colors.dart';

class GiCircularButton extends StatefulWidget {
  const GiCircularButton({
    required this.onTap,
    this.size = 24,
    required this.child,
    this.gradient = primaryGradient,
    super.key,
  });

  final VoidCallback onTap;
  final double? size;
  final Widget child;
  final Gradient? gradient;

  @override
  State<GiCircularButton> createState() => _GiCircularButtonState();
}

class _GiCircularButtonState extends State<GiCircularButton> {
  @override
  Widget build(BuildContext context) {
    final handledSize =
        widget.size != null ? Responsive.getSize(widget.size!) : null;

    return InkWell(
      onTap: widget.onTap,
      child: Container(
        height: handledSize,
        width: handledSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: widget.gradient,
          shape: BoxShape.circle,
        ),
        child: widget.child,
      ),
    );
  }
}
