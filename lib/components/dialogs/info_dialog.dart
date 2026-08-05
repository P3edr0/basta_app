import 'package:flutter/material.dart';
import 'package:gina/responsiveness/responsive.dart';

import '../../responsiveness/gi_font_style.dart';
import '../../theme/colors.dart';
import '../buttons/rounded_button.dart';

class InfoDialog {
  const InfoDialog();

  static Future show(
    String title,
    String content,
    BuildContext context, [
    String? image,
    String? errorImage,
  ]) async {
    return await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title, textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (image != null)
                  Image.network(
                    image,
                    height: Responsive.getSize(120),

                    errorBuilder: (context, _, stackTrace) {
                      return Image.asset(
                        errorImage ?? 'assets/images/error.png',
                        height: Responsive.getSize(120),
                      );
                    },
                  ),

                Text(content, textAlign: TextAlign.center),
              ],
            ),

            actions: [
              BasRoundedButton(
                onTap: () => Navigator.of(context).pop(),

                child: Text(
                  'Fechar',
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
