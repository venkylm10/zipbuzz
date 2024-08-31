import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/personalise/personalise_controller.dart';
import 'package:zipbuzz/env.dart';
import 'package:zipbuzz/models/user/post/user_details_model.dart';
import 'package:zipbuzz/models/user/requests/user_details_update_request_model.dart';
import 'package:zipbuzz/services/auth_services.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/custom_text_field.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';

class ConfirmOwnMobilePage extends ConsumerStatefulWidget {
  final int otherUserId;
  final UserDetailsModel otherUserDetails;
  const ConfirmOwnMobilePage(
      {super.key, required this.otherUserId, required this.otherUserDetails});

  @override
  ConsumerState<ConfirmOwnMobilePage> createState() => _ConfirmOwnMobilePageState();
}

class _ConfirmOwnMobilePageState extends ConsumerState<ConfirmOwnMobilePage> {
  var loading = false;
  var otpSent = false;
  var otp = "";
  void showOTPSentSnackBar(WidgetRef ref) async {
    await sendOTP(ref);
    showSnackBar(
        message: "OTP sent to ${ref.read(personaliseControllerProvider).mobileController.text}");
  }

  @override
  void initState() {
    showOTPSentSnackBar(ref);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Own Mobile', style: AppStyles.h3),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Consumer(builder: (context, ref, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Enter Verification Code", style: AppStyles.h4),
                      GestureDetector(
                        onTap: () {
                          ref.read(authServicesProvider).clearOTPs();
                        },
                        child: Text("clear", style: AppStyles.h5),
                      ),
                    ],
                  );
                }),
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
                                if (index == ref.read(authServicesProvider).otpDigits.length - 1) {
                                  FocusScope.of(context).unfocus();
                                }
                                FocusScope.of(context).nextFocus();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        sendOTP(ref);
                      },
                      child: Text("Re-send", style: AppStyles.h5),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    verifyOTP(ref);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        "Verify Code",
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
            ),
        ],
      ),
    );
  }

  Future<void> sendOTP(WidgetRef ref) async {
    if (loading) return;
    final countryCode = ref.read(personaliseControllerProvider).countryDialCode;
    final number = "+$countryCode${ref.read(personaliseControllerProvider).mobileController.text}";
    ref.read(authServicesProvider).clearOTPs();
    setState(() {
      loading = true;
    });
    try {
      final otp = (await ref.read(dioServicesProvider).sendOTP(number)).toString();
      if (AppEnvironment.environment == Environment.dev) {
        debugPrint("OTP: $otp");
        // showSnackBar(message: "OTP: $otp", duration: 5);
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

  Future<void> verifyOTP(WidgetRef ref) async {
    if (loading) return;
    final digits = ref.read(authServicesProvider).otpDigits.map((e) => e.text);
    final entered = digits.join('');
    if (otp != entered) {
      showSnackBar(message: "Try again!");
      return;
    }
    setState(() {
      loading = true;
    });
    try {
      final userDetailsUpdateRequestModel = UserDetailsUpdateRequestModel(
          id: widget.otherUserId,
          phoneNumber: 'zipbuzz-null',
          zipcode: widget.otherUserDetails.zipcode,
          email: widget.otherUserDetails.email,
          profilePicture: widget.otherUserDetails.profilePicture,
          description: widget.otherUserDetails.description,
          username: widget.otherUserDetails.username,
          isAmbassador: false,
          instagram: 'zipbuzz-null',
          linkedin: 'zipbuzz-null',
          twitter: 'zipbuzz-null',
          interests: [],
          notifictaionCount: 0);
      await ref.read(dioServicesProvider).updateUserDetails(userDetailsUpdateRequestModel);
      navigatorKey.currentState!.pop();
      await Future.delayed(const Duration(milliseconds: 500));
      showSnackBar(message: "Now try again to continue with this number..");
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar(message: "Something went wrong!");
    }
    setState(() {
      loading = false;
    });
  }
}
