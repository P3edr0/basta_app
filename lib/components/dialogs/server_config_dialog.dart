import 'package:flutter/material.dart';
import 'package:gina/components/textfields/small_textfield.dart';
import 'package:gina/responsiveness/responsive.dart';

import '../../responsiveness/gi_font_style.dart';
import '../../theme/colors.dart';
import '../buttons/rounded_button.dart';

class ServerConfigDialog {
  const ServerConfigDialog();

  static Future show({
    required TextEditingController serverUrlController,
    required TextEditingController roomNameController,
    required TextEditingController participantTokenController,
    required Function() saveServerDataCallback,

    required BuildContext context,
  }) async {
    return await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            scrollable: true,
            title: Text(
              "Alterar dados do servidor",
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                JackSmallTextfield(
                  hasLabel: true,
                  label: Text(
                    "Server Url",
                    style: BasFontStyle.bodyBold.copyWith(color: primaryColor),
                  ),

                  controller: serverUrlController,
                  hint: "Server Url",
                ),
                SizedBox(height: Responsive.getSize(20)),

                JackSmallTextfield(
                  hasLabel: true,
                  label: Text(
                    "Room name",
                    style: BasFontStyle.bodyBold.copyWith(color: primaryColor),
                  ),

                  controller: roomNameController,
                  hint: "Room name",
                ),
                SizedBox(height: Responsive.getSize(20)),
                JackSmallTextfield(
                  hasLabel: true,
                  label: Text(
                    "Participant Token",
                    style: BasFontStyle.bodyBold.copyWith(color: primaryColor),
                  ),

                  controller: participantTokenController,
                  hint: "Participant Token",
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              BasRoundedButton.solid(
                color: success,
                onTap: () {
                  saveServerDataCallback();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'SALVAR',
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
