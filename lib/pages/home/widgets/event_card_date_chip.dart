import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class EventCardDateChip extends StatelessWidget {
  const EventCardDateChip({
    super.key,
    required this.date,
  });

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final weekDay = DateFormat.EEEE().format(date).substring(0, 3);
    final month = DateFormat.MMM().format(date);
    return Container(
      padding: const EdgeInsets.all(2),
      margin: const EdgeInsets.only(bottom: 12),
      constraints: const BoxConstraints(minWidth: 50),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: Text(
              month,
              style: AppStyles.h4.copyWith(
                color: AppColors.greyColor,
              ),
            ),
          ),
          Text(
            date.day.toString(),
            style: AppStyles.h2.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            weekDay,
            style: AppStyles.h4.copyWith(color: AppColors.greyColor),
          )
        ],
      ),
    );
  }
}
