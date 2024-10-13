import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/edit_event_controller.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class CreateEventTicketTypeFields extends StatelessWidget {
  final bool rePublish;
  const CreateEventTicketTypeFields({super.key, required this.rePublish});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        EventModel event;
        if (rePublish) {
          event = ref.watch(editEventControllerProvider);
        } else {
          event = ref.watch(newEventProvider);
        }
        return Row(
          children: [
            Text("Ticketed Event", style: AppStyles.h4),
            Switch.adaptive(
              value: event.ticketTypes.isNotEmpty,
              onChanged: (val) {
                if (rePublish) {
                  ref.read(editEventControllerProvider.notifier).toggleTicketTypes(val);
                } else {
                  ref.read(newEventProvider.notifier).toggleTicketTypes(val);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
