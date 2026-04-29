import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'responsive.dart';

//////////////////////// PRIMARY FONT STYLE ////////////////////////

abstract class GiFontStyle {
  static TextStyle h3 = GoogleFonts.roboto().copyWith(
    fontSize: Responsive.getFontValue(22),
    color: Colors.black,
  );
  static TextStyle h4 = GoogleFonts.roboto().copyWith(
    fontSize: Responsive.getFontValue(20),
    color: Colors.black,
  );

  static TextStyle title = GoogleFonts.roboto().copyWith(
    fontSize: Responsive.getFontValue(18),
    color: Colors.black,
  );
  static TextStyle bodyLarge = GoogleFonts.roboto().copyWith(
    fontSize: Responsive.getFontValue(16),
    color: Colors.black,
  );
  static TextStyle body = GoogleFonts.roboto().copyWith(
    fontSize: Responsive.getFontValue(14),
    color: Colors.black,
  );
  static TextStyle small = GoogleFonts.roboto().copyWith(
    fontSize: Responsive.getFontValue(12),
    color: Colors.black,
  );
  static TextStyle verySmall = GoogleFonts.roboto().copyWith(
    fontSize: Responsive.getFontValue(10),
    color: Colors.black,
  );

  //+++++++++++++++++++  BOLD FONTS +++++++++++++++++++++++++++++++++++++++

  static TextStyle h3Bold = GoogleFonts.roboto().copyWith(
    fontSize: Responsive.getFontValue(22),
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );
  static TextStyle h4Bold = GoogleFonts.roboto().copyWith(
    fontSize: Responsive.getFontValue(20),
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );

  static TextStyle titleBold = GoogleFonts.roboto().copyWith(
    fontSize: Responsive.getFontValue(18),
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );
  static TextStyle bodyLargeBold = GoogleFonts.roboto().copyWith(
    fontSize: Responsive.getFontValue(16),
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );
  static TextStyle bodyBold = GoogleFonts.roboto().copyWith(
    fontSize: Responsive.getFontValue(14),
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );

  static TextStyle smallBold = GoogleFonts.roboto().copyWith(
    fontSize: Responsive.getFontValue(12),
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );
  static TextStyle verySmallBold = GoogleFonts.roboto().copyWith(
    fontSize: Responsive.getFontValue(10),
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );

  //////////////////////// SECONDARY FONT STYLE ////////////////////////

  static TextStyle h3Sec = GoogleFonts.sourceSans3().copyWith(
    fontSize: Responsive.getFontValue(22),
    color: Colors.black,
  );
  static TextStyle h4Sec = GoogleFonts.sourceSans3().copyWith(
    fontSize: Responsive.getFontValue(20),
    color: Colors.black,
  );

  static TextStyle titleSec = GoogleFonts.sourceSans3().copyWith(
    fontSize: Responsive.getFontValue(18),
    color: Colors.black,
  );
  static TextStyle bodyLargeSec = GoogleFonts.sourceSans3().copyWith(
    fontSize: Responsive.getFontValue(16),
    color: Colors.black,
  );
  static TextStyle bodySec = GoogleFonts.sourceSans3().copyWith(
    fontSize: Responsive.getFontValue(14),
    color: Colors.black,
  );
  static TextStyle smallSec = GoogleFonts.sourceSans3().copyWith(
    fontSize: Responsive.getFontValue(12),
    color: Colors.black,
  );
  static TextStyle verySmallSec = GoogleFonts.sourceSans3().copyWith(
    fontSize: Responsive.getFontValue(10),
    color: Colors.black,
  );

  //+++++++++++++++++++  BOLD FONTS +++++++++++++++++++++++++++++++++++++++

  static TextStyle h3BoldSec = GoogleFonts.sourceSans3().copyWith(
    fontSize: Responsive.getFontValue(48),
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );
  static TextStyle h4BoldSec = GoogleFonts.sourceSans3().copyWith(
    fontSize: Responsive.getFontValue(30),
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );

  static TextStyle titleBoldSec = GoogleFonts.sourceSans3().copyWith(
    fontSize: Responsive.getFontValue(18),
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );
  static TextStyle bodyLargeBoldSec = GoogleFonts.sourceSans3().copyWith(
    fontSize: Responsive.getFontValue(16),
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );
  static TextStyle bodyBoldSec = GoogleFonts.sourceSans3().copyWith(
    fontSize: Responsive.getFontValue(14),
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );

  static TextStyle smallBoldSec = GoogleFonts.sourceSans3().copyWith(
    fontSize: Responsive.getFontValue(12),
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );
  static TextStyle verySmallBoldSec = GoogleFonts.sourceSans3().copyWith(
    fontSize: Responsive.getFontValue(10),
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );

  // static TextStyle h3 = GoogleFonts.manrope().copyWith(
  //   fontSize: Responsive.getFontValue(22),
  //   color: Colors.black,
  // );
  // static TextStyle h4 = GoogleFonts.manrope().copyWith(
  //   fontSize: Responsive.getFontValue(20),
  //   color: Colors.black,
  // );

  // static TextStyle title = GoogleFonts.manrope().copyWith(
  //   fontSize: Responsive.getFontValue(18),
  //   color: Colors.black,
  // );
  // static TextStyle bodyLarge = GoogleFonts.manrope().copyWith(
  //   fontSize: Responsive.getFontValue(16),
  //   color: Colors.black,
  // );
  // static TextStyle body = GoogleFonts.manrope().copyWith(
  //   fontSize: Responsive.getFontValue(14),
  //   color: Colors.black,
  // );
  // static TextStyle small = GoogleFonts.manrope().copyWith(
  //   fontSize: Responsive.getFontValue(12),
  //   color: Colors.black,
  // );
  // static TextStyle verySmall = GoogleFonts.manrope().copyWith(
  //   fontSize: Responsive.getFontValue(10),
  //   color: Colors.black,
  // );

  // //+++++++++++++++++++  BOLD FONTS +++++++++++++++++++++++++++++++++++++++

  // static TextStyle h3Bold = GoogleFonts.manrope().copyWith(
  //   fontSize: Responsive.getFontValue(22),
  //   color: Colors.black,
  //   fontWeight: FontWeight.bold,
  // );
  // static TextStyle h4Bold = GoogleFonts.manrope().copyWith(
  //   fontSize: Responsive.getFontValue(20),
  //   color: Colors.black,
  //   fontWeight: FontWeight.bold,
  // );

  // static TextStyle titleBold = GoogleFonts.manrope().copyWith(
  //   fontSize: Responsive.getFontValue(18),
  //   color: Colors.black,
  //   fontWeight: FontWeight.bold,
  // );
  // static TextStyle bodyLargeBold = GoogleFonts.manrope().copyWith(
  //   fontSize: Responsive.getFontValue(16),
  //   color: Colors.black,
  //   fontWeight: FontWeight.bold,
  // );
  // static TextStyle bodyBold = GoogleFonts.manrope().copyWith(
  //   fontSize: Responsive.getFontValue(14),
  //   color: Colors.black,
  //   fontWeight: FontWeight.bold,
  // );

  // static TextStyle smallBold = GoogleFonts.manrope().copyWith(
  //   fontSize: Responsive.getFontValue(12),
  //   color: Colors.black,
  //   fontWeight: FontWeight.bold,
  // );
  // static TextStyle verySmallBold = GoogleFonts.manrope().copyWith(
  //   fontSize: Responsive.getFontValue(10),
  //   color: Colors.black,
  //   fontWeight: FontWeight.bold,
  // );

  // //////////////////////// SECONDARY FONT STYLE ////////////////////////

  // static TextStyle h3Sec = GoogleFonts.plusJakartaSans().copyWith(
  //   fontSize: Responsive.getFontValue(22),
  //   color: Colors.black,
  // );
  // static TextStyle h4Sec = GoogleFonts.plusJakartaSans().copyWith(
  //   fontSize: Responsive.getFontValue(20),
  //   color: Colors.black,
  // );

  // static TextStyle titleSec = GoogleFonts.plusJakartaSans().copyWith(
  //   fontSize: Responsive.getFontValue(18),
  //   color: Colors.black,
  // );
  // static TextStyle bodyLargeSec = GoogleFonts.plusJakartaSans().copyWith(
  //   fontSize: Responsive.getFontValue(16),
  //   color: Colors.black,
  // );
  // static TextStyle bodySec = GoogleFonts.plusJakartaSans().copyWith(
  //   fontSize: Responsive.getFontValue(14),
  //   color: Colors.black,
  // );
  // static TextStyle smallSec = GoogleFonts.plusJakartaSans().copyWith(
  //   fontSize: Responsive.getFontValue(12),
  //   color: Colors.black,
  // );
  // static TextStyle verySmallSec = GoogleFonts.plusJakartaSans().copyWith(
  //   fontSize: Responsive.getFontValue(10),
  //   color: Colors.black,
  // );

  // //+++++++++++++++++++  BOLD FONTS +++++++++++++++++++++++++++++++++++++++

  // static TextStyle h3BoldSec = GoogleFonts.plusJakartaSans().copyWith(
  //   fontSize: Responsive.getFontValue(48),
  //   color: Colors.black,
  //   fontWeight: FontWeight.bold,
  // );
  // static TextStyle h4BoldSec = GoogleFonts.plusJakartaSans().copyWith(
  //   fontSize: Responsive.getFontValue(30),
  //   color: Colors.black,
  //   fontWeight: FontWeight.bold,
  // );

  // static TextStyle titleBoldSec = GoogleFonts.plusJakartaSans().copyWith(
  //   fontSize: Responsive.getFontValue(18),
  //   color: Colors.black,
  //   fontWeight: FontWeight.bold,
  // );
  // static TextStyle bodyLargeBoldSec = GoogleFonts.plusJakartaSans().copyWith(
  //   fontSize: Responsive.getFontValue(16),
  //   color: Colors.black,
  //   fontWeight: FontWeight.bold,
  // );
  // static TextStyle bodyBoldSec = GoogleFonts.plusJakartaSans().copyWith(
  //   fontSize: Responsive.getFontValue(14),
  //   color: Colors.black,
  //   fontWeight: FontWeight.bold,
  // );

  // static TextStyle smallBoldSec = GoogleFonts.plusJakartaSans().copyWith(
  //   fontSize: Responsive.getFontValue(12),
  //   color: Colors.black,
  //   fontWeight: FontWeight.bold,
  // );
  // static TextStyle verySmallBoldSec = GoogleFonts.plusJakartaSans().copyWith(
  //   fontSize: Responsive.getFontValue(10),
  //   color: Colors.black,
  //   fontWeight: FontWeight.bold,
  // );
}
