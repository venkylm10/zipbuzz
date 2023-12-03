import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/controllers/home_tab_controller.dart';
import 'package:zipbuzz/main.dart';
import 'package:zipbuzz/services/auth_services.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

class SignInSheet extends ConsumerWidget {
  static const id = '/sign_in';
  const SignInSheet({super.key});

  void googleSignIn(WidgetRef ref) {
    ref.read(authServicesProvider).signInWithGoogle();
    navigatorKey.currentState!.pop();
    ref.read(homeTabControllerProvider.notifier).updateIndex(0);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryColor.withOpacity(0.3),
                AppColors.primaryColor,
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(32),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Sign In",
                style: AppStyles.h1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              SignInButton(
                title: "Google",
                iconPath: Assets.icons.google_logo,
                onTap: () => googleSignIn(ref),
              ),
              const SizedBox(height: 8),
              SignInButton(
                title: "Apple",
                iconPath: Assets.icons.apple_logo,
                onTap: showSnackBar,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: showSnackBar,
                child: Container(
                  height: 56,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white),
                  ),
                  child: Center(
                    child: Text(
                      "Explore as Guest",
                      style: AppStyles.h4.copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignInButton extends StatelessWidget {
  final String iconPath;
  final String title;
  final void Function()? onTap;
  const SignInButton({
    super.key,
    required this.iconPath,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                iconPath,
                height: 24,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: AppStyles.h3.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
