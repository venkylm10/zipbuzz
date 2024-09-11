import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/pages/home/widgets/event_card.dart';
import 'package:zipbuzz/pages/home/widgets/home_calendar.dart';
import 'package:zipbuzz/pages/home/widgets/no_upcoming_events_banner.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class HomeUpcomingEvents extends StatelessWidget {
  const HomeUpcomingEvents({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        _upcomingEventsTitle(),
        _buildHomeCalendar(),
        _buildUpcomingEvents(),
      ],
    );
  }

  Widget _buildHomeCalendar() {
    return Consumer(builder: (context, ref, child) {
      final visible = ref.watch(homeTabControllerProvider).homeCalenderVisible;
      return visible ? const HomeCalender() : const SizedBox();
    });
  }

  Consumer _buildUpcomingEvents() {
    return Consumer(
      builder: (context, ref, child) {
        final visible = ref.watch(homeTabControllerProvider).homeCalenderVisible;
        if (visible) return const SizedBox();
        final upcomingEvents = ref.watch(eventsControllerProvider).upcomingEvents;
        if (upcomingEvents.isEmpty) {
          return const NoUpcomingEventsBanner();
        }
        return SizedBox(
          width: double.infinity,
          child: ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: upcomingEvents.map((e) {
              if (!ref.watch(homeTabControllerProvider).inQuery) {
                return EventCard(event: e);
              }
              final containsQuery = ref.read(homeTabControllerProvider.notifier).containsQuery(e);
              if (!containsQuery) return const SizedBox();
              return EventCard(event: e);
            }).toList(),
          ),
        );
      },
    );
  }

  Consumer _upcomingEventsTitle() {
    return Consumer(
      builder: (context, ref, child) {
        final visible = ref.watch(homeTabControllerProvider).homeCalenderVisible;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 0, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Upcoming Events",
                style: AppStyles.h2.copyWith(fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: () {
                  ref.read(homeTabControllerProvider.notifier).toggleHomeCalenderVisibility();
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SvgPicture.asset(
                    visible
                        ? Assets.icons.home_calender_visible
                        : Assets.icons.home_calender_not_visible,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
