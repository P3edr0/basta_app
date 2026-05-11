import 'package:flutter/material.dart';

import '../../responsiveness/gi_font_style.dart';
import '../../responsiveness/responsive.dart';
import '../../theme/colors.dart';
import '../buttons/back_button.dart';

class GiAppBar extends StatelessWidget {
  const GiAppBar({
    super.key,
    required this.title,
    this.withPadding = false,
    this.onTap,
  }) : secondary = false;
  const GiAppBar.secondary({
    super.key,
    required this.title,
    this.withPadding = false,
    this.onTap,
  }) : secondary = true;
  final String title;
  final bool secondary;
  final bool withPadding;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    if (secondary) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.getSize(withPadding ? 24 : 0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GiBackButton.transparent(onTap: onTap),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                title,
                style: BasFontStyle.titleBoldSec.copyWith(color: primaryColor),
              ),
            ),
            SizedBox(width: Responsive.getSize(40)),
          ],
        ),
      );
    }
    return Positioned(
      top: Responsive.getSize(Responsive.getSize(4)),
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GiBackButton.transparent(onTap: onTap),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              title,
              style: BasFontStyle.bodyLargeBoldSec.copyWith(
                color: primaryColor,
              ),
            ),
          ),
          SizedBox(width: Responsive.getSize(40)),
        ],
      ),
    );
  }
}
