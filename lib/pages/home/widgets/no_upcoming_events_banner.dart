import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/events_tab_controler.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/tabs.dart';

class NoUpcomingEventsBanner extends ConsumerWidget {
  const NoUpcomingEventsBanner({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Image.asset(Assets.images.no_events_image),
        Positioned(
          left: 0,
          right: 0,
          top: 260,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  ref
                      .read(homeTabControllerProvider.notifier)
                      .updateSelectedTab(AppTabs.events);
                  ref.read(eventTabControllerProvider.notifier).updateIndex(2);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xffFF9635),
                        const Color(0xffFF0099).withOpacity(0.65),
                      ],
                    ),
                  ),
                  child: Text(
                    "Create Event",
                    style: AppStyles.h4.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}