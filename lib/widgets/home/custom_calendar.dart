import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';

class CustomCalendar extends StatelessWidget {
  const CustomCalendar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20).copyWith(top: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.calenderBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TableCalendar(
        focusedDay: DateTime.now(),
        firstDay: DateTime.utc(2022),
        lastDay: DateTime.utc(2024),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: AppStyles.titleStyle,
        ),
        startingDayOfWeek: StartingDayOfWeek.monday,
        rowHeight: 48,
        calendarBuilders: CalendarBuilders(
          dowBuilder: (context, day) {
            return Text(
              DateFormat.E('en_US').format(day).substring(0, 2),
              textAlign: TextAlign.center,
              style:
                  AppStyles.h4.copyWith(fontWeight: FontWeight.w500),
            );
          },
          todayBuilder: (context, day, focusedDay) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.2, 0.85],
                      colors: [
                        AppColors.primaryColor.withOpacity(0.2),
                        Colors.transparent
                      ],
                    ),
                  ),
                  child: Text(
                    day.day.toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}