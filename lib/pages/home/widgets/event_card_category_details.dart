import 'package:flutter/material.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/pages/home/widgets/event_card_date_chip.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class EventCardCategoryDetails extends StatelessWidget {
  const EventCardCategoryDetails({
    super.key,
    required this.event,
    required this.date,
  });

  final EventModel event;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      left: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EventCardDateChip(date: date),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              event.category,
              style: AppStyles.h4.copyWith(
                color: AppColors.greyColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
