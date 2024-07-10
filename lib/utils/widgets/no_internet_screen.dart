import 'dart:io';

import 'package:flutter/material.dart';
import 'package:zipbuzz/pages/splash/splash_screen.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/back_button.dart';

Future<bool> checkInternet() async {
  try {
    final res = await InternetAddress.lookup('www.google.com');
    return res.isNotEmpty && res[0].rawAddress.isNotEmpty;
  } catch (e) {
    debugPrint("No Internet Connection");
    return false;
  }
}

class NoInternetScreen extends StatelessWidget {
  static const id = '/no-internet';
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backButton(),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(32.0).copyWith(bottom: 0),
              child: Text(
                "No Internet Connection\nPlease check your internet connection and try again.",
                style: AppStyles.h4.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightGreyColor,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            InkWell(
              onTap: () {
                checkInternet().then((value) {
                  if (value) {
                    navigatorKey.currentState!
                        .pushNamedAndRemoveUntil(SplashScreen.id, (route) => false);
                  }
                });
              },
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Icon(Icons.refresh_rounded),
              ),
            )
          ],
        ),
      ),
    );
  }
}
