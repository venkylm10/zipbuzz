import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/widgets/home/event_card.dart';

class HomeUpcomingEvents extends StatelessWidget {
  const HomeUpcomingEvents({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final upcomingEvents = ref.watch(eventsControllerProvider).upcomingEvents.where((element) {
          final date = DateTime.parse(element.date);
          return !date.isAtSameMomentAs(ref.watch(eventsControllerProvider).focusedDay);
        });
        // ignore: unused_local_variable
        final homeTabController = ref.read(homeTabControllerProvider);
        final selectedCategory = ref.watch(homeTabControllerProvider).selectedCategory;
        return SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: upcomingEvents.map((e) {
              // final containsInterest =
              //     ref.read(homeTabControllerProvider.notifier).containsInterest(e.category);
              final containsQuery = ref.read(homeTabControllerProvider.notifier).containsQuery(e);
              // var display = containsInterest && containsQuery;
              var display = containsQuery;
              if (selectedCategory.isNotEmpty) {
                display = display && e.category == selectedCategory;
              }
              if (!display) return const SizedBox();
              return EventCard(event: e);
            }).toList(),
          ),
        );
      },
    );
  }
}
