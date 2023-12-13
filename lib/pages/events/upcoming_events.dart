import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/widgets/home/event_card.dart';

class UpcomingEvents extends ConsumerStatefulWidget {
  const UpcomingEvents({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UpcomingEventsState();
}

class _UpcomingEventsState extends ConsumerState<UpcomingEvents> {
  List<EventModel> upcomingEvents = [];

  @override
  void initState() {
    ref.read(eventsControllerProvider).updateUpcomingEvents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    upcomingEvents = ref.watch(eventsControllerProvider).upcomingEvents;
    return upcomingEvents.isNotEmpty
        ? Column(
            children: upcomingEvents
                .map(
                  (e) => EventCard(event: e),
                )
                .toList(),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              Image.asset(Assets.images.no_events, height: 200),
              const SizedBox(height: 24),
              Text(
                "No Events lined up",
                style: AppStyles.h2.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                "Your registered events will show up here.",
                style: AppStyles.h4,
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () {},
                child: Ink(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    "Browse events",
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
