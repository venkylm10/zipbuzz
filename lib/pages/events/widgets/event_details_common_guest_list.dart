import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/edit_event_controller.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/pages/events/widgets/event_details_guest_list.dart';
import 'package:zipbuzz/pages/events/widgets/event_host_guest_list.dart';

class EventDetailsCommonGuestList extends ConsumerWidget {
  const EventDetailsCommonGuestList({
    super.key,
    required this.event,
    required this.isPreview,
    required this.rePublish,
    required this.clone,
    required this.hosted,
  });

  final EventModel event;
  final bool isPreview;
  final bool rePublish;
  final bool clone;
  final bool hosted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!(!event.privateGuestList || hosted)) {
      return const SizedBox();
    }
    final userId = ref.read(userProvider).id;
    final newEvent = ref.watch(newEventProvider);
    final editEvent = ref.watch(editEventControllerProvider);
    if (isPreview) {
      return EventDetailsGuestList(
        event: event,
        guests: newEvent.eventMembers,
        isPreview: true,
        clone: clone,
      );
    } else if (rePublish) {
      return EventDetailsGuestList(
        event: event,
        guests: editEvent.eventMembers,
        isPreview: false,
        clone: clone,
      );
    } else if (event.hostId != userId) {
      return EventDetailsGuestList(
        event: event,
        guests: event.eventMembers,
        isPreview: false,
        clone: clone,
        addRSVPToList: true,
      );
    }
    return EventHostGuestList(
      event: event,
      guests: event.eventMembers,
    );
  }
}