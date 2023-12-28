import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/controllers/personalise/personalise_controller.dart';
import 'package:zipbuzz/services/location_services.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/services/firebase_providers.dart';
import 'package:zipbuzz/widgets/common/loader.dart';

class PersonalisePage extends ConsumerStatefulWidget {
  static const id = '/welcome/personalise';
  const PersonalisePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PersonalisePageState();
}

class _PersonalisePageState extends ConsumerState<PersonalisePage> {
  @override
  void initState() {
    initialise();
    super.initState();
  }

  void initialise() {
    ref.read(personaliseControllerProvider).initialise();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentUser = ref.read(authProvider).currentUser!;
    final personaliseController = ref.read(personaliseControllerProvider);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
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
          SingleChildScrollView(
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
                      personaliseController.zipcodeController,
                      userLocation.zipcode,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                    );
                  }),
                  const SizedBox(height: 24),
                  buildTextField(
                    Assets.icons.telephone_filled,
                    "Mobile no",
                    personaliseController.mobileController,
                    currentUser.phoneNumber ?? "9998887776",
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                  ),
                  const SizedBox(height: 40),
                  Text(
                    "Select at least 3 interests:",
                    style: AppStyles.h3.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  buildInterests(ref),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          buildSubmitButton(personaliseController),
        ],
      ),
    );
  }

  Align buildSubmitButton(PersonaliseController personaliseController) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Consumer(builder: (context, subRef, child) {
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
      }),
    );
  }

  Widget buildInterests(WidgetRef ref) {
    final personaliseController = ref.watch(personaliseControllerProvider);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: allInterests.entries.map(
        (e) {
          final name = e.key;
          return GestureDetector(
            onTap: () {
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
                name,
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
