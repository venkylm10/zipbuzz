import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/pages/events/widgets/event_buttons/event_add_to_favorite_button.dart';
import 'package:zipbuzz/pages/events/widgets/event_buttons/event_copy_button.dart';
import 'package:zipbuzz/pages/events/widgets/event_buttons/event_share_button.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class EventJoinedButton extends StatelessWidget {
  final EventModel event;
  const EventJoinedButton({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Row(
          children: [
            Expanded(
              child: Consumer(builder: (context, ref, child) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.greyColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Joined ",
                          style: AppStyles.h3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "(${event.attendees}/${event.capacity})",
                          style: AppStyles.h4.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(width: 8),
            EventShareButton(event: event),
            const SizedBox(width: 8),
            EventCopyButton(event: event),
            const SizedBox(width: 8),
            EventAddToFavoriteButton(event: event),
          ],
        ),
      ),
    );
  }
}
