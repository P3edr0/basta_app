import 'package:flutter/material.dart';

import '../../responsiveness/responsive.dart';
import '../../theme/colors.dart';

class BasPageLoading extends StatelessWidget {
  const BasPageLoading({super.key});
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      decoration: const BoxDecoration(gradient: primaryGradient),
      child: Center(
        child: SizedBox(
          width: Responsive.getSize(50),
          height: Responsive.getSize(50),
          child: const CircularProgressIndicator(
            strokeWidth: 4,
            color: secondaryColor,
          ),
        ),
      ),
    );
  }
}
