import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/main.dart';
import 'package:zipbuzz/pages/home/home.dart';

class PersonalisePage extends ConsumerStatefulWidget {
  static const id = '/welcome/personalise';
  const PersonalisePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PersonalisePageState();
}

class _PersonalisePageState extends ConsumerState<PersonalisePage> {
  late final TextEditingController zipcodeController;
  late final TextEditingController mobileController;

  var selectedInterests = [];

  void updateInterests(String interest) {
    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
    setState(() {});
  }

  @override
  void initState() {
    zipcodeController = TextEditingController();
    mobileController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    zipcodeController.dispose();
    mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 54),
                  Text(
                    "Hi Alex!",
                    style: AppStyles.extraLarge.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Lets start by personalize your experience...",
                    style: AppStyles.h2,
                  ),
                  const SizedBox(height: 24),
                  buildTextField(
                    Assets.icons.geo,
                    "Zipcode",
                    zipcodeController,
                    "444-444",
                  ),
                  const SizedBox(height: 24),
                  buildTextField(
                    Assets.icons.telephone_filled,
                    "Mobile no",
                    mobileController,
                    "(+1) (400) 444-5555",
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
                  buildInterests(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24)
                  .copyWith(bottom: 8),
              child: InkWell(
                onTap: () => navigatorKey.currentState!.pushNamed(Home.id),
                borderRadius: BorderRadius.circular(24),
                child: Ink(
                  height: 48,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      "Confirm & Personalize",
                      style: AppStyles.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Wrap buildInterests() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: interests.entries.map(
        (e) {
          final name = e.key;
          return GestureDetector(
            onTap: () => updateInterests(name),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryColor),
                color: selectedInterests.contains(name)
                    ? AppColors.primaryColor
                    : Colors.white,
              ),
              child: Text(
                name,
                style: AppStyles.h5.copyWith(
                  color: selectedInterests.contains(name)
                      ? Colors.white
                      : AppColors.primaryColor,
                  fontWeight: selectedInterests.contains(name)
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
    String iconPath,
    String label,
    TextEditingController controller,
    String hintText,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          iconPath,
          height: 32,
          colorFilter:
              const ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
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
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: AppStyles.h4,
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
