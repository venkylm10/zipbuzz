import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/pages/events/widgets/event_payment_links.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';

import '../../../utils/constants/styles.dart';

class TicketEventPaymentLinkSheet extends StatelessWidget {
  final EventModel event;
  const TicketEventPaymentLinkSheet({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    navigatorKey.currentState!.pop();
                  },
                  child: Icon(
                    Icons.cancel,
                    color: AppColors.primaryColor.withOpacity(0.8),
                    size: 32,
                  ),
                ),
              ],
            ),
            Text(
              "Do complete your payment!\nSo Host can confirm your request.",
              style: AppStyles.h4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            EventPaymentLinks(event: event),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
