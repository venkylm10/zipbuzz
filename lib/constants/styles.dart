import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zipbuzz/constants/colors.dart';

class AppStyles {
  static final titleStyle = GoogleFonts.poppins(
    textStyle: const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 18,
      color: AppColors.textColor,
    ),
  );
  static final normalTextStyle = GoogleFonts.poppins(
    textStyle: const TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 12,
      color: AppColors.textColor,
    ),
  );
}
