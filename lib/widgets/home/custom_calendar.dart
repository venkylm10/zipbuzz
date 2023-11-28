import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/models/event_model.dart';
import 'package:zipbuzz/widgets/home/event_card.dart';
import 'package:zipbuzz/controllers/events_controller.dart';

class CustomCalendar extends ConsumerStatefulWidget {
  const CustomCalendar({super.key});

  @override
  ConsumerState<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends ConsumerState<CustomCalendar> {
  DateTime focusedDay = DateTime.now();
  List<EventModel> upcomingEvents = [];
  List<EventModel> focusedEvents = [];

  void onDaySelected(DateTime day, DateTime focusedDay) {
    ref.read(eventsControllerProvider).updatedFocusedDay(focusedDay);
    ref.read(eventsControllerProvider).updateFocusedEvents();
    setState(() {});
  }

  @override
  void initState() {
    ref.read(eventsControllerProvider).updateUpcomingEvents();
    ref.read(eventsControllerProvider).updateFocusedEvents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    upcomingEvents = ref.watch(eventsControllerProvider).upcomingEvents;
    focusedDay = ref.watch(eventsControllerProvider).focusedDay;
    focusedEvents = ref.watch(eventsControllerProvider).focusedEvents;
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
              titleTextStyle: AppStyles.h2,
            ),
            selectedDayPredicate: (day) => isSameDay(day, focusedDay),
            onDaySelected: onDaySelected,
            startingDayOfWeek: StartingDayOfWeek.monday,
            rowHeight: 48,
            availableGestures: AvailableGestures.horizontalSwipe,
            calendarBuilders: customCalendarBuilders(),
            eventLoader: (day) => events[day] ?? [],
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: focusedEvents.isNotEmpty
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('d\'th\' MMM').format(focusedDay),
                      style: AppStyles.h4.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      " (${DateFormat('EEEE').format(focusedDay)})",
                      style: AppStyles.h4.copyWith(
                        color: AppColors.lightGreyColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
        ),
        const SizedBox(height: 15),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: focusedEvents.isNotEmpty
              ? Column(
                  children: focusedEvents
                      .map((e) => EventCard(event: e, focusedEvent: true))
                      .toList(),
                )
              : const SizedBox(),
        ),
        if (upcomingEvents.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 0, 10),
            child: Text(
              "Upcoming Events",
              style: AppStyles.h2,
            ),
          ),
        Column(
          children: upcomingEvents.map((e) => EventCard(event: e)).toList(),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.primaryColor.withOpacity(0.2),
                ),
                child: Center(
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
            children: List.generate(
              dayEvents.length,
              (index) => buildEventIndicator(
                dayEvents[index],
                index,
                dayEvents.length,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildEventIndicator(EventModel event, int index, int length) {
    final color = getInterestColor(event.iconPath);
    return Expanded(
      child: Transform.translate(
        offset: Offset(-(2 * index).toDouble(), 0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.white, width: 0.75),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
