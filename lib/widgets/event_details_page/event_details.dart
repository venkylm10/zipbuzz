import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/models/event_model.dart';

class EventDetails extends StatefulWidget {
  const EventDetails({
    super.key,
    required this.event,
  });

  final EventModel event;

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  var startTime = "";
  var endTime = "";

  void getStartTime() {
    if (widget.event.startTime.isNotEmpty) {
      final start = DateTime.parse(widget.event.startTime).toLocal();
      final noon = start.hour >= 12 ? true : false;
      startTime =
          "${start.hour >= 13 ? start.hour - 12 : start.hour}:${start.minute} ${noon ? "PM" : "AM"}";
    }
  }

  void getEndTime() {
    if (widget.event.endTime!.isNotEmpty) {
      final end = DateTime.parse(widget.event.endTime!).toLocal();
      final noon = end.hour >= 12 ? true : false;
      endTime =
          "${end.hour >= 13 ? end.hour - 12 : end.hour}:${end.minute} ${noon ? "PM" : "AM"}";
    }
  }

  void initialiseTime() {
    getStartTime();
    if (widget.event.endTime != null) {
      getEndTime();
    }
    setState(() {});
  }

  @override
  void initState() {
    initialiseTime();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(widget.event.date);
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
                  "${DateFormat.MMMM().format(date)} ${date.day}",
                  style: AppStyles.h4.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  DateFormat.EEEE().format(date),
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
              "$startTime - $endTime",
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
