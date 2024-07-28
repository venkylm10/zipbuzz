import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/pages/home/widgets/event_card_update_rsvp_sheet.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class EventCardRsvpUpdateButton extends ConsumerWidget {
  const EventCardRsvpUpdateButton({
    super.key,
    required this.event,
    required this.updateStatus,
  });

  final EventModel event;
  final Function(String, int) updateStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (event.status != 'requested' &&
        event.status != 'confirmed' &&
        event.status != 'declined' &&
        event.status != 'pending') {
      return const SizedBox();
    }
    return InkWell(
      onTap: () async {
        await showModalBottomSheet(
          context: navigatorKey.currentContext!,
          isScrollControlled: true,
          enableDrag: true,
          builder: (context) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: EventCardRsvpUpdateSheet(
                event: event,
                updateStatus: (status, members) => updateStatus(status, members),
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.primaryColor),
        ),
        child: Text(
          "RSVP",
          style: AppStyles.h5.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
