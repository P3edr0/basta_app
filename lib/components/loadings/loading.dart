import 'package:flutter/material.dart';
import 'package:gina/responsiveness/gi_font_style.dart';
import 'package:gina/utils/assets/app_assets.dart';

import '../../responsiveness/responsive.dart';
import '../../theme/colors.dart';

class DashPageLoading extends StatelessWidget {
  const DashPageLoading({super.key}) : isSecondary = false, title = null;
  const DashPageLoading.secondary({super.key, required this.title})
    : isSecondary = true;
  final bool isSecondary;
  final String? title;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (isSecondary) {
      return Container(
        height: size.height,
        width: size.width,
        decoration: const BoxDecoration(gradient: primaryGradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Spacer(),
            Image.asset(GiAppAssets.logo, height: Responsive.getSize(200)),
            Spacer(),
            Text(
              title!,
              style: BasFontStyle.bodyLargeBold.copyWith(color: secondaryColor),
            ),
            SizedBox(
              width: double.infinity,
              height: Responsive.getSize(10),
              child: const LinearProgressIndicator(color: primaryColor),
            ),
          ],
        ),
      );
    }
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
