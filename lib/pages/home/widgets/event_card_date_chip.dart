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
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            month,
            style: AppStyles.h4.copyWith(
              color: AppColors.greyColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            date.day.toString(),
            style: AppStyles.h3.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            weekDay,
            style: AppStyles.h4.copyWith(
              color: AppColors.greyColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
