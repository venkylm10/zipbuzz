import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/posts/make_request_model.dart';
import 'package:zipbuzz/models/interests/requests/user_interests_update_model.dart';
import 'package:zipbuzz/models/interests/responses/interest_model.dart';
import 'package:zipbuzz/models/notification_data.dart';
import 'package:zipbuzz/pages/events/event_details_page.dart';
import 'package:zipbuzz/pages/notification/widgets/attendee_sheet.dart';
import 'package:zipbuzz/services/chat_services.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/services/notification_services.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';
import 'package:zipbuzz/pages/events/widgets/event_host_guest_list.dart';

class InviteNotiCard extends ConsumerWidget {
  const InviteNotiCard({
    super.key,
    required this.notification,
    required this.time,
    required this.rebuildCall,
  });

  final NotificationData notification;
  final String time;
  final VoidCallback rebuildCall;

  void navigateToEventDetails(WidgetRef ref) async {
    showSnackBar(message: "Getting event details...");
    final event = await ref.read(dbServicesProvider).getEventDetails(notification.eventId);
    final dominantColor = await getDominantColor(event.bannerPath);
    ref.read(guestListTagProvider.notifier).update((state) => "Invited");
    await navigatorKey.currentState!.pushNamed(EventDetailsPage.id, arguments: {
      "event": event,
      "dominantColor": dominantColor,
      "isPreview": false,
      "rePublish": false,
      "randInt": 0,
    });
    rebuildCall();
  }

  Future<Color> getDominantColor(String bannerPath) async {
    Color dominantColor = Colors.green;
    final image = NetworkImage(bannerPath);
    final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
      image,
    );
    dominantColor = generator.dominantColor!.color;
    return dominantColor;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              notification.senderProfilePicture,
              height: 44,
              width: 44,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.senderName,
                  style: AppStyles.h5.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  softWrap: true,
                ),
                InkWell(
                  onTap: () => navigateToEventDetails(ref),
                  child: RichText(
                    softWrap: true,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Invited you for ',
                          style: AppStyles.h5,
                        ),
                        TextSpan(
                          text: notification.eventName,
                          style: AppStyles.h5.copyWith(
                            color: AppColors.primaryColor,
                            fontStyle: FontStyle.italic,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => acceptInvite(ref),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'RSVP - Yes',
                              style: AppStyles.h5.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () => declineInvite(ref),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.borderGrey,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'RSVP - No',
                              style: AppStyles.h5.copyWith(
                                color: AppColors.greyColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Text(
            time,
            style: AppStyles.h6,
          ),
        ],
      ),
    );
  }

  Future<void> acceptInvite(WidgetRef ref) async {
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
              final user = ref.read(userProvider);
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
                  final event =
                      await ref.read(dbServicesProvider).getEventDetails(notification.eventId);
                  await ref
                      .read(chatServicesProvider)
                      .sendMessage(event: event, message: commentController.text);
                }
              } catch (e) {
                debugPrint("Error requesting to join: $e");
              }
              ref.read(eventsControllerProvider.notifier).updateLoadingState(false);
              final inInterests = ref
                  .read(homeTabControllerProvider.notifier)
                  .containsInterest(notification.eventCategory);
              if (!inInterests) {
                final interest = allInterests
                    .firstWhere((element) => element.activity == notification.eventCategory);
                updateInterests(interest, ref);
              }
              rebuildCall();
            },
          ),
        );
      },
    );
  }

  Future<void> declineInvite(WidgetRef ref) async {
    showModalBottomSheet(
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
              final user = ref.read(userProvider);
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
                await ref.read(dioServicesProvider).increaseDecision(notification.eventId, "no");
                NotificationServices.sendMessageNotification(
                  notification.eventName,
                  "${user.name} RSVP'd No to the event",
                  notification.deviceToken,
                  notification.eventId,
                );
              } catch (e) {
                debugPrint("Error declining invite: $e");
              }
              ref.read(eventsControllerProvider.notifier).updateLoadingState(false);
              rebuildCall();
            },
          ),
        );
      },
    );
  }

  void updateInterests(InterestModel interest, WidgetRef ref) async {
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
}