import 'package:flutter/material.dart';

import '../../responsiveness/gi_font_style.dart';
import '../../responsiveness/responsive.dart';
import '../../theme/colors.dart';

class GiSecondaryDropdown extends StatefulWidget {
  const GiSecondaryDropdown({
    super.key,
    required this.selectedItem,
    required this.items,
    required this.textColor,
    this.onChanged,
    this.contentColor = accentColor,
    this.fontSize = 12,
    this.height = 40,
    this.isUnderlineBorder = false,
    this.backgroundButtonColor = secondaryColor,
  });
  final String selectedItem;
  final List<String> items;
  final Color textColor;
  final Color contentColor;
  final Color backgroundButtonColor;
  final double fontSize;
  final double height;
  final Function(String? value)? onChanged;
  final bool isUnderlineBorder;
  @override
  State<GiSecondaryDropdown> createState() => _GiSecondaryDropdownState();
}

class _GiSecondaryDropdownState extends State<GiSecondaryDropdown> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.getSize(8.0)),
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.backgroundButtonColor,

        borderRadius:
            widget.isUnderlineBorder
                ? BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                )
                : BorderRadius.circular(30),
        border:
            widget.isUnderlineBorder
                ? Border(
                  bottom: BorderSide(color: widget.contentColor, width: 1),
                )
                : null,
      ),
      height: Responsive.getSize(widget.height),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: secondaryColor,
          icon: Icon(
            Icons.keyboard_arrow_down_outlined,
            color: widget.contentColor,
            size: Responsive.getSize(24),
          ),
          focusColor: widget.contentColor.withValues(alpha: 0.1),
          value: widget.selectedItem,
          items:
              widget.items
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style:
                            widget.isUnderlineBorder
                                ? BasFontStyle.bodyBoldSec.copyWith(
                                  color: widget.contentColor,
                                )
                                : BasFontStyle.bodyBold.copyWith(
                                  color: widget.contentColor,
                                ),
                      ),
                    ),
                  )
                  .toList(),
          onChanged: (item) {
            if (widget.onChanged == null) return;
            widget.onChanged!(item);
          },
        ),
      ),
    );
  }
}
