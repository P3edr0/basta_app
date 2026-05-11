import 'package:flutter/material.dart';

import '../../responsiveness/gi_font_style.dart';
import '../../responsiveness/responsive.dart';
import '../../theme/colors.dart';

class GiHomeCard extends StatelessWidget {
  const GiHomeCard({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
    this.onTap,
  });
  final String title;
  final String content;
  final String icon;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(Responsive.getSize(16)),
          decoration: BoxDecoration(
            color: secondaryColor,
            border: Border.all(color: accentColor, width: 2),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                offset: Offset(2, -2),
                blurRadius: 6,
                spreadRadius: 2,
                color: accentColor.withValues(alpha: 0.3),
              ),
              BoxShadow(
                offset: Offset(-2, -2),
                blurRadius: 6,
                spreadRadius: 2,

                color: accentColor.withValues(alpha: 0.3),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(Responsive.getSize(10)),
                child: Image.asset(icon),
              ),
              Text(
                title,
                style: BasFontStyle.bodyLargeBoldSec.copyWith(color: darkGrey),
              ),
              Text(content, style: BasFontStyle.bodySec.copyWith(color: grey)),
            ],
          ),
        ),
      ),
    );
  }
}
