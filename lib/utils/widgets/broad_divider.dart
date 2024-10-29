import 'package:flutter/material.dart';
import 'package:zipbuzz/utils/constants/colors.dart';

Column broadDivider({double? gap = 14, bool host = false}) {
  return Column(
    children: [
      SizedBox(height: gap),
      Divider(
          color: host
              ? AppColors.primaryColor.withOpacity(0.5)
              : AppColors.borderGrey.withOpacity(0.5),
          height: 1),
      SizedBox(height: gap),
    ],
  );
}
