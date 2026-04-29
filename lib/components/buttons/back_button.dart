import 'package:flutter/material.dart';
import 'package:gina/responsiveness/responsive.dart';

import '../../theme/colors.dart';

class GiBackButton extends StatelessWidget {
  const GiBackButton({super.key, this.onTap}) : isTransparent = false;
  const GiBackButton.transparent({super.key, this.onTap})
    : isTransparent = true;
  final void Function()? onTap;
  final bool isTransparent;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: InkWell(
          // gradient: isTransparent ? null : primaryGradient,
          onTap: () async {
            if (onTap != null) {
              onTap!();
              return;
            }
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            size: Responsive.getSize(30),

            color: isTransparent ? primaryColor : secondaryColor,
          ),
        ),
      ),
    );
  }
}
