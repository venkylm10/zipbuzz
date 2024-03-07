import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/widgets/home/event_card.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';

class CustomCalendar extends ConsumerStatefulWidget {
  const CustomCalendar({super.key});

  @override
  ConsumerState<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends ConsumerState<CustomCalendar> {
  bool isMounted = true;

  void onDaySelected(DateTime day, DateTime focusedDay) {
    ref.read(eventsControllerProvider.notifier).updatedFocusedDay(focusedDay);
    ref.read(eventsControllerProvider.notifier).updateFocusedEvents();
    setState(() {});
  }

  @override
  void initState() {
    getAllEvents();
    super.initState();
  }

  @override
  void dispose() {
    isMounted = false;
    super.dispose();
  }

  void getAllEvents() async {
    if (isMounted) await ref.read(eventsControllerProvider.notifier).getAllEvents();
    if (isMounted) ref.read(eventsControllerProvider.notifier).updateUpcomingEvents();
    if (isMounted) ref.read(eventsControllerProvider.notifier).updateFocusedEvents();
    if (isMounted) setState(() {});
  }

  String formatWithSuffix(DateTime date) {
    String dayOfMonth = DateFormat('d').format(date);
    String suffix;
    if (dayOfMonth.endsWith('1') && dayOfMonth != '11') {
      suffix = 'st';
    } else if (dayOfMonth.endsWith('2') && dayOfMonth != '12') {
      suffix = 'nd';
    } else if (dayOfMonth.endsWith('3') && dayOfMonth != '13') {
      suffix = 'rd';
    } else {
      suffix = 'th';
    }
    return DateFormat('d\'$suffix\' MMM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    const double rowHeight = 36;
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
          child: Consumer(builder: (context, ref, child) {
            final eventsMap = ref.watch(eventsControllerProvider).eventsMap;
            final focusedDay = ref.watch(eventsControllerProvider).focusedDay;
            return TableCalendar(
              focusedDay: focusedDay,
              firstDay: DateTime.utc(2022),
              lastDay: DateTime.now().add(const Duration(days: 365 * 2)),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: AppStyles.h2,
              ),
              selectedDayPredicate: (day) => isSameDay(day, focusedDay),
              onDaySelected: onDaySelected,
              startingDayOfWeek: StartingDayOfWeek.monday,
              rowHeight: rowHeight,
              availableGestures: AvailableGestures.horizontalSwipe,
              calendarBuilders: customCalendarBuilders(),
              eventLoader: (day) => eventsMap[day] ?? [],
            );
          }),
        ),
        Consumer(builder: (context, ref, child) {
          final focusedEvents = ref.watch(eventsControllerProvider).focusedEvents;
          final focusedDay = ref.watch(eventsControllerProvider).focusedDay;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: focusedEvents.isNotEmpty
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        formatWithSuffix(focusedDay),
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
          );
        }),
        const SizedBox(height: 15),
        Consumer(builder: (context, ref, child) {
          final focusedEvents = ref.watch(eventsControllerProvider).focusedEvents;
          // ignore: unused_local_variable
          final homeTabController = ref.read(homeTabControllerProvider);
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: focusedEvents.isNotEmpty
                ? Consumer(builder: (context, ref, child) {
                    final focusedEvents = ref.watch(eventsControllerProvider).focusedEvents;
                    final selectedCategory = ref.watch(homeTabControllerProvider).selectedCategory;
                    return Column(
                      children: focusedEvents.map((e) {
                        final containsInterest = ref
                            .read(homeTabControllerProvider.notifier)
                            .containsInterest(e.category);
                        final containsQuery =
                            ref.read(homeTabControllerProvider.notifier).containsQuery(e);
                        var display = containsInterest && containsQuery;
                        if (selectedCategory.isNotEmpty) {
                          display = display && e.category == selectedCategory;
                        }
                        if (!display) return const SizedBox();
                        return EventCard(event: e, focusedEvent: true);
                      }).toList(),
                    );
                  })
                : const SizedBox(),
          );
        }),
        Consumer(builder: (context, ref, child) {
          final upcomingEvents = ref.watch(eventsControllerProvider).upcomingEvents;
          return upcomingEvents.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 10),
                  child: Text(
                    "Upcoming Events",
                    style: AppStyles.h2.copyWith(fontWeight: FontWeight.w600),
                  ),
                )
              : const SizedBox();
        }),
        Consumer(
          builder: (context, ref, child) {
            final upcomingEvents = ref.watch(eventsControllerProvider).upcomingEvents;
            // ignore: unused_local_variable
            final homeTabController = ref.read(homeTabControllerProvider);
            final selectedCategory = ref.watch(homeTabControllerProvider).selectedCategory;
            return Column(
              children: upcomingEvents.map((e) {
                final containsInterest =
                    ref.read(homeTabControllerProvider.notifier).containsInterest(e.category);
                final containsQuery = ref.read(homeTabControllerProvider.notifier).containsQuery(e);
                var display = containsInterest && containsQuery;
                if (selectedCategory.isNotEmpty) {
                  display = display && e.category == selectedCategory;
                }
                if (!display) return const SizedBox();
                return EventCard(event: e);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  CalendarBuilders<dynamic> customCalendarBuilders() {
    final eventMaps = ref.watch(eventsControllerProvider).eventsMap;
    // ignore: unused_local_variable
    final homeTabController = ref.watch(homeTabControllerProvider);
    final selectedCategory = ref.watch(homeTabControllerProvider).selectedCategory;
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
