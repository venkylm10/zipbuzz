import 'dart:io';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import '../../models/events/event_model.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/styles.dart';

class AddToCalendar extends StatelessWidget {
  final EventModel event;
  const AddToCalendar({super.key, required this.event});

  DateTime getTime(String time, bool endsNextDay, {bool endTime = false}) {
    var hr = int.parse(time.split(":").first);
    final min = int.parse(time.split(":").last.split(' ').first);
    final pm = time.split(" ").last == 'PM';
    if(pm && hr != 12) {
      hr += 12;
    }
    final eventDate = DateTime.parse(event.date);
    var date = DateTime(eventDate.year, eventDate.month,
        eventDate.day + (endTime && endsNextDay ? 1 : 0), hr, min);
    return date;
  }

  bool endsNextDay(String startTime, String endTime) {
    final startPm = startTime.split(" ").last == 'PM';
    final endAm = endTime.split(" ").last == 'AM';
    return startPm && endAm;
  }

  Future<void> addToAppleCalendar() async {
    final nextDay = endsNextDay(event.startTime, event.endTime);
    final startTime = getTime(event.startTime, nextDay);
    final endTime = event.endTime != 'null'
        ? getTime(event.endTime, nextDay, endTime: true)
        : startTime.add(const Duration(hours: 1));
    final Event calEvent = Event(
      title: event.title,
      description: event.about,
      location: event.location,
      startDate: startTime,
      endDate: endTime,
    );
    Add2Calendar.addEvent2Cal(calEvent);
  }

  Future<void> addToGoogleCalendar() async {
    final nextDay = endsNextDay(event.startTime, event.endTime);
    var googleCalendarUrl =
        'https://www.google.com/calendar/render?action=TEMPLATE';
    final startTime = getTime(event.startTime, nextDay);
    final endTime = event.endTime != 'null'
        ? getTime(event.endTime,nextDay, endTime: true)
        : startTime.add(const Duration(hours: 1));
    String formattedStartTime =
        '${DateFormat("yyyyMMddTHHmmss").format(startTime.toUtc())}Z';
    String formattedEndTime =
        '${DateFormat("yyyyMMddTHHmmss").format(endTime.toUtc())}Z';
    googleCalendarUrl += '&text=${Uri.encodeComponent(event.title)}';
    googleCalendarUrl += '&dates=$formattedStartTime/$formattedEndTime';
    googleCalendarUrl += '&location=${Uri.encodeComponent(event.location)}';
    debugPrint("Google Calendar URL: $googleCalendarUrl");
    if (await canLaunchUrlString(googleCalendarUrl)) {
      await launchUrlString(googleCalendarUrl);
    }
  }

  Future<void> addToMicrosoftCalendar() async {
    final nextDay = endsNextDay(event.startTime, event.endTime);
    var microsoftCalendarUrl =
        'https://outlook.live.com/calendar/action/compose';
    final startTime = getTime(event.startTime,nextDay);
    final endTime = event.endTime != 'null'
        ? getTime(event.endTime, nextDay, endTime: true)
        : startTime.add(const Duration(hours: 1));
    String formattedStartTime =
        '${DateFormat("yyyyMMddTHHmmss").format(startTime.toUtc())}Z';
    String formattedEndTime =
        '${DateFormat("yyyyMMddTHHmmss").format(endTime.toUtc())}Z';
    microsoftCalendarUrl += '?startdt=$formattedStartTime';
    microsoftCalendarUrl += '&enddt=$formattedEndTime';
    microsoftCalendarUrl += '&subject=${Uri.encodeComponent(event.title)}';
    microsoftCalendarUrl += '&location=${Uri.encodeComponent(event.location)}';
    debugPrint("Microsoft Calendar URL: $microsoftCalendarUrl");
    if (await canLaunchUrlString(microsoftCalendarUrl)) {
      await launchUrlString(microsoftCalendarUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding:
            const EdgeInsets.symmetric(horizontal: 12).copyWith(bottom: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 5,
                  width: 36,
                  decoration: BoxDecoration(
                    color: AppColors.lightGreyColor,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Add ${event.title} to Calendar",
              softWrap: true,
              textAlign: TextAlign.center,
              style: AppStyles.h2.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () {
                    addToGoogleCalendar();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.borderGrey,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SvgPicture.asset(
                        Assets.icons.google_logo,
                        height: 36,
                        width: 36,
                      ),
                    ),
                  ),
                ),
                if (Platform.isIOS)
                  InkWell(
                    onTap: () {
                      addToAppleCalendar();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.borderGrey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SvgPicture.asset(
                          Assets.icons.apple_logo,
                          height: 36,
                          width: 36,
                        ),
                      ),
                    ),
                  ),
                InkWell(
                  onTap: () => addToMicrosoftCalendar(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.borderGrey,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        Assets.icons.microsoftLogo,
                        height: 36,
                        width: 36,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
