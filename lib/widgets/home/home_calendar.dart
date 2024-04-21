import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zipbuzz/pages/events/focused_events.dart';
import 'package:zipbuzz/pages/events/upcoming_events.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/widgets/home/event_calendar.dart';
import 'package:zipbuzz/widgets/home/home_upcoming_events.dart';

class HomeCalender extends ConsumerStatefulWidget {
  const HomeCalender({super.key});

  @override
  ConsumerState<HomeCalender> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends ConsumerState<HomeCalender> {
  bool isMounted = true;

  @override
  void dispose() {
    isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const EventCalendar(),
        _focusedEventTitle(),
        const SizedBox(height: 16),
        const FocusedEvents(),
        _upcomingEventsTitle(),
        const HomeUpcomingEvents(),
      ],
    );
  }

  String _formatWithSuffix(DateTime date) {
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

  Consumer _focusedEventTitle() {
    return Consumer(builder: (context, ref, child) {
      final focusedEvents = ref.watch(eventsControllerProvider).focusedEvents;
      final focusedDay = ref.watch(eventsControllerProvider).focusedDay;
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: focusedEvents.isNotEmpty
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatWithSuffix(focusedDay),
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
    });
  }

  Consumer _upcomingEventsTitle() {
    return Consumer(builder: (context, ref, child) {
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
    });
  }
}
