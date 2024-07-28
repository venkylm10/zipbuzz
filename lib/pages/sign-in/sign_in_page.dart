import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';

import 'package:zipbuzz/controllers/navigation_controller.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/services/auth_services.dart';
import 'package:zipbuzz/pages/splash/splash_screen.dart';

class SignInSheet extends ConsumerWidget {
  static const id = '/sign_in';
  const SignInSheet({super.key});

  void googleSignIn(WidgetRef ref) {
    ref.read(homeTabControllerProvider.notifier).selectCategory(category: "");
    ref.read(homeTabControllerProvider.notifier).updateSelectedTab(AppTabs.home);
    ref.read(authServicesProvider).signInWithGoogle();
  }

  void appleSignIn(WidgetRef ref) {
    ref.read(homeTabControllerProvider.notifier).selectCategory(category: "");
    ref.read(homeTabControllerProvider.notifier).updateSelectedTab(AppTabs.home);
    ref.read(authServicesProvider).signInWithApple();
  }

  void signInGuestUser(WidgetRef ref) {
    GetStorage().write(BoxConstants.guestUser, true);
    GetStorage().write(BoxConstants.id, 1);
    ref.read(homeTabControllerProvider.notifier).selectCategory(category: "");
    ref.read(homeTabControllerProvider.notifier).updateSelectedTab(AppTabs.home);
    NavigationController.routeOff(route: SplashScreen.id);
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
              bottom: kIsWeb ? Radius.circular(32) : Radius.zero,
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
              // SignInButton(
              //   title: "Login",
              //   iconPath: "zipbuzz-null",
              //   onTap: () =>
              //       ref.read(authServicesProvider).googleUserExistsFlow("venkylm10@gmail.com"),
              // ),
              // const SizedBox(height: 24),
              SignInButton(
                title: "Google",
                iconPath: Assets.icons.google_logo,
                onTap: () => googleSignIn(ref),
              ),
              const SizedBox(height: 8),
              // if(Platform.isIOS)
              SignInButton(
                title: "Apple",
                iconPath: Assets.icons.apple_logo,
                onTap: () => appleSignIn(ref),
              ),
              // if(Platform.isIOS)
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  // Guest View Flow
                  // signInGuestUser(ref);
                  navigatorKey.currentState!.pop();
                  showPrivacySheet(context);
                },
                child: Container(
                  height: 56,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Privacy Protected",
                          style: AppStyles.h4.copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SvgPicture.asset(
                          Assets.icons.lock,
                          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          height: 20,
                        )
                      ],
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
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconPath != "zipbuzz-null")
                SvgPicture.asset(
                  iconPath,
                  height: 24,
                ),
              if (iconPath != "zipbuzz-null") const SizedBox(width: 16),
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

void showPrivacySheet(BuildContext context) async {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    barrierColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(32),
      ),
    ),
    builder: (context) {
      return const PrivacySheet();
    },
  );
}

class PrivacySheet extends StatelessWidget {
  const PrivacySheet({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: Text(
            "Are you harvesting and sharing my data for other commercial interests? \n\nEMPHATICALLY NO! We do not and will NEVER share your data with anyone for any reason at any time.",
            style: AppStyles.h4.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
