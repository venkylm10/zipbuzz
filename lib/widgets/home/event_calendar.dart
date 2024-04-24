import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class EventCalendar extends ConsumerWidget {
  const EventCalendar({super.key});

  void onDaySelected(DateTime day, DateTime focusedDay, WidgetRef ref) {
    ref.read(eventsControllerProvider.notifier).updatedFocusedDay(focusedDay);
    ref.read(eventsControllerProvider.notifier).updateFocusedEvents();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double rowHeight = 44;
    final eventsMap = ref.watch(eventsControllerProvider).eventsMap;
    final focusedDay = ref.watch(eventsControllerProvider).focusedDay;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.calenderBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TableCalendar(
        focusedDay: focusedDay,
        firstDay: DateTime.utc(2022),
        lastDay: DateTime.now().add(const Duration(days: 365 * 2)),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: AppStyles.h2,
        ),
        selectedDayPredicate: (day) => isSameDay(day, focusedDay),
        onDaySelected: (selectedDay, focusedDay) {
          onDaySelected(selectedDay, focusedDay, ref);
        },
        startingDayOfWeek: StartingDayOfWeek.sunday,
        rowHeight: rowHeight,
        availableGestures: AvailableGestures.horizontalSwipe,
        calendarBuilders: customCalendarBuilders(ref),
        eventLoader: (day) => eventsMap[day] ?? [],
      ),
    );
  }

  void fetchEvents(WidgetRef ref) async {
    await ref.read(eventsControllerProvider.notifier).fetchEvents();
  }

  void updateCurrentDay(WidgetRef ref, DateTime day) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (ref.read(eventsControllerProvider.notifier).currentDay != day) {
      print(day.toString());
      print("current month: ${DateFormat.yMMMM().format(day)}");
      ref.read(eventsControllerProvider.notifier).updateCurrentDay(day);
      onDaySelected(day, day, ref);
      fetchEvents(ref);
    }
  }

  CalendarBuilders<dynamic> customCalendarBuilders(WidgetRef ref) {
    final eventMaps = ref.watch(eventsControllerProvider).eventsMap;
    final selectedCategory = ref.watch(homeTabControllerProvider).selectedCategory;
    return CalendarBuilders(
      headerTitleBuilder: (context, day) {
        updateCurrentDay(ref, day);
        return Text(
          DateFormat.yMMMM().format(day),
          style: AppStyles.h2,
          textAlign: TextAlign.center,
        );
      },
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
                height: 24,
                width: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  color: AppColors.primaryColor.withOpacity(0.2),
                ),
                child: Center(
                  child: Text(
                    day.day.toString(),
                    textAlign: TextAlign.center,
                    style: AppStyles.h4.copyWith(
                      fontWeight:
                          focusedDay == DateTime.now() ? FontWeight.bold : FontWeight.normal,
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
                  colors: [AppColors.primaryColor.withOpacity(0.2), Colors.transparent],
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
        final formatedDay = DateTime(day.year, day.month, day.day);
        final dayEvents = eventMaps[formatedDay] ?? [];
        final formatedEvents = (dayEvents.length > 6 ? dayEvents.sublist(0, 6) : dayEvents);
        final displayEvents = formatedEvents.where((e) {
          final containsInterest =
              ref.read(homeTabControllerProvider.notifier).containsInterest(e.category);
          final containsQuery = ref.read(homeTabControllerProvider.notifier).containsQuery(e);
          var display = containsInterest && containsQuery;

          if (selectedCategory.isNotEmpty) {
            display = display && e.category == selectedCategory;
          }
          return display;
        }).toList();

        return SizedBox(
          height: 6,
          width: 36,
          child: Row(
            children: List.generate(
              displayEvents.length,
              (index) => buildEventIndicator(
                formatedEvents[index],
                index,
                formatedEvents.length,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildEventIndicator(EventModel event, int index, int length) {
    final color = interestColors[event.category];
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
