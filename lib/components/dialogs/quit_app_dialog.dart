import 'package:flutter/material.dart';

import '../../responsiveness/gi_font_style.dart';
import '../../responsiveness/responsive.dart';
import '../../theme/colors.dart';
import '../buttons/rounded_button.dart';

class QuitAppDialog {
  const QuitAppDialog();

  static Future<bool> show(
    String title,
    String content,
    BuildContext context,
  ) async {
    return await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title, textAlign: TextAlign.center),
            content: Text(content, textAlign: TextAlign.center),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              GiRoundedButton(
                width: Responsive.getSize(120),
                onTap: () => Navigator.of(context).pop(false),
                child: Text(
                  "Voltar",
                  textAlign: TextAlign.center,
                  style: GiFontStyle.titleBold.copyWith(color: secondaryColor),
                ),
              ),
              GiRoundedButton.solid(
                color: secondaryColor,
                height: 48,

                width: Responsive.getSize(100),
                onTap: () => Navigator.of(context).pop(true),
                child: Text(
                  "Sair",
                  textAlign: TextAlign.center,
                  style: GiFontStyle.titleBold.copyWith(color: grey),
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
        Future.delayed(Durations.extralong4, () {
          if (context.mounted) {
            Navigator.of(context).pop(false);
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
