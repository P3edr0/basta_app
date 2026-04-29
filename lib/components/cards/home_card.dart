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
            borderRadius: BorderRadius.circular(30),
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
                style: GiFontStyle.bodyLargeBoldSec.copyWith(color: darkGrey),
              ),
              Text(content, style: GiFontStyle.bodySec.copyWith(color: grey)),
            ],
          ),
        ),
      ),
    );
  }
}
