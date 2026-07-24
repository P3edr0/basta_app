import 'package:flutter/material.dart';

import '../../responsiveness/responsive.dart';
import '../../theme/colors.dart';

class BasStepByStep extends StatelessWidget {
  const BasStepByStep({
    super.key,
    required this.steps,
    required this.currentStep,
  });
  final int steps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: steps,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _step(true);
        }

        if (index <= currentStep - 1) {
          return Row(
            children: [
              Container(
                height: 3,
                width: Responsive.getSize(60),
                color: primaryColor,
              ),
              _step(true),
            ],
          );
        } else {
          return Row(
            children: [
              Container(
                height: 1,
                width: Responsive.getSize(60),
                color: primaryColor,
              ),
              _step(false),
            ],
          );
        }
      },
    );
  }

  Widget _step(bool isSelected) {
    if (isSelected) {
      return CircleAvatar(
        backgroundColor: primaryColor,
        radius: 15,
        child: CircleAvatar(
          backgroundColor: primaryColor,
          radius: 12,
          child: Icon(Icons.check, color: secondaryColor, size: 16),
        ),
      );
    }

    return CircleAvatar(
      backgroundColor: primaryColor,
      radius: 15,
      child: CircleAvatar(
        backgroundColor: secondaryColor,
        radius: 12,
        child: CircleAvatar(backgroundColor: primaryFocusColor, radius: 6),
      ),
    );
  }
}
