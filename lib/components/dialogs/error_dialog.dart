import 'package:flutter/material.dart';

import '../../responsiveness/gi_font_style.dart';
import '../../responsiveness/responsive.dart';
import '../../theme/colors.dart';
import '../buttons/rounded_button.dart';

class ErrorDialog {
  const ErrorDialog();

  static Future show({
    required String title,
    required String content,
    required BuildContext context,
  }) async {
    return await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title, textAlign: TextAlign.center),
            content: Text(content, textAlign: TextAlign.center),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              GiRoundedButton(
                height: 50,
                width: Responsive.getSize(140),
                onTap: () => Navigator.of(context).pop(),
                child: Text(
                  "Fechar",
                  textAlign: TextAlign.center,
                  style: GiFontStyle.titleBold.copyWith(color: secondaryColor),
                ),
              ),
            ],
          ),
    );
  }
}
