import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/models/events/posts/make_request_model.dart';
import 'package:zipbuzz/models/notification_data.dart';
import 'package:zipbuzz/pages/home/widgets/event_card_update_rsvp_sheet.dart';
import 'package:zipbuzz/pages/notification/widgets/attendee_sheet.dart';
import 'package:zipbuzz/services/chat_services.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/services/notification_services.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';

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
              onSubmit: (context, attendees, commentController) async {
                if (clicked) return;
                clicked = true;
                await ref.read(dioServicesProvider).updateUserNotificationYN(
                    notification.senderId, user.id, "yes", notification.eventId);
                await ref
                    .read(dioServicesProvider)
                    .updateUserNotification(notification.id, "requested");
                try {
                  final user = ref.read(userProvider);
                  var model = MakeRequestModel(
                    userId: user.id,
                    eventId: notification.eventId,
                    name: user.name,
                    phoneNumber: user.mobileNumber,
                    members: attendees,
                    userDecision: true,
                  );
                  await ref.read(dioServicesProvider).makeRequest(model);
                  await ref.read(dioServicesProvider).increaseDecision(notification.eventId, "yes");
                  NotificationServices.sendMessageNotification(
                    notification.eventName,
                    "${user.name} RSVP'd Yes to the event",
                    notification.deviceToken,
                    notification.eventId,
                  );
                  if (commentController.text.trim().isNotEmpty) {
                    await ref
                        .read(chatServicesProvider)
                        .sendMessage(event: event, message: commentController.text);
                  }
                  await Future.delayed(const Duration(milliseconds: 300));
                  clicked = false;
                  navigatorKey.currentState!.pop();
                  await Future.delayed(const Duration(milliseconds: 300));
                  showSnackBar(message: "Requested to join event");
                } catch (e) {
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
