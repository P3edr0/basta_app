import 'package:flutter/material.dart';
import 'package:gina/responsiveness/responsive.dart';

import '../../responsiveness/gi_font_style.dart';
import '../../theme/colors.dart';
import '../../theme/icons.dart';
import '../buttons/rounded_button.dart';

class EmergencyDialog {
  const EmergencyDialog();

  static Future show(
    String title,
    String content,
    BuildContext context,
    void Function() onTap, [
    String? image,
  ]) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text(
              title,
              style: BasFontStyle.h4BoldSec,
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  BasIcons.alert,
                  size: Responsive.getSize(120),
                  color: alertColor,
                ),

                Text(
                  content,
                  style: BasFontStyle.bodyLargeBold,
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            actions: [
              BasRoundedButton(
                onTap: () {
                  Navigator.of(context).pop();
                  onTap();
                },

                child: Text(
                  'Acompanhar',
                  style: BasFontStyle.bodyBoldSec.copyWith(
                    color: secondaryColor,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  static Future closeAuto(
    String title,
    String content,
    BuildContext context,
  ) async {
    return await showDialog(
      context: context,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        });
        return AlertDialog(
          title: Text(title, textAlign: TextAlign.center),
          content: Text(content, textAlign: TextAlign.center),
        );
      },
    );
  }
}
