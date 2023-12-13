import 'package:flutter/material.dart';
import 'package:zipbuzz/utils/constants/colors.dart';

Column broadDivider({double? gap = 32}) {
  return Column(
    children: [
      SizedBox(height: gap),
      Divider(color: AppColors.borderGrey.withOpacity(0.5), height: 1),
      SizedBox(height: gap),
    ],
  );
}
