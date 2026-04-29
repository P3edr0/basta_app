import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'formatter.dart';

class CpfFormatter extends Formatter {
  static final maskFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9a-z]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  String clearMask() {
    return '';
  }
}
