import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/controllers/events_controller.dart';
import 'package:zipbuzz/models/event_model.dart';
import 'package:zipbuzz/widgets/home/event_card.dart';

class PastEvents extends ConsumerStatefulWidget {
  const PastEvents({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PastEventsState();
}

class _PastEventsState extends ConsumerState<PastEvents> {
  List<EventModel> pastEvents = [];

  @override
  void initState() {
    ref.read(eventsControllerProvider).updatePastEvents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    pastEvents = ref.watch(eventsControllerProvider).pastEvents;
    return pastEvents.isNotEmpty
        ? Column(
            children: pastEvents
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
                "No Past Events",
                style: AppStyles.h2.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                "Events you have attended will show up here.",
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
