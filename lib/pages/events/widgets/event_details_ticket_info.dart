import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/pages/events/event_details_page.dart';
import 'package:zipbuzz/pages/events/widgets/event_host_guest_list.dart';
import 'package:zipbuzz/pages/events/widgets/event_payment_links.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/broad_divider.dart';

class EventDetailsTicketInfo extends StatelessWidget {
  final EventModel event;
  final bool isPreview;
  final bool rePublish;
  const EventDetailsTicketInfo({
    super.key,
    required this.event,
    required this.isPreview,
    required this.rePublish,
  });

  @override
  Widget build(BuildContext context) {
    if (event.ticketTypes.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tickets Info",
          style: AppStyles.h5.copyWith(
            color: AppColors.lightGreyColor,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: List.generate(event.ticketTypes.length, (index) {
            final last = index == event.ticketTypes.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${event.ticketTypes[index].title} :",
                      style: AppStyles.h4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "\$${event.ticketTypes[index].price}",
                    style: AppStyles.h4.copyWith(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Consumer(builder: (context, ref, child) {
          var amount = 0;
          final userId = ref.read(userProvider).id;
          if (!isPreview && !rePublish) {
            final member =
                ref.read(eventRequestMembersProvider).indexWhere((e) => e.userId == userId);
            if (member == -1) return const SizedBox();
            amount = ref
                .read(eventRequestMembersProvider)
                .firstWhere((e) => e.userId == userId)
                .totalAmount;
          }
          return EventPaymentLinks(event: event, amount: amount);
        }),
        broadDivider(),
      ],
    );
  }
}
