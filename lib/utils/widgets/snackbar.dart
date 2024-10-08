import 'package:flutter/material.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

void showSnackBar({String? message = "coming soon!", int? duration = 1}) {
  if (scaffoldMessengerKey.currentState != null) {
    scaffoldMessengerKey.currentState!.removeCurrentSnackBar();
    scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: duration!),
        content: Container(
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minHeight: 40),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderGrey),
          ),
          child: Center(
            child: Text(
              message!,
              style: AppStyles.h5.copyWith(color: Colors.white),
              softWrap: true,
            ),
          ),
        ),
      ),
    );
  }
}
