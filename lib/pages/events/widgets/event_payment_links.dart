import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final double amount;
  final bool hideButtons;
  const EventPaymentLinks({
    super.key,
    required this.event,
    required this.amount,
    this.pop = false,
    this.hideButtons = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paypal = event.paypalLink != 'zipbuzz-null';
    final venmo = event.venmoLink != 'zipbuzz-null';
    final paypalLink = ref.read(eventsControllerProvider.notifier).getPayPalLink(event, amount);
    final venmoLink = ref.read(eventsControllerProvider.notifier).getVenmoLink(event, amount);
    return Column(
      children: [
        if (paypal)
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.all(8),
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
                              paypalLink,
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
                          Clipboard.setData(ClipboardData(text: paypalLink));
                          showSnackBar(message: "PayPal link copied to clipboard", duration: 2);
                        },
                        child: const Icon(Icons.copy_rounded, color: AppColors.greyColor),
                      )
                    ],
                  ),
                ),
              ),
              if (!hideButtons)
                GestureDetector(
                  onTap: () async {
                    if (amount == 0) {
                      showSnackBar(message: "Nothing to pay!", duration: 2);
                      return;
                    }
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
                    width: 42,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      image: DecorationImage(
                        image: AssetImage(Assets.icons.paypal),
                        fit: BoxFit.cover,
                      ),
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
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.all(8),
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
                              venmoLink,
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
                          Clipboard.setData(ClipboardData(text: venmoLink));
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
              if (!hideButtons)
                GestureDetector(
                  onTap: () async {
                    if (amount == 0) {
                      showSnackBar(message: "Nothing to pay!", duration: 2);
                      return;
                    }
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
                    width: 42,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      image: DecorationImage(
                        image: AssetImage(Assets.icons.venmo),
                        fit: BoxFit.contain,
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
