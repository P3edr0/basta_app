import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TneTextTheme {
  TneTextTheme._();

  static TextTheme lightTextTheme = TextTheme(
    bodyMedium: GoogleFonts.manropeTextTheme().bodyMedium!.copyWith(
      color: Colors.black,
    ),
    headlineLarge: GoogleFonts.manropeTextTheme().headlineLarge!.copyWith(
      color: Colors.black,
    ),
    headlineMedium: GoogleFonts.manropeTextTheme().headlineMedium!.copyWith(
      color: Colors.black,
    ),
  );

  static TextTheme darkTextTheme = TextTheme(
    bodyMedium: GoogleFonts.manropeTextTheme().bodyMedium!.copyWith(
      color: Colors.white,
    ),
    headlineLarge: GoogleFonts.manropeTextTheme().headlineLarge!.copyWith(
      color: Colors.white,
    ),
    headlineMedium: GoogleFonts.manropeTextTheme().headlineMedium!.copyWith(
      color: Colors.white,
    ),
  );
}
