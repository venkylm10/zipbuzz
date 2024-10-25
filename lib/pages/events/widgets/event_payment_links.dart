import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';

class EventPaymentLinks extends ConsumerWidget {
  final EventModel event;
  final bool pop;
  final int amount;
  const EventPaymentLinks({super.key, required this.event, required this.amount, this.pop = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paypal = event.paypalLink != 'zipbuzz-null';
    final venmo = event.venmoLink != 'zipbuzz-null';
    return Column(
      children: [
        if (paypal)
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.borderGrey,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.paypalLink,
                              style: AppStyles.h5.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: event.paypalLink));
                          showSnackBar(message: "PayPal link copied to clipboard", duration: 2);
                        },
                        child: const Icon(Icons.copy_rounded, color: AppColors.greyColor),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    if (amount == 0) {
                      showSnackBar(message: "Nothing to pay!", duration: 2);
                      return;
                    }
                    final paypalLink =
                        ref.read(eventsControllerProvider.notifier).getPayPalLink(event, amount);
                    if (paypalLink.isEmpty) {
                      showSnackBar(
                        message: "Please contact host to correct the PayPal link!",
                        duration: 5,
                      );
                      return;
                    }
                    debugPrint(paypalLink);
                    showSnackBar(
                      message: "Once payment is done, Please wait till the host confirms it",
                      duration: 2,
                    );
                    await Future.delayed(const Duration(seconds: 2));
                    await launchUrlString(
                      paypalLink,
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.yellow[600],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SvgPicture.asset(Assets.icons.paypal),
                  ),
                ),
              ),
            ],
          ),
        if (paypal && venmo) const SizedBox(height: 8),
        if (venmo)
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.borderGrey,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.venmoLink,
                              style: AppStyles.h5.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: event.venmoLink));
                          showSnackBar(
                            message: "Venmo link copied to clipboard",
                            duration: 2,
                          );
                        },
                        child: const Icon(Icons.copy_rounded, color: AppColors.greyColor),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    if (amount == 0) {
                      showSnackBar(message: "Nothing to pay!", duration: 2);
                      return;
                    }
                    final venmoLink =
                        ref.read(eventsControllerProvider.notifier).getVenmoLink(event, amount);
                    if (venmoLink.isEmpty) {
                      showSnackBar(
                        message: "Please contact host to correct the Venmo ID!",
                        duration: 5,
                      );
                      return;
                    }
                    debugPrint(venmoLink);
                    showSnackBar(
                      message: "Once payment is done, Please wait till the host confirms it",
                      duration: 2,
                    );
                    await Future.delayed(const Duration(seconds: 2));
                    launchUrlString(
                      venmoLink,
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xff3d95ce),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SvgPicture.asset(
                      Assets.icons.venmo,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
