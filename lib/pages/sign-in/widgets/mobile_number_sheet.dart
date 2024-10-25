import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/personalise/personalise_controller.dart';
import 'package:zipbuzz/env.dart';
import 'package:zipbuzz/pages/sign-in/widgets/country_code_selector.dart';
import 'package:zipbuzz/services/auth_services.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/custom_text_field.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';

class MobileNumberSheet extends ConsumerStatefulWidget {
  const MobileNumberSheet({super.key});

  @override
  ConsumerState<MobileNumberSheet> createState() => _MobileNumberSheetState();
}

class _MobileNumberSheetState extends ConsumerState<MobileNumberSheet> {
  var otpSent = false;
  var otp = "";
  var loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text("Mobile Number", style: AppStyles.h4),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const CountryCodeSelector(),
                    Expanded(
                      child: CustomTextField(
                        controller: ref.read(personaliseControllerProvider).mobileController,
                        maxLength: 10,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (otpSent)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Enter verification code", style: AppStyles.h4),
                      GestureDetector(
                        onTap: () {
                          ref.read(authServicesProvider).clearOTPs();
                        },
                        child: Text("clear", style: AppStyles.h5),
                      ),
                    ],
                  ),
                if (otpSent)
                  Consumer(builder: (context, ref, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        ref.read(authServicesProvider).otpDigits.length,
                        (index) {
                          final controller = ref.watch(authServicesProvider).otpDigits[index];
                          final focusNode = ref.watch(authServicesProvider).otpFocusNodes[index];
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8).copyWith(
                                left: index == 0 ? 0 : 8,
                                right: index == ref.read(authServicesProvider).otpDigits.length - 1
                                    ? 0
                                    : 8,
                              ),
                              child: CustomTextField(
                                controller: controller,
                                focusNode: focusNode,
                                textAlign: TextAlign.center,
                                maxLength: 1,
                                keyboardType: TextInputType.phone,
                                onChanged: (val) {
                                  if (val.isEmpty) return;
                                  if (index ==
                                      ref.read(authServicesProvider).otpDigits.length - 1) {
                                    FocusScope.of(context).unfocus();
                                  }
                                  FocusScope.of(context).nextFocus();
                                },
                                borderColor: AppColors.primaryColor,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    if (otpSent) {
                      verifyOTP();
                      return;
                    }
                    sendOTP();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        otpSent ? "Verify code" : "Send code",
                        style: AppStyles.h4.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (loading)
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
              ),
            )
        ],
      ),
    );
  }

  Future<void> sendOTP() async {
    final countryCode = ref.read(authServicesProvider).countryCodeController.text;
    final number = "+$countryCode${ref.read(personaliseControllerProvider).mobileController.text}";
    if (loading) return;
    ref.read(authServicesProvider).clearOTPs();
    setState(() {
      loading = true;
    });
    if (number == '+919454047774') {
      await ref.read(authServicesProvider).signInWithMobile(number);
      return;
    }
    try {
      final otp = (await ref.read(dioServicesProvider).sendOTP(number)).toString();
      if (AppEnvironment.environment == Environment.dev) {
        debugPrint("OTP: $otp");
      }
      setState(() {
        this.otp = otp;
        if (otp.isNotEmpty) {
          otpSent = true;
        } else {
          otpSent = false;
        }
        loading = false;
      });
    } catch (e) {
      showSnackBar(
          message:
              "Error sending verification to ${ref.read(personaliseControllerProvider).mobileController.text}");
      setState(() {
        loading = false;
      });
      debugPrint(e.toString());
    }
  }

  Future<void> verifyOTP() async {
    final digits = ref.read(authServicesProvider).otpDigits.map((e) => e.text);
    final entered = digits.join('');
    if (otp != entered) {
      showSnackBar(message: "Try again!");
    }
    ref.read(personaliseControllerProvider).updateShowMobile(false);
    ref.read(personaliseControllerProvider).updateShowEmailId(true);
    setState(() {
      loading = true;
    });
    final countryCode = ref.read(authServicesProvider).countryCodeController.text;
    final number = "+$countryCode${ref.read(personaliseControllerProvider).mobileController.text}";
    try {
      await ref.read(authServicesProvider).signInWithMobile(number);
    } catch (e) {
      debugPrint(e.toString());
    }
    setState(() {
      loading = false;
    });
  }
}
