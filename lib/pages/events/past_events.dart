import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/events_tab_controler.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/widgets/home/event_card.dart';

class PastEvents extends ConsumerWidget {
  const PastEvents({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.read(userProvider).id;
    var ownPastEvents = <EventModel>[];
    ownPastEvents.addAll(ref
        .watch(eventsControllerProvider)
        .pastEvents
        .where((element) => element.hostId == userId));
    return ownPastEvents.isNotEmpty
        ? Column(
            children: ownPastEvents.map((e) => EventCard(event: e, showTag: false)).toList(),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              Image.asset(Assets.images.no_events, height: 200),
              const SizedBox(height: 24),
              Text(
                "No Past Events",
                style: AppStyles.h2.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                "Events you have attended will show up here.",
                style: AppStyles.h4,
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () {
                  ref.read(eventTabControllerProvider.notifier).updateIndex(2);
                },
                child: Ink(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    "Create event",
                    style: AppStyles.h4.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}
