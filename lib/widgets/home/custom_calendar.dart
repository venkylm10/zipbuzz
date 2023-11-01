import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/models/event_model.dart';
import 'package:zipbuzz/widgets/home/event_card.dart';
import 'package:zipbuzz/widgets/home/events_provider.dart';

class CustomCalendar extends ConsumerStatefulWidget {
  const CustomCalendar({super.key});

  @override
  ConsumerState<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends ConsumerState<CustomCalendar> {
  DateTime focusedDay = DateTime.now();
  void onDaySelected(DateTime day, DateTime focusedDay) {
    ref.read(eventsControllerProvider.notifier).updateEvents(focusedDay);
    setState(() {
      this.focusedDay = focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedDaysEvents = ref.watch(eventsControllerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.all(20).copyWith(top: 10),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.calenderBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TableCalendar(
            focusedDay: focusedDay,
            firstDay: DateTime.utc(2022),
            lastDay: DateTime.utc(2024),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: AppStyles.titleStyle,
            ),
            selectedDayPredicate: (day) => isSameDay(day, focusedDay),
            onDaySelected: onDaySelected,
            startingDayOfWeek: StartingDayOfWeek.monday,
            rowHeight: 48,
            calendarBuilders: customCalendarBuilders(),
            eventLoader: (day) => events[day] ?? [],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 0, 10),
          child: Text(
            "Upcoming Events",
            style: AppStyles.titleStyle,
          ),
        ),
        Column(
          children: selectedDaysEvents.map((e) => EventCard(event: e)).toList(),
        ),
      ],
    );
  }

  CalendarBuilders<dynamic> customCalendarBuilders() {
    return CalendarBuilders(
      dowBuilder: (context, day) {
        return Text(
          DateFormat.E('en_US').format(day).substring(0, 2),
          textAlign: TextAlign.center,
          style: AppStyles.h4.copyWith(fontWeight: FontWeight.w500),
        );
      },
      todayBuilder: (context, day, focusedDay) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                style: AppStyles.h4.copyWith(
                  fontWeight: focusedDay == DateTime.now()
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ],
        );
      },
      selectedBuilder: (context, day, focusedDay) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                style: AppStyles.h4.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
      defaultBuilder: (context, day, focusedDay) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                day.day.toString(),
                textAlign: TextAlign.center,
                style: AppStyles.h4,
              ),
            ),
          ],
        );
      },
      disabledBuilder: (context, day, focusedDay) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                day.day.toString(),
                textAlign: TextAlign.center,
                style: AppStyles.h4.copyWith(
                  color: AppColors.greyColor,
                ),
              ),
            ),
          ],
        );
      },
      markerBuilder: (context, day, events) {
        final dayEvents = (events.length > 6 ? events.sublist(0, 6) : events);
        return SizedBox(
          height: 6,
          width: 36,
          child: Row(
            children: dayEvents.map((e) => buildEventIndicator(e)).toList(),
          ),
        );
      },
    );
  }

  Expanded buildEventIndicator(EventModel event) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: getCategoryColor(event.iconPath),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

Color getCategoryColor(String categoryPath) {
  return categoryColors[categoryPath]!;
}
