import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/edit_event_controller.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/pages/events/widgets/attendee_numbers.dart';
import 'package:zipbuzz/pages/events/widgets/event_host_guest_list.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';

class EventDetailsAttendeeNumbers extends ConsumerWidget {
  const EventDetailsAttendeeNumbers({
    super.key,
    required this.event,
    required this.isPreview,
    required this.rePublish,
  });
  final EventModel event;
  final bool isPreview;
  final bool rePublish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => _showHostGuestListSheet(ref),
      child: Consumer(
        builder: (context, ref, child) {
          var data = ref.watch(eventRequestMembersProvider);
          final confirmedMembers = data
              .where((element) => element.status == "confirm" || element.status == 'host')
              .toList();
          final respondedMembers = data;
          String attendees = "";
          if (isPreview) {
            attendees = "${ref.watch(newEventProvider).attendees},0,0";
          } else {
            var responded = 0;
            for (var e in respondedMembers) {
              responded = responded + e.attendees;
            }
            var confirmed = 0;
            for (var e in confirmedMembers) {
              confirmed = confirmed + e.attendees;
            }
            attendees = "${event.eventMembers.length},$responded,$confirmed";
          }

          var total = 1;

          if (isPreview) {
            total = ref.watch(newEventProvider).capacity;
          } else if (rePublish) {
            total = ref.watch(editEventControllerProvider).capacity;
          } else {
            total = event.capacity;
          }
          return AttendeeNumbers(
            attendees: attendees,
            total: total,
            backgroundColor: AppColors.greyColor.withOpacity(0.1),
          );
        },
      ),
    );
  }

  void _showHostGuestListSheet(WidgetRef ref) {
    final hosted = event.hostId == ref.read(userProvider).id;
    if (isPreview || rePublish) return;
    if (!(!event.privateGuestList || hosted)) return;
    showModalBottomSheet(
      context: navigatorKey.currentContext!,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) {
        var guests = isPreview ? ref.watch(newEventProvider).eventMembers : event.eventMembers;
        if (rePublish) {
          guests = ref.read(editEventControllerProvider).eventMembers;
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(8),
              width: kIsWeb
                  ? MediaQuery.of(context).size.height * Assets.images.border_ratio * 0.9
                  : null,
              child: EventHostGuestList(
                event: event,
                guests: guests,
                interative: false,
              ),
            ),
          ),
        );
      },
    );
  }
}
