import 'package:flutter/material.dart';
import 'package:zipbuzz/constants/styles.dart';

class EventChip extends StatelessWidget {
  const EventChip({
    super.key,
    required this.eventColor,
    required this.interest,
    required this.iconPath,
  });

  final Color eventColor;
  final String interest;
  final String iconPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: eventColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconPath,
            height: 16,
          ),
          const SizedBox(width: 5),
          Text(
            interest,
            style: AppStyles.h5.copyWith(
              color: eventColor,
            ),
          ),
        ],
      ),
    );
  }
}
