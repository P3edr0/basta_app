import 'package:flutter/material.dart';

const primaryColor = Color(0xFFFF5000); // Color.fromRGBO(107, 58, 214, 1);
const primaryFocusColor = Color.fromRGBO(
  255,
  149,
  100,
  1,
); // Color.fromRGBO(143, 96, 250, 1);
const movidaColor = Color.fromARGB(255, 255, 80, 0);

// const primaryFocusColor = Color.fromRGBO(240, 80, 0, .6);
const alertColor = Color.fromRGBO(222, 52, 0, 1);
const accentColor = Color.fromRGBO(189, 12, 59, 1);
const secondaryColor = Colors.white;
const black = Colors.black;

const transparent = Colors.transparent;

const warning = Colors.amber;

const veryDarkBlue = Color.fromRGBO(0, 13, 29, 1);
const success = Color.fromRGBO(22, 163, 74, 1);
const mediumDarkBlue = Color.fromRGBO(0, 31, 59, 1);
const blue = Color.fromRGBO(1, 136, 255, 1);
const blueGrey = Color.fromRGBO(94, 106, 130, 1);
const grey = Color.fromRGBO(92, 95, 99, 1);
const darkGrey = Color.fromRGBO(47, 51, 54, 1);
const mediumGrey = Color.fromRGBO(231, 232, 236, 1);
const lightGrey = Color.fromRGBO(250, 249, 251, 1);

const LinearGradient primaryGradient = LinearGradient(
  colors: [primaryColor, primaryFocusColor],
);
const secondaryGradient = LinearGradient(
  colors: [accentColor, primaryFocusColor],
);
final greyGradient = LinearGradient(
  colors: [Colors.white, Colors.grey.shade300],
);

MaterialColor createMaterialColor(Color color) {
  final strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }

  for (final strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }

  return MaterialColor(color.value, swatch);
}
