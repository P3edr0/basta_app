import 'package:flutter/material.dart';

import '../../responsiveness/responsive.dart';
import '../../theme/colors.dart';

class DashLoadingContent extends StatelessWidget {
  const DashLoadingContent({super.key, this.value});
  final double? value;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: Responsive.getSize(200),
      width: size.width,
      decoration: const BoxDecoration(gradient: secondaryGradient),
      child: Center(
        child: SizedBox(
          width: Responsive.getSize(50),
          height: Responsive.getSize(50),
          child: CircularProgressIndicator(strokeWidth: 4, value: value),
        ),
      ),
    );
  }
}
