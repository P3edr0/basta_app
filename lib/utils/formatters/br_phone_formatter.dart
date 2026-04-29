import 'package:flutter/services.dart';

class BrPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (text.length > 11) {
      text = text.substring(0, 11);
    }

    String newText;

    if (text.length <= 2) {
      newText = '(${text.substring(0, 2)}';
    } else if (text.length <= 6) {
      newText = '(${text.substring(0, 2)}) ${text.substring(2)}';
    } else if (text.length <= 10) {
      // Número completo: se tiver 8 ou 9 dígitos
      final numberPart = text.substring(2);
      if (numberPart.length <= 8) {
        // 8 dígitos
        newText = '(${text.substring(0, 2)}) '
            '${numberPart.substring(0, 4)}-${numberPart.substring(4)}';
      } else {
        // 9 dígitos
        newText = '(${text.substring(0, 2)}) '
            '${numberPart.substring(0, 2)}-${numberPart.substring(2)}';
      }
    } else {
      newText = '(${text.substring(0, 2)}) '
          '${text.substring(2, 7)}-${text.substring(7, 11)}';
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
