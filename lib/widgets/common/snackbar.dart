import 'package:flutter/material.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/main.dart';

void showSnackBar({String? message = "Yet to be implemented"}) {
  scaffoldMessengerKey.currentState!.removeCurrentSnackBar();
  scaffoldMessengerKey.currentState!.showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: const Duration(seconds: 1),
      content: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Center(
          child: Text(
            message!,
            style: AppStyles.h4.copyWith(color: Colors.white),
          ),
        ),
      ),
    ),
  );
}
