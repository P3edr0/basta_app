import 'package:flutter/material.dart';

import '../../responsiveness/gi_font_style.dart';
import '../../responsiveness/responsive.dart';
import '../../theme/colors.dart';
import '../buttons/rounded_button.dart';

class SuccessDialog {
  const SuccessDialog();

  static Future show(String title, String content, BuildContext context) async {
    return await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title, textAlign: TextAlign.center),
            content: Text(content, textAlign: TextAlign.center),
            actions: [
              GiRoundedButton(
                onTap: () => Navigator.of(context).pop(),

                child: Text(
                  'Fechar',
                  style: GiFontStyle.bodyBoldSec.copyWith(
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
        Future.delayed(const Duration(seconds: 3), () {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        });
        return AlertDialog(
          title: Text(title, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.done_all,
                color: primaryColor,
                size: Responsive.getSize(40),
              ),
              Text(content, textAlign: TextAlign.center),
            ],
          ),
        );
      },
    );
  }
}
