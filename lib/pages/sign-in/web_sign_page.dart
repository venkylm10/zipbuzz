import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/pages/sign-in/sign_in_page.dart';
import 'package:zipbuzz/pages/welcome/welcome_page.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/widgets/common/custom_bezel.dart';

class WebSignInPage extends StatelessWidget {
  static const id = '/web_sign_in';
  const WebSignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBezel(
        child: Stack(
          children: [
            Positioned.fill(
              child: Consumer(
                builder: (context, ref, child) {
                  final pageDetails = ref.read(onboardingDetailsProvider);
                  return CachedNetworkImage(
                    fadeInDuration: const Duration(milliseconds: 1000),
                    imageUrl: pageDetails.last.imageUrl,
                    placeholder: (context, url) {
                      return Image.asset(
                        Assets.welcomeImage.welcome3,
                        fit: BoxFit.cover,
                      );
                    },
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Builder(builder: (context) {
                final height = MediaQuery.of(context).size.height;
                final width = height * 1484 / 2000; // don't change
                return Padding(
                  padding: EdgeInsets.all(width * 0.1),
                  child: const SignInSheet(),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
