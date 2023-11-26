import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zipbuzz/constants/colors.dart';

class AppStyles {
  static final poppins = GoogleFonts.poppins();
  static final extraLarge = GoogleFonts.poppins(
    textStyle: const TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 28,
      color: AppColors.textColor,
    ),
  );
  static final h1 = GoogleFonts.poppins(
    textStyle: const TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 24,
      color: AppColors.textColor,
    ),
  );
  static final h2 = GoogleFonts.poppins(
    textStyle: const TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 18,
      color: AppColors.textColor,
    ),
  );
  static final h3 = GoogleFonts.poppins(
    textStyle: const TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 16,
      color: AppColors.textColor,
    ),
  );
  static final h4 = GoogleFonts.poppins(
    textStyle: const TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 14,
      color: AppColors.textColor,
    ),
  );
  static final h5 = GoogleFonts.poppins(
    textStyle: const TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 12,
      color: AppColors.textColor,
    ),
  );
}
