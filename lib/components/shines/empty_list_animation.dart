import 'package:flutter/material.dart';
import 'package:gina/responsiveness/gi_font_style.dart';
import 'package:lottie/lottie.dart';

import '../../theme/colors.dart';
import '../../utils/assets/app_assets.dart';

class BasEmptyAnimation extends StatelessWidget {
  const BasEmptyAnimation({super.key, required this.content});
  final String content;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Lottie.asset(BasAppAssets.emptyList),
        Text(
          content,
          style: BasFontStyle.bodyLargeBold.copyWith(color: primaryColor),
        ),
      ],
    );
  }
}
