import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../responsiveness/gi_font_style.dart';
import '../../theme/colors.dart';

class JackSmallTextfield extends StatefulWidget {
  const JackSmallTextfield({
    super.key,
    required this.controller,
    required this.hint,
    this.prefix,
    this.onFieldSubmitted,
    this.isObscureText = false,
    this.label,
    this.enable = true,
    this.hasLabel = false,
    this.suffix,
    this.formatter,
    this.onChanged,
    this.validator,
    this.onEditingComplete,
    this.inputType = TextInputType.emailAddress,
    this.inputAction = TextInputAction.done,
    this.radius = 10,
  });
  final TextEditingController controller;
  final String hint;
  final Widget? prefix;
  final Widget? suffix;
  final FormFieldValidator? validator;
  final Widget? label;
  final bool isObscureText;
  final bool enable;
  final bool hasLabel;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final double radius;
  final List<TextInputFormatter>? formatter;
  final Function(String)? onChanged;
  final Function()? onEditingComplete;

  final Function(String value)? onFieldSubmitted;

  @override
  State<JackSmallTextfield> createState() => _JackSmallTextfieldState();
}

class _JackSmallTextfieldState extends State<JackSmallTextfield> {
  @override
  Widget build(BuildContext context) {
    late EdgeInsets contentPadding;
    if (widget.prefix == null && widget.suffix == null) {
      contentPadding = const EdgeInsets.all(0);
    } else {
      if (widget.prefix == null) {
        contentPadding = const EdgeInsets.only(top: 5, left: 20, bottom: 10);
      } else {
        contentPadding = const EdgeInsets.only(top: 6, left: 6);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.label != null) ...[widget.label!, const SizedBox(height: 5)],
        Container(
          alignment: Alignment.center,
          height: 44,
          decoration: BoxDecoration(
            border: Border.all(color: primaryFocusColor, width: 1),
            borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
          ),
          width: double.infinity,
          child: TextFormField(
            textAlign: TextAlign.center,
            onEditingComplete: widget.onEditingComplete,
            enabled: widget.enable,
            textInputAction: widget.inputAction,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: BasFontStyle.bodyLargeBold.copyWith(
                color: primaryFocusColor,
              ),
              border: InputBorder.none,
              labelStyle: BasFontStyle.bodyLargeBold,
              prefixIcon: widget.prefix,
              suffixIcon: widget.suffix,
              contentPadding: contentPadding,
            ),
            keyboardType: widget.inputType,
            obscureText: widget.isObscureText,
            inputFormatters: widget.formatter,
            onFieldSubmitted: widget.onFieldSubmitted,
            controller: widget.controller,
            validator: widget.validator,
            onChanged: widget.onChanged,
          ),
        ),
      ],
    );
  }
}
