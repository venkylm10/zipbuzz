import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/controllers/events/edit_event_controller.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/pages/events/widgets/event_buttons/event_edit_button.dart';
import 'package:zipbuzz/pages/events/widgets/event_buttons/event_invite_guests_button.dart';
import 'package:zipbuzz/pages/events/widgets/event_buttons/event_invite_more_guests_button.dart';
import 'package:zipbuzz/pages/events/widgets/event_buttons/event_join_button.dart';
import 'package:zipbuzz/pages/events/widgets/event_buttons/event_joined_button.dart';
import 'package:zipbuzz/pages/events/widgets/event_buttons/event_link_button.dart';
import 'package:zipbuzz/pages/events/widgets/event_buttons/event_publish_button.dart';
import 'package:zipbuzz/pages/events/widgets/event_buttons/event_rejected_button.dart';
import 'package:zipbuzz/pages/events/widgets/event_buttons/event_republish_buttons.dart';
import 'package:zipbuzz/pages/events/widgets/event_buttons/event_requested_buttons.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/pages/events/widgets/event_select_contacts_sheet.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';

class EventButtons extends ConsumerStatefulWidget {
  const EventButtons({
    required this.event,
    this.isPreview = false,
    this.rePublish = false,
    this.groupEvent = false,
    super.key,
  });

  final EventModel event;
  final bool isPreview;
  final bool rePublish;
  final bool groupEvent;

  @override
  ConsumerState<EventButtons> createState() => _EventButtonsState();
}

class _EventButtonsState extends ConsumerState<EventButtons> {
  void publishEvent(WidgetRef ref) async {
    await ref.read(newEventProvider.notifier).publishEvent();
  }

  @override
  Widget build(BuildContext context) {
    return !widget.isPreview ? eventDetailsButtons() : eventPreviewButtons();
  }

  Widget eventPreviewButtons() {
    return Container(
      width: double.infinity,
      height: 104,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Column(
          children: [
            Row(
              children: [
                if (!widget.isPreview) const EventLinkButton(),
                Expanded(
                  child: EventInviteGuestsButton(
                    inviteContacts: () => inviteContacts(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: EventPublishButton(groupEvent: widget.groupEvent),
            ),
          ],
        ),
      ),
    );
  }

  Widget eventDetailsButtons() {
    final userId = GetStorage().read(BoxConstants.id);
    if (userId == widget.event.hostId) {
      if (widget.rePublish) {
        return EventRepublishButtons(
          inviteContacts: () => inviteContacts(false),
          republishEvent: (loadingText) {
            if (loadingText == null) {
              ref.read(editEventControllerProvider.notifier).rePublishEvent();
            }
          },
        );
      }
      return editShareButtons();
    } else if (widget.event.status == "requested" || widget.event.status == "pending") {
      return EventRequestedButton(event: widget.event);
    } else if (widget.event.status == "confirmed") {
      return EventJoinedButton(event: widget.event);
    } else if (widget.event.status == "rejected") {
      return EventRejectedButton(event: widget.event);
    }
    return EventJoinButton(
      event: widget.event,
      invited: widget.event.status == "invited",
    );
  }

  Widget editShareButtons() {
    return Consumer(builder: (context, ref, child) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            EventInviteMoreGuestsButton(
                event: widget.event, inviteContacts: () => inviteContacts(true)),
            const SizedBox(height: 8),
            EventEditButton(event: widget.event),
          ],
        ),
      );
    });
  }

  void inviteContacts(bool edit) async {
    if (kIsWeb) {
      showSnackBar(message: "This feature is not available on web");
      return;
    }
    await showModalBottomSheet(
      context: navigatorKey.currentContext!,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: EventSelectContactSheet(edit: edit),
        );
      },
    );
  }
}
