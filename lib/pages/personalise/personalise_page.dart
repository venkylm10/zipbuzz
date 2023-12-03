import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/controllers/user_controller.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/firebase_providers.dart';
import 'package:zipbuzz/services/location_services.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

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

  var selectedInterests = <String>[];

  var country = "";
  var countryDialCode = "";
  var zipcode = "";
  bool loading = true;
  bool isMounted = true;

  void updateInterests(String interest) {
    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
    setState(() {});
  }

  void updateUser() async {
    final check = validate();
    if (check) {
      try {
        final auth = ref.read(authProvider);
        final currentUser = ref.read(userProvider)!.copyWith(
              mobileNumber: "$countryDialCode${mobileController.text.trim()}",
              interests: selectedInterests,
              zipcode: zipcodeController.text.trim(),
            );
        Map<String, dynamic> updateMap = {
          'mobileNumber': "$countryDialCode${mobileController.text.trim()}",
          'interests': selectedInterests,
          'zipcode': zipcodeController.text.trim(),
        };

        await ref
            .read(dbServicesProvider)
            .updateUser(auth.currentUser!.uid, updateMap);
        ref.read(userProvider.notifier).update((state) => currentUser);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  void initialise() async {
    if (ref.read(userProvider)!.zipcode.isEmpty) {
      await ref.read(locationServicesProvider).getInitialInfo();
    }
    country = ref.read(userProvider)!.country;
    countryDialCode = ref.read(userProvider)!.countryDialCode;
    zipcode = ref.read(userProvider)!.zipcode;
    zipcodeController.text = zipcode;
    loading = false;
    mobileController.text =
        ref.read(authProvider).currentUser!.phoneNumber ?? "";
    setState(() {});
  }

  bool validate() {
    if (zipcodeController.text.isEmpty) {
      showSnackBar(message: "Please enter zipcode");
      return false;
    }

    if (zipcodeController.text.length != 6) {
      showSnackBar(message: "Please enter valid zipcode");
      return false;
    }
    if (mobileController.text.isEmpty) {
      showSnackBar(message: "Please enter mobile number");
      return false;
    }
    if (mobileController.text.length != 10) {
      showSnackBar(message: "Please enter valid mobile number");
      return false;
    }
    if (selectedInterests.length < 3) {
      showSnackBar(message: "Please select at least 3 interests");
      return false;
    }
    return true;
  }

  @override
  void initState() {
    zipcodeController = TextEditingController();
    mobileController = TextEditingController();
    initialise();
    super.initState();
  }

  @override
  void dispose() {
    isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentUser = ref.read(authProvider).currentUser!;
    country = ref.watch(userProvider)!.country;
    countryDialCode = ref.watch(userProvider)!.countryDialCode;
    zipcode = ref.watch(userProvider)!.zipcode;
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
                  buildTextField(
                    Assets.icons.geo,
                    "Zipcode",
                    zipcodeController,
                    "444444",
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                  ),
                  const SizedBox(height: 24),
                  buildTextField(
                    Assets.icons.telephone_filled,
                    "Mobile no",
                    mobileController,
                    "4004445555",
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
                onTap: () => updateUser(),
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
          ),
          if (loading)
            Align(
              alignment: Alignment.center,
              child: Expanded(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: const CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Wrap buildInterests() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: allInterests.entries.map(
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

  Row buildTextField(String iconPath, String label,
      TextEditingController controller, String hintText,
      {TextInputType? keyboardType, int? maxLength}) {
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
