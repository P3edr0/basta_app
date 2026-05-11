import 'package:flutter/material.dart';
import 'package:gina/responsiveness/gi_font_style.dart';

import '../../responsiveness/responsive.dart';
import '../../theme/colors.dart';

class BasSelectorButton extends StatelessWidget {
  const BasSelectorButton({
    super.key,
    required this.isSelected,
    required this.title,
    this.onTap,
  });
  final String title;
  final bool isSelected;
  final Function()? onTap;
  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          child: Container(
            alignment: Alignment.center,

            padding: EdgeInsets.symmetric(
              horizontal: Responsive.getSize(10),
              vertical: Responsive.getSize(10),
            ),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: primaryColor,
            ),
            child: Text(
              title,
              style: BasFontStyle.bodyLargeBold.copyWith(color: secondaryColor),
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.getSize(10),
            vertical: Responsive.getSize(10),
          ),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primaryColor),
            color: secondaryColor,
          ),
          child: Text(
            title,
            style: BasFontStyle.bodyLargeBold.copyWith(color: primaryColor),
          ),
        ),
      ),
    );
  }
}
