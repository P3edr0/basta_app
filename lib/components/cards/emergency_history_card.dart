import 'package:flutter/material.dart';

import '../../responsiveness/gi_font_style.dart';
import '../../responsiveness/responsive.dart';
import '../../theme/colors.dart';

class EmergencyHistoryCard extends StatelessWidget {
  const EmergencyHistoryCard({
    super.key,
    required this.content,
    required this.title,
    required this.image,
    this.onTap,
  });

  final String? title;
  final String? content;
  final String? image;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    final hasImage = image != null;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: Responsive.getSize(16)),
        padding: EdgeInsets.all(Responsive.getSize(16)),
        decoration: BoxDecoration(
          border: Border.all(color: primaryColor),
          color: secondaryColor,
          borderRadius: BorderRadius.circular(30),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: primaryColor,
              backgroundImage: hasImage ? NetworkImage(image!) : null,

              radius: 28,
            ),
            SizedBox(width: Responsive.getSize(10)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Solicitante",
                  style: BasFontStyle.bodyBold.copyWith(color: primaryColor),
                ),
                Text(
                  title!,
                  style: BasFontStyle.bodyLargeBoldSec.copyWith(
                    color: darkGrey,
                  ),
                ),
                SizedBox(height: Responsive.getSize(10)),

                Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      color: primaryColor,
                      size: Responsive.getSize(16),
                    ),
                    SizedBox(width: Responsive.getSize(4)),
                    Text(
                      content!,
                      style: BasFontStyle.bodyBold.copyWith(
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Spacer(),
            Icon(
              Icons.search,
              size: Responsive.getSize(24),
              color: primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
