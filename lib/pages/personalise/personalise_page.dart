import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/controllers/personalise/personalise_controller.dart';
import 'package:zipbuzz/services/location_services.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/services/firebase_providers.dart';
import 'package:zipbuzz/utils/widgets/custom_bezel.dart';
import 'package:zipbuzz/utils/widgets/loader.dart';

class PersonalisePage extends ConsumerStatefulWidget {
  static const id = '/welcome/personalise';
  const PersonalisePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PersonalisePageState();
}

class _PersonalisePageState extends ConsumerState<PersonalisePage> {
  bool agree = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentUser = ref.read(authProvider).currentUser;
    final personaliseController = ref.read(personaliseControllerProvider);
    // final userInterest = ref.read(userProvider);
    // personaliseController.selectedInterests.addAll(userInterest.interests);
    final webWidth = size.height * Assets.images.border_ratio * 0.88;
    return CustomBezel(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SizedBox(
            height: size.height,
            width: kIsWeb ? webWidth : size.width,
            child: Stack(
              children: [
                // Background Gradients
                Container(
                  height: size.height,
                  width: kIsWeb ? webWidth : size.width,
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
                  width: kIsWeb ? webWidth : size.width,
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
                    width: kIsWeb ? webWidth : size.width,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 54),
                            Consumer(builder: (context, ref, child) {
                              return Text(
                                "Hi ${ref.read(personaliseControllerProvider).nameController.text}!",
                                style: AppStyles.extraLarge.copyWith(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                              );
                            }),
                            const SizedBox(height: 8),
                            Text(
                              "Personalize your experience",
                              style: AppStyles.h2,
                            ),
                            const SizedBox(height: 12),
                            Consumer(builder: (context, ref, child) {
                              final showName = ref.watch(personaliseControllerProvider).showEmailId;
                              if (!showName) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: buildTextField(
                                  Assets.icons.personName,
                                  "Name",
                                  personaliseController.nameController,
                                  "Enter name",
                                  keyboardType: TextInputType.text,
                                ),
                              );
                            }),
                            Consumer(builder: (context, ref, child) {
                              final showEmailId =
                                  ref.watch(personaliseControllerProvider).showEmailId;
                              if (!showEmailId) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: buildTextField(
                                  Assets.icons.email,
                                  "Email",
                                  personaliseController.emailController,
                                  "Enter email",
                                  keyboardType: TextInputType.text,
                                ),
                              );
                            }),
                            Consumer(builder: (context, subRef, child) {
                              final userLocation = subRef.watch(userLocationProvider);
                              return buildTextField(
                                Assets.icons.geo,
                                "Zipcode",
                                personaliseController.zipcodeController,
                                userLocation.zipcode,
                                keyboardType: TextInputType.number,
                                maxLength: 10,
                              );
                            }),
                            const SizedBox(height: 12),
                            Consumer(builder: (context, ref, child) {
                              final enabled =
                                  !(ref.watch(personaliseControllerProvider).showEmailId);
                              return buildTextField(
                                Assets.icons.telephone_filled,
                                "Mobile no",
                                personaliseController.mobileController,
                                currentUser == null
                                    ? "Number"
                                    : currentUser.phoneNumber ?? "Number",
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                prefixWidget: countryCodeSelector(
                                  enabled: enabled,
                                ),
                                enabled: enabled,
                              );
                            }),
                            const SizedBox(height: 12),
                            Text(
                              "Select at least one interest:",
                              style: AppStyles.h3.copyWith(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            buildInterests(context, ref),
                            const SizedBox(height: 24),
                            buildCheckBox(),
                            const SizedBox(height: 12),
                            buildSubmitButton(personaliseController),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row buildCheckBox() {
    return Row(
      children: [
        Checkbox(
          value: agree,
          activeColor: AppColors.primaryColor,
          side: const BorderSide(
            color: AppColors.greyColor,
            width: 1.5,
            style: BorderStyle.solid,
          ),
          onChanged: (val) {
            setState(() {
              agree = val!;
            });
          },
        ),
        Expanded(
          child: Text(
            "By continuing you agree to receive event text messages from BuzzMe at this number",
            style: AppStyles.h5.copyWith(
              color: AppColors.greyColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget countryCodeSelector({bool enabled = true}) {
    final personaliseController = ref.read(personaliseControllerProvider);
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGreyColor),
      ),
      child: Center(
        child: DropdownButton(
          value: personaliseController.countryDialCode,
          underline: const SizedBox(),
          padding: EdgeInsets.zero,
          icon: Transform.rotate(
            angle: -pi / 2,
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
            ),
          ),
          items: [
            DropdownMenuItem(
              value: "1",
              child: Text(
                " + 1 ",
                style: AppStyles.h4,
              ),
            ),
            DropdownMenuItem(
              value: "91",
              child: Text(
                " + 91 ",
                style: AppStyles.h4,
              ),
            ),
            DropdownMenuItem(
              value: "971",
              child: Text(
                " + 971 ",
                style: AppStyles.h4,
              ),
            ),
          ],
          onChanged: enabled
              ? (val) {
                  if (val != null) {
                    personaliseController.updateCountryCode(val as String);
                    setState(() {});
                  }
                }
              : null,
        ),
      ),
    );
  }

  Widget buildSubmitButton(PersonaliseController personaliseController) {
    return Consumer(builder: (context, subRef, child) {
      final loadingText = subRef.watch(loadingTextProvider);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 8),
        child: InkWell(
          onTap: () {
            if (loadingText == null) {
              personaliseController.sumbitInterests();
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
    final personaliseController = ref.watch(personaliseControllerProvider);
    List<Widget> interests = unsortedInterests.sublist(0, 10).map(
      (e) {
        final name = e.activity;
        return InkWell(
          onTap: () {
            FocusScope.of(context).unfocus();
            personaliseController.updateInterests(name);
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryColor),
              color: personaliseController.selectedInterests.contains(name)
                  ? AppColors.primaryColor
                  : Colors.white,
            ),
            child: Text(
              e.activity,
              style: AppStyles.h5.copyWith(
                color: personaliseController.selectedInterests.contains(name)
                    ? Colors.white
                    : AppColors.primaryColor,
                fontWeight: personaliseController.selectedInterests.contains(name)
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    ).toList();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...interests,
        Text(
          "and many many more...",
          style: AppStyles.h5.copyWith(fontStyle: FontStyle.italic, color: AppColors.textColor),
        ),
      ],
    );
  }

  Widget buildTextField(
      String iconPath, String label, TextEditingController controller, String hintText,
      {TextInputType? keyboardType,
      int? maxLength,
      Widget? prefixWidget,
      VoidCallback? onChanged,
      bool enabled = true}) {
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (prefixWidget != null) prefixWidget,
                  if (prefixWidget != null) const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      cursorColor: AppColors.primaryColor,
                      style: AppStyles.h4,
                      keyboardType: keyboardType,
                      maxLength: maxLength,
                      enabled: enabled,
                      onChanged: (value) {
                        if (onChanged != null) onChanged();
                        if (value.length == maxLength) {
                          //close keyboard
                          FocusScope.of(context).requestFocus(FocusNode());
                        }
                      },
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
