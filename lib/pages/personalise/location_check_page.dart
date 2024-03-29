import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/controllers/profile/edit_profile_controller.dart';
import 'package:zipbuzz/pages/home/home.dart';
import 'package:zipbuzz/services/location_services.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/services/firebase_providers.dart';
import 'package:zipbuzz/widgets/common/loader.dart';

class LocationCheckPage extends ConsumerStatefulWidget {
  static const id = '/location_check';
  const LocationCheckPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LocationCheckPageState();
}

class _LocationCheckPageState extends ConsumerState<LocationCheckPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentUser = ref.read(authProvider).currentUser!;
    final editProfileController = ref.read(editProfileControllerProvider);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        height: size.height,
        width: size.height,
        child: Stack(
          children: [
            // Background Gradients
            Container(
              height: size.height,
              width: size.width,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryColor.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  radius: 0.8,
                  center: Alignment.topRight,
                  focalRadius: 0,
                ),
              ),
            ),
            Container(
              height: size.height,
              width: size.width,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryColor.withOpacity(0.2),
                    Colors.transparent,
                  ],
                  radius: 0.8,
                  center: Alignment.bottomLeft,
                  focalRadius: 0,
                ),
              ),
            ),
            // Form
            Positioned(
              top: 0,
              left: 0,
              child: SizedBox(
                height: size.height,
                width: size.width,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 54),
                        Text(
                          "Hi ${currentUser.displayName ?? ""}!",
                          style: AppStyles.extraLarge.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Lets start by personalize your experience...",
                          style: AppStyles.h2,
                        ),
                        const SizedBox(height: 24),
                        Consumer(builder: (context, subRef, child) {
                          final userLocation = subRef.watch(userLocationProvider);
                          return buildTextField(
                            Assets.icons.geo,
                            "Zipcode",
                            editProfileController.zipcodeController,
                            userLocation.zipcode,
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                          );
                        }),
                        const SizedBox(height: 24),
                        Text(
                          "Select at least 3 interests:",
                          style: AppStyles.h3.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        buildInterests(context, ref),
                        const SizedBox(height: 48),
                        buildSubmitButton(editProfileController),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSubmitButton(EditProfileController editProfileController) {
    return Consumer(builder: (context, subRef, child) {
      final loadingText = subRef.watch(loadingTextProvider);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 8),
        child: InkWell(
          onTap: () async {
            if (loadingText == null) {
              if (editProfileController.validateLocationCheck()) {
                await editProfileController.saveChanges();
                navigatorKey.currentState!.pushReplacementNamed(Home.id);
              }
            }
          },
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            height: 48,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: loadingText == null
                  ? Text(
                      "Confirm & Personalize",
                      style: AppStyles.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : Text(
                      loadingText,
                      style: AppStyles.h4.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      );
    });
  }

  Widget buildInterests(BuildContext context, WidgetRef ref) {
    final editProfileController = ref.watch(editProfileControllerProvider);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: allInterests.sublist(0, 10).map(
        (e) {
          final name = e.activity;
          return InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
              editProfileController.updateInterest(name);
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryColor),
                color: editProfileController.userClone.interests.contains(name)
                    ? AppColors.primaryColor
                    : Colors.white,
              ),
              child: Text(
                "${e.category}/${e.activity}",
                style: AppStyles.h5.copyWith(
                  color: editProfileController.userClone.interests.contains(name)
                      ? Colors.white
                      : AppColors.primaryColor,
                  fontWeight: editProfileController.userClone.interests.contains(name)
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ).toList(),
    );
  }

  Row buildTextField(
      String iconPath, String label, TextEditingController controller, String hintText,
      {TextInputType? keyboardType, int? maxLength}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          iconPath,
          height: 32,
          colorFilter: const ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppStyles.h3),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                cursorColor: AppColors.primaryColor,
                style: AppStyles.h4,
                keyboardType: keyboardType,
                maxLength: maxLength,
                decoration: InputDecoration(
                  counter: const SizedBox(),
                  hintText: hintText,
                  hintStyle: AppStyles.h4.copyWith(
                    color: AppColors.lightGreyColor,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.lightGreyColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.lightGreyColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.lightGreyColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
