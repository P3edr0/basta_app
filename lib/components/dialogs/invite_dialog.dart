import 'package:flutter/material.dart';
import 'package:gina/responsiveness/responsive.dart';

import '../../responsiveness/gi_font_style.dart';
import '../../theme/colors.dart';
import '../buttons/rounded_button.dart';

class InviteDialog {
  const InviteDialog();

  static Future show({
    required String title,
    required String content,
    required String refuseButton,
    required String acceptButton,
    required Function() acceptCallback,
    required Function() refuseCallback,

    required BuildContext context,
  }) async {
    return await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title, textAlign: TextAlign.center),
            content: Text(content, textAlign: TextAlign.center),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              DashRoundedButton.solid(
                width: Responsive.getSize(120),

                color: darkGrey,
                onTap: () {
                  refuseCallback();
                  Navigator.of(context).pop();
                },
                child: Text(
                  refuseButton,
                  style: BasFontStyle.bodyBoldSec.copyWith(
                    color: secondaryColor,
                  ),
                ),
              ),
              DashRoundedButton.solid(
                width: Responsive.getSize(120),
                color: primaryColor,
                onTap: () {
                  acceptCallback();
                  Navigator.of(context).pop();
                },

                child: Text(
                  acceptButton,
                  style: BasFontStyle.bodyBoldSec.copyWith(
                    color: secondaryColor,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
