import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../responsiveness/gi_font_style.dart';
import '../../responsiveness/responsive.dart';
import '../../theme/colors.dart';
import '../../theme/icons.dart';

class GiTextfield extends StatefulWidget {
  const GiTextfield({
    super.key,
    this.controller,
    required this.hint,
    this.onFieldSubmitted,
    this.isObscureText = false,
    this.label,
    this.enable = true,
    this.suffix,
    this.prefix,
    this.formatter,
    this.onChanged,
    this.validator,
    this.onEditingComplete,
    this.inputType = TextInputType.emailAddress,
    this.inputAction = TextInputAction.done,
    this.maxLength,
    this.height = 56,
    this.radius = 10,
    this.maxLines = 1,
    this.focusNode,
    this.textColor,
    this.backgroundColor = mediumGrey,
    this.alignment = Alignment.center,
    this.padding = EdgeInsets.zero,
    this.labelPositionEnum = LabelPositionEnum.outside,
  });

  final TextEditingController? controller;
  final String hint;
  final AlignmentGeometry alignment;
  final Widget? suffix;
  final Widget? prefix;
  final FormFieldValidator? validator;
  final String? label;
  final bool isObscureText;
  final bool enable;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final double radius, height;
  final int? maxLength;
  final int? maxLines;
  final List<TextInputFormatter>? formatter;
  final Function(String)? onChanged;
  final Function()? onEditingComplete;
  final EdgeInsets padding;
  final FocusNode? focusNode;
  final Function(String value)? onFieldSubmitted;
  final LabelPositionEnum labelPositionEnum;
  final Color? textColor;
  final Color? backgroundColor;

  @override
  State<GiTextfield> createState() => _GiTextfieldState();
}

class _GiTextfieldState extends State<GiTextfield> {
  bool isObscure = true;

  @override
  void initState() {
    super.initState();
    isObscure = widget.isObscureText;
  }

  bool hasError = false;

  @override
  Widget build(BuildContext context) {
    final hasSuffix = widget.isObscureText || widget.prefix != null;
    EdgeInsets contentPadding = EdgeInsets.only(
      top:
          hasError
              ? Responsive.getSize(18)
              : hasSuffix
              ? Responsive.getSize(8)
              : Responsive.getSize(0),
      left: Responsive.getSize(16),
    );
    EdgeInsets suffixPadding = EdgeInsets.only(
      top: hasError ? Responsive.getSize(18) : Responsive.getSize(0),
      left: Responsive.getSize(6),
    );
    Widget? handledSuffix;
    if (widget.isObscureText) {
      handledSuffix = Padding(
        padding: suffixPadding,
        child: InkWell(
          onTap: () {
            setState(() {
              isObscure = !isObscure;
            });
          },
          child: Icon(isObscure ? BasIcons.visibleOff : BasIcons.visible),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null &&
            widget.labelPositionEnum == LabelPositionEnum.outside) ...[
          Padding(
            padding: EdgeInsets.only(left: Responsive.getSize(8.0)),
            child: Text(
              widget.label!,
              style: GiFontStyle.bodyLargeBold.copyWith(color: grey),
            ),
          ),
          SizedBox(height: Responsive.getSize(2)),
        ],
        Container(
          alignment: widget.alignment,
          padding: widget.padding,
          height: Responsive.getSize(widget.height * widget.maxLines!),
          decoration: BoxDecoration(
            color: widget.enable ? widget.backgroundColor : darkGrey,

            borderRadius: BorderRadius.circular(30),
          ),
          width: double.infinity,
          child: TextFormField(
            style: GiFontStyle.bodyLargeBoldSec.copyWith(
              color: widget.textColor ?? primaryColor,
            ),
            focusNode: widget.focusNode,
            onEditingComplete: widget.onEditingComplete,
            enabled: widget.enable,
            textInputAction: widget.inputAction,
            maxLines: widget.maxLines,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: GiFontStyle.bodyLargeSec.copyWith(
                color: Color(0xff000000).withOpacity(.25),
              ),
              border: InputBorder.none,
              labelStyle: GiFontStyle.bodyBoldSec.copyWith(
                fontSize: null,
                color: widget.textColor?.withOpacity(.25) ?? primaryColor,
              ),
              suffixIcon: widget.suffix ?? handledSuffix,
              // prefix: widget.prefix,
              prefixIcon: widget.prefix,
              label:
                  widget.labelPositionEnum == LabelPositionEnum.inside &&
                          widget.label != null
                      ? Padding(
                        padding: EdgeInsets.only(
                          left: Responsive.getSize(2.0),
                          top: 4,
                        ),
                        child: Text(
                          widget.label!,
                          style: GiFontStyle.titleBold.copyWith(
                            color: widget.textColor?.withOpacity(.5),
                          ),
                        ),
                      )
                      : null,
              contentPadding: contentPadding,
            ),
            keyboardType: widget.inputType,
            obscureText: isObscure,
            inputFormatters: widget.formatter,
            onFieldSubmitted: widget.onFieldSubmitted,
            controller: widget.controller,
            validator: (value) {
              final isValid = widget.validator?.call(value);
              if (isValid != null) {
                setState(() {
                  hasError = true;
                });
              } else {
                setState(() {
                  hasError = false;
                });
              }
              return isValid;
            },
            onChanged: widget.onChanged,
            maxLength: widget.maxLength,
          ),
        ),
      ],
    );
  }
}

enum LabelPositionEnum { outside, inside, invisible }
