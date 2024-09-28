import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class GroupEventCalendar extends ConsumerStatefulWidget {
  const GroupEventCalendar({super.key});

  @override
  ConsumerState<GroupEventCalendar> createState() => _GroupEventCalendarState();
}

class _GroupEventCalendarState extends ConsumerState<GroupEventCalendar> {
  void onDaySelected(DateTime day, DateTime focusedDay, WidgetRef ref) {
    ref.read(groupControllerProvider.notifier).updateFocusedDay(focusedDay);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      ref.read(groupControllerProvider.notifier).updateFocusedDay(today);
    });
  }

  @override
  Widget build(BuildContext context) {
    const double rowHeight = 46;
    final eventsMap = ref.watch(groupControllerProvider).currentGroupMonthEventsMap;
    final focusedDay = ref.watch(groupControllerProvider).focusedDay;
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
        daysOfWeekHeight: 30,
        rowHeight: rowHeight,
        availableGestures: AvailableGestures.horizontalSwipe,
        calendarBuilders: customCalendarBuilders(ref),
        eventLoader: (day) => eventsMap[day] ?? [],
      ),
    );
  }

  void fetchGroupEvents(WidgetRef ref, DateTime day) async {
    final focusedMonth = DateFormat('yyyy-MM').format(ref.read(groupControllerProvider).focusedDay);
    final month = DateFormat('yyyy-MM').format(day);
    if (focusedMonth != month) {
      await Future.delayed(const Duration(milliseconds: 300));
      ref.read(groupControllerProvider.notifier).updateFocusedDay(day);
      ref.read(groupControllerProvider.notifier).fetchGroupEvents();
    }
  }

  CalendarBuilders<dynamic> customCalendarBuilders(WidgetRef ref) {
    final eventMaps = ref.watch(groupControllerProvider).currentGroupMonthEventsMap;
    return CalendarBuilders(
      headerTitleBuilder: (context, day) {
        fetchGroupEvents(ref, day);
        return Text(
          DateFormat.yMMMM().format(day),
          style: AppStyles.h2,
          textAlign: TextAlign.center,
        );
      },
      dowBuilder: (context, day) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat.E('en_US').format(day).substring(0, 2),
              textAlign: TextAlign.center,
              style: AppStyles.h4.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
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
          final containsQuery = ref.read(homeTabControllerProvider.notifier).containsQuery(e);
          var display = containsQuery;
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
