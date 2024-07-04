import 'package:flutter/material.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';

InkWell backButton({void Function()? onTap}) {
  return InkWell(
    onTap: () => onTap ?? navigatorKey.currentState!.pop(),
    child: Container(
      height: 32,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: const Icon(Icons.arrow_back, size: 16),
    ),
  );
}
