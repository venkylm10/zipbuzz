import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/models/events/posts/make_request_model.dart';
import 'package:zipbuzz/models/interests/requests/user_interests_update_model.dart';
import 'package:zipbuzz/models/interests/responses/interest_model.dart';
import 'package:zipbuzz/models/notification_data.dart';
import 'package:zipbuzz/pages/events/widgets/event_buttons/event_add_to_favorite_button.dart';
import 'package:zipbuzz/pages/events/widgets/event_buttons/event_copy_button.dart';
import 'package:zipbuzz/pages/events/widgets/event_buttons/event_share_button.dart';
import 'package:zipbuzz/pages/notification/widgets/attendee_sheet.dart';
import 'package:zipbuzz/services/chat_services.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/services/notification_services.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';

class EventJoinButton extends ConsumerStatefulWidget {
  final EventModel event;
  final bool invited;
  const EventJoinButton({
    super.key,
    required this.event,
    required this.invited,
  });

  @override
  ConsumerState<EventJoinButton> createState() => _EventJoinButtonState();
}

class _EventJoinButtonState extends ConsumerState<EventJoinButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget.invited ? 100 : 48,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  widget.invited ? buildRejectButton() : buildJoinButton(invited: widget.invited),
                  const SizedBox(width: 8),
                  EventShareButton(event: widget.event),
                  const SizedBox(width: 8),
                  EventCopyButton(event: widget.event),
                  const SizedBox(width: 8),
                  EventAddToFavoriteButton(event: widget.event),
                ],
              ),
            ),
            SizedBox(height: widget.invited ? 4 : 0),
            widget.invited ? buildJoinButton(invited: widget.invited) : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Expanded buildJoinButton({bool invited = false}) {
    return Expanded(
      child: Consumer(builder: (context, ref, child) {
        return InkWell(
          onTap: () async {
            final user = ref.read(userProvider);
            final event = widget.event;
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
                      Navigator.of(context).pop();
                      ref.read(eventsControllerProvider.notifier).updateLoadingState(true);
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
                        await ref
                            .read(dioServicesProvider)
                            .increaseDecision(notification.eventId, "yes");
                        if (invited) {
                          NotificationServices.sendMessageNotification(
                            notification.eventName,
                            "${user.name} RSVP'd Yes to the event",
                            notification.deviceToken,
                            notification.eventId,
                          );
                        }
                        if (commentController.text.trim().isNotEmpty) {
                          final event = widget.event;
                          await ref
                              .read(chatServicesProvider)
                              .sendMessage(event: event, message: commentController.text);
                        }
                        widget.event.status = "requested";
                        setState(() {});
                        showSnackBar(message: "Requested to join event");
                      } catch (e) {
                        debugPrint("Error acception the request: $e");
                      }
                      ref.read(eventsControllerProvider.notifier).updateLoadingState(false);
                      final inInterests = ref
                          .read(homeTabControllerProvider.notifier)
                          .containsInterest(notification.eventCategory);
                      if (!inInterests) {
                        final interest = allInterests.firstWhere(
                            (element) => element.activity == notification.eventCategory);
                        updateInterests(interest);
                      }
                    },
                  ),
                );
              },
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(Assets.icons.add_fill, height: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Join ",
                    style: AppStyles.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "(${widget.event.attendees}/${widget.event.capacity})",
                    style: AppStyles.h4.copyWith(color: AppColors.lightGreyColor),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  void updateInterests(InterestModel interest) async {
    ref.read(homeTabControllerProvider.notifier).toggleHomeTabInterest(interest);
    await ref.read(dioServicesProvider).updateUserInterests(
          UserInterestsUpdateModel(
            userId: ref.read(userProvider).id,
            interests: ref
                .read(homeTabControllerProvider)
                .currentInterests
                .map((e) => e.activity)
                .toList(),
          ),
        );
  }

  Widget buildRejectButton() {
    return Expanded(
      child: Consumer(builder: (context, ref, child) {
        return InkWell(
          onTap: () async {
            final user = ref.read(userProvider);
            final event = widget.event;
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
                    comment: "Sorry, I can't make it",
                    onSubmit: (context, attendees, commentController) async {
                      Navigator.of(context).pop();
                      ref.read(eventsControllerProvider.notifier).updateLoadingState(true);
                      await ref.read(dioServicesProvider).updateUserNotificationYN(
                          notification.senderId, user.id, "no", notification.eventId);
                      await ref
                          .read(dioServicesProvider)
                          .updateUserNotification(notification.id, "declined");
                      try {
                        final user = ref.read(userProvider);
                        var model = MakeRequestModel(
                          userId: user.id,
                          eventId: notification.eventId,
                          name: user.name,
                          phoneNumber: user.mobileNumber,
                          members: attendees,
                          userDecision: false,
                        );
                        await ref.read(dioServicesProvider).makeRequest(model);
                        await ref
                            .read(dioServicesProvider)
                            .increaseDecision(notification.eventId, "no");
                        NotificationServices.sendMessageNotification(
                          notification.eventName,
                          "${user.name} RSVP'd No to the event",
                          notification.deviceToken,
                          notification.eventId,
                        );
                        if (commentController.text.trim().isNotEmpty) {
                          final event = widget.event;
                          await ref
                              .read(chatServicesProvider)
                              .sendMessage(event: event, message: commentController.text);
                        }
                      } catch (e) {
                        debugPrint("Error rejecting event invite: $e");
                      }
                      ref.read(eventsControllerProvider.notifier).updateLoadingState(false);
                      widget.event.status = "rejected";
                      setState(() {});
                      showSnackBar(message: "Rejected event invite");
                    },
                  ),
                );
              },
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.greyColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                "Decline",
                style: AppStyles.h3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
