import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/widgets/home/event_card.dart';

class PastEvents extends ConsumerWidget {
  const PastEvents({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pastEvents = ref.watch(eventsControllerProvider).pastEvents;
    final userId = ref.read(userProvider).id;
    return pastEvents.isNotEmpty
        ? Column(
            children: pastEvents.map(
              (e) {
                if (e.hostId == userId) {
                  return EventCard(event: e, showHostedTag: false);
                }
                return const SizedBox();
              },
            ).toList(),
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
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
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
