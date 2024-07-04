import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/pages/home/widgets/event_card.dart';

class EventsSearchResults extends StatelessWidget {
  const EventsSearchResults({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
          child: Text(
            "Search results",
            style: AppStyles.h2,
          ),
        ),
        Consumer(
          builder: (context, ref, child) {
            final allEvents = ref.watch(eventsControllerProvider).currentMonthEvents;
            // ignore: unused_local_variable
            final homeTabController = ref.read(homeTabControllerProvider);
            final selectedCategory = ref.watch(homeTabControllerProvider).selectedCategory;

            final filteredEvents = allEvents.where((e) {
              // final containsInterest =
              //     ref.read(homeTabControllerProvider.notifier).containsInterest(e.category);
              final containsQuery = ref.read(homeTabControllerProvider.notifier).containsQuery(e);
              // var display = containsInterest && containsQuery;
              var display = containsQuery;
              if (selectedCategory.isNotEmpty) {
                display = display && e.category == selectedCategory;
              }
              return display;
            }).toList();

            if (filteredEvents.isEmpty) {
              return Center(
                child: Text(
                  "No events found",
                  style: AppStyles.h3.copyWith(
                    color: AppColors.greyColor,
                  ),
                ),
              );
            }
            return Column(
              children: filteredEvents.map((e) {
                return EventCard(event: e);
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
