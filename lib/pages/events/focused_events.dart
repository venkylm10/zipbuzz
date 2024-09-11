import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/pages/home/widgets/event_card.dart';

class FocusedEvents extends StatelessWidget {
  const FocusedEvents({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final focusedEvents = ref.watch(eventsControllerProvider).focusedEvents;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: focusedEvents.isNotEmpty
              ? ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: focusedEvents.map(
                    (e) {
                      // final containsInterest =
                      //     ref.read(homeTabControllerProvider.notifier).containsInterest(e.category);
                      final containsQuery =
                          ref.read(homeTabControllerProvider.notifier).containsQuery(e);
                      // var display = containsInterest && containsQuery;
                      var display = containsQuery;
                      if (!display) return const SizedBox();
                      return EventCard(event: e, focusedEvent: true);
                    },
                  ).toList(),
                )
              : const SizedBox(),
        );
      },
    );
  }
}
