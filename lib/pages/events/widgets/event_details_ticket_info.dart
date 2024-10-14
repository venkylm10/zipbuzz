import 'package:flutter/material.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/pages/events/widgets/event_payment_links.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class EventDetailsTicketInfo extends StatelessWidget {
  final EventModel event;
  const EventDetailsTicketInfo({super.key, required this.event});

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
        EventPaymentLinks(event: event),
        const SizedBox(height: 16),
        Divider(
          color: AppColors.greyColor.withOpacity(0.2),
          thickness: 0,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
