import 'package:flutter/material.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/pages/home/widgets/add_to_calendar.dart';
import 'package:zipbuzz/pages/home/widgets/event_card_date_chip.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';

class EventCardCategoryDetails extends StatelessWidget {
  const EventCardCategoryDetails({
    super.key,
    required this.event,
    required this.focusedEvent,
    required this.date,
    required this.eventColor,
  });

  final EventModel event;
  final bool focusedEvent;
  final DateTime date;
  final Color eventColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!focusedEvent) EventCardDateChip(date: date),
        Container(
          height: 50,
          width: 50,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: eventColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Image.network(event.iconPath),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            await showModalBottomSheet(
              context: navigatorKey.currentContext!,
              isScrollControlled: true,
              enableDrag: true,
              isDismissible: true,
              backgroundColor: Colors.transparent,
              builder: (context) {
                return AddToCalendar(event: event);
              },
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Container(
              height: 50,
              width: 50,
              padding: const EdgeInsets.all(12),
              color: AppColors.bgGrey,
              child: Image.asset(Assets.icons.addToCalendar),
            ),
          ),
        )
      ],
    );
  }
}