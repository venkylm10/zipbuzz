import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/models/event_model.dart';

class EventDetails extends StatelessWidget {
  const EventDetails({
    super.key,
    required this.event,
  });

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //date
        Row(
          children: [
            Container(
              height: 44,
              width: 44,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.greyColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  8,
                ),
              ),
              child: SvgPicture.asset(
                Assets.icons.calendar_fill,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  DateFormat.MMMM().format(event.dateTime),
                  style: AppStyles.h4.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  DateFormat.EEEE().format(event.dateTime),
                  style: AppStyles.h5.copyWith(
                    color: AppColors.lightGreyColor,
                  ),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 8),
        // location
        Row(
          children: [
            Container(
              height: 44,
              width: 44,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.greyColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  8,
                ),
              ),
              child: SvgPicture.asset(
                Assets.icons.geo2,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "Gala Convention Center",
                  softWrap: true,
                  style: AppStyles.h4.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "420 Gala St, San Jose 95125",
                  softWrap: true,
                  style: AppStyles.h5.copyWith(
                    color: AppColors.lightGreyColor,
                  ),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 8),
        //timing
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 44,
              width: 44,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.greyColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  8,
                ),
              ),
              child: SvgPicture.asset(
                Assets.icons.clock_fill,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "8:00 PM - 12:00 PM",
              style: AppStyles.h4.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
