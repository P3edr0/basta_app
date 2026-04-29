import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gina/utils/enums/guardian_status.dart';

import '../../responsiveness/gi_font_style.dart';
import '../../responsiveness/responsive.dart';
import '../../theme/colors.dart';

class AngelCard extends StatelessWidget {
  const AngelCard({
    super.key,
    required this.content,
    required this.title,
    required this.icon,
    this.onTap,
  }) : type = 1,
       status = null,
       image = null;
  const AngelCard.secondary({
    super.key,
    required this.content,
    required this.title,
    required this.image,
    this.onTap,
  }) : icon = null,

       status = null,

       type = 2;
  const AngelCard.tertiary({
    super.key,
    required this.content,
    required this.title,
    required this.image,
    required this.status,
    this.onTap,
  }) : type = 3,
       icon = null;
  final IconData? icon;
  final String? title;
  final String? content;
  final int type;
  final String? image;
  final GuardianStatus? status;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    if (type == 1) {
      return InkWell(
        onTap: onTap,

        child: Container(
          padding: EdgeInsets.all(Responsive.getSize(16)),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(30),
          ),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: secondaryColor,
                  size: Responsive.getSize(24),
                ),
              ),
              SizedBox(width: Responsive.getSize(10)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title!,
                    style: GiFontStyle.bodyLargeBoldSec.copyWith(
                      color: primaryColor,
                    ),
                  ),
                  Text(content!, style: GiFontStyle.body.copyWith(color: grey)),
                ],
              ),
              Spacer(),
              Icon(
                Icons.chevron_right,
                size: Responsive.getSize(24),
                color: primaryColor,
              ),
            ],
          ),
        ),
      );
    }
    if (type == 2) {
      final hasImage = image != null;
      return InkWell(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: Responsive.getSize(16)),
          padding: EdgeInsets.all(Responsive.getSize(16)),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(30),
          ),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: primaryColor,
                backgroundImage:
                    hasImage ? MemoryImage(base64Decode(image!)) : null,

                radius: 28,
              ),
              SizedBox(width: Responsive.getSize(10)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title!,
                    style: GiFontStyle.bodyLargeBoldSec.copyWith(
                      color: darkGrey,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: Responsive.getSize(2)),
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: success,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: secondaryColor,
                          size: Responsive.getSize(8),
                        ),
                      ),

                      Text(
                        content!,
                        style: GiFontStyle.bodyBold.copyWith(color: success),
                      ),
                    ],
                  ),
                ],
              ),
              Spacer(),
              Icon(
                Icons.delete_forever_outlined,
                size: Responsive.getSize(24),
                color: grey,
              ),
            ],
          ),
        ),
      );
    }
    final hasImage = image != null;

    return InkWell(
      onTap: onTap,

      child: Container(
        padding: EdgeInsets.all(Responsive.getSize(16)),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(60),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: primaryColor,
              backgroundImage:
                  hasImage ? MemoryImage(base64Decode(image!)) : null,
              radius: 28,
            ),

            SizedBox(width: Responsive.getSize(10)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title!,
                  style: GiFontStyle.bodyLargeBoldSec.copyWith(color: darkGrey),
                ),
                Text(content!, style: GiFontStyle.body.copyWith(color: grey)),
              ],
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.getSize(10),
                vertical: Responsive.getSize(6),
              ),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: _getColor(),
              ),
              child: Text(
                _getText(),
                style: GiFontStyle.bodyBold.copyWith(color: secondaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case GuardianStatus.waiting:
        return accentColor;
      case GuardianStatus.none:
        return primaryColor;
      case GuardianStatus.invited:
        return warning;
      case GuardianStatus.accepted:
        return success;

      default:
        return grey;
    }
  }

  String _getText() {
    switch (status) {
      case GuardianStatus.waiting:
        return "Aguardando";
      case GuardianStatus.none:
        return "+ Adicionar";
      case GuardianStatus.invited:
        return "Responder";
      case GuardianStatus.accepted:
        return "Adicionada";

      default:
        return "Recusado";
    }
  }
}
