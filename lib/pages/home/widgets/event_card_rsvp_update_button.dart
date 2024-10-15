import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/models/notification_data.dart';
import 'package:zipbuzz/pages/home/widgets/event_card_update_rsvp_sheet.dart';
import 'package:zipbuzz/pages/notification/widgets/attendee_sheet.dart';
import 'package:zipbuzz/pages/notification/widgets/ticket_event_payment_link_sheet.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';

// ignore: must_be_immutable
class EventCardRsvpUpdateButton extends ConsumerWidget {
  EventCardRsvpUpdateButton({
    super.key,
    required this.event,
    required this.updateStatus,
  });

  EventModel event;
  final Function(String, int) updateStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (event.hostId == ref.read(userProvider).id) {
      return const SizedBox();
    }
    final change =
        event.status == 'pending' || event.status == 'confirmed' || event.status == 'declined'
            ? "Change "
            : '';
    return InkWell(
      onTap: () async {
        if (change.isEmpty) {
          _requestToJoin(ref);
        } else {
          _changeRSVP();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.primaryColor),
        ),
        child: Text(
          "${change}RSVP",
          style: AppStyles.h5.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _requestToJoin(WidgetRef ref) async {
    {
      var clicked = false;
      final user = ref.read(userProvider);
      final notification = NotificationData(
        id: event.notificationId,
        senderId: event.hostId,
        senderName: user.name,
        senderProfilePicture: user.imageUrl,
        notificationType: 'zipbuzz-null',
        notificationTime: DateTime.now().toUtc().toString(),
        eventId: event.id,
        eventName: event.title,
        deviceToken: event.userDeviceToken,
        eventCategory: event.category,
      );
      await showModalBottomSheet(
        context: navigatorKey.currentContext!,
        isScrollControlled: true,
        enableDrag: true,
        builder: (context) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AttendeeNumberResponse(
              notification: notification,
              event: event,
              onSubmit: (context, attendees, commentController, amount) async {
                if (clicked) return;
                clicked = true;
                try {
                  await ref.read(eventsControllerProvider.notifier).respondToInvite(
                        event,
                        notification,
                        attendees,
                        commentController.text.trim(),
                        accepted: true,
                      );
                  clicked = false;
                  navigatorKey.currentState!.pop();
                  await Future.delayed(const Duration(milliseconds: 300));
                  event.status = "requested";
                  updateStatus('requested', event.eventMembers.length);
                  showSnackBar(message: "Requested to join event");
                  ref.read(eventsControllerProvider.notifier).updateLoadingState(false);
                  if (event.ticketTypes.isNotEmpty) {
                    await showModalBottomSheet(
                      context: navigatorKey.currentContext!,
                      isScrollControlled: true,
                      enableDrag: true,
                      builder: (context) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: TicketEventPaymentLinkSheet(
                            event: event,
                            totalAmount: amount,
                          ),
                        );
                      },
                    );
                  }
                } catch (e) {
                  clicked = false;
                  debugPrint("Error accepting the request: $e");
                  navigatorKey.currentState!.pop();
                  await Future.delayed(const Duration(milliseconds: 300));
                  showSnackBar(message: "Error accepting the request");
                }
              },
            ),
          );
        },
      );
    }
  }

  void _changeRSVP() async {
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
  }
}
