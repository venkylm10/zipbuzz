import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/pages/sign-in/sign_in_page.dart';
import 'package:zipbuzz/pages/welcome/welcome_page.dart';
import 'package:zipbuzz/utils/constants/assets.dart';

class WebSignInPage extends StatelessWidget {
  static const id = '/web_sign_in';
  const WebSignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        height: size.height < 400 ? 400 : size.height,
        width: size.width < 300 ? 300 : size.width,
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
                      return Container(
                        color: Colors.black,
                      );
                    },
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width*0.25),
                child: SignInSheet(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
