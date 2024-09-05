import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/pages/splash/splash_screen.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

final StreamProvider<bool> checkInternetProvider = StreamProvider<bool>((ref) {
  return checkInternetStream();
});

Stream<bool> checkInternetStream() async* {
  while (true) {
    await Future.delayed(const Duration(seconds: 3));
    yield await checkInternet();
  }
}

Future<bool> checkInternet() async {
  if (kIsWeb) return true;
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
  final bool showLoader;
  const NoInternetScreen({super.key, this.showLoader = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            if (showLoader)
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
