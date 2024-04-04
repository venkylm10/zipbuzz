import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/interests/requests/user_interests_update_model.dart';
import 'package:zipbuzz/models/interests/responses/interest_model.dart';
import 'package:zipbuzz/models/notification_data.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/services/notification_services.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/widgets/common/back_button.dart';
import 'package:zipbuzz/widgets/common/custom_bezel.dart';
import 'package:zipbuzz/widgets/home/invite_noti_card.dart';
import 'package:zipbuzz/widgets/home/response_noti_card.dart';
import 'package:zipbuzz/widgets/notification_page/attendee_sheet.dart';

class NotificationPage extends ConsumerStatefulWidget {
  static const id = "/notification_page";
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  final currentTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return CustomBezel(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            leading: backButton(),
            title: Text(
              "Notifications",
              style: AppStyles.h2.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: FutureBuilder(
            future: ref.read(dioServicesProvider).getNotifications(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }
              final notifications = snapshot.data as List<NotificationData>;
              if (notifications.isEmpty) {
                return Center(
                  child: Text(
                    "No Notifications",
                    style: AppStyles.h4.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightGreyColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                );
              }
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16).copyWith(bottom: 0),
                  child: Column(
                    children: notifications
                        .map(
                          (e) => buildNotificationCard(e),
                        )
                        .toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildNotificationCard(NotificationData notification) {
    if (notification.notificationType == "invited") {
      final notiTime = DateTime.parse(notification.notificationTime);
      final timeDiff = currentTime.difference(notiTime);
      return InviteNotiCard(
        hostName: notification.senderName,
        hostProfilePic: notification.senderProfilePicture,
        eventId: notification.eventId,
        eventName: notification.eventName,
        time: timeDiff.inHours == 0 ? "${timeDiff.inMinutes}min" : "${timeDiff.inHours}hr",
        acceptInvite: () async {
          await showModalBottomSheet(
            context: navigatorKey.currentContext!,
            isScrollControlled: true,
            enableDrag: true,
            builder: (context) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AttendeeNumberResponse(notification: notification),
              );
            },
          );
          final inInterests = ref
              .read(homeTabControllerProvider.notifier)
              .containsInterest(notification.eventCategory);
          if (!inInterests) {
            final interest = allInterests
                .firstWhere((element) => element.activity == notification.eventCategory);
            updateInterests(interest);
          }
          setState(() {});
        },
        declineInvite: () async {
          await ref.read(dioServicesProvider).updateNotification(notification.id, "no");
          setState(() {});
          await ref.read(dioServicesProvider).increaseDecision(notification.eventId, "no");
          final user = ref.read(userProvider);
          NotificationServices.sendMessageNotification(
            notification.eventName,
            "${user.name} RSVP'd No to the event",
            notification.deviceToken,
            notification.eventId,
          );
        },
      );
    } else if (notification.notificationType == "yes") {
      final notiTime = DateTime.parse(notification.notificationTime);
      final timeDiff = currentTime.difference(notiTime);
      return ResponseNotiCard(
        senderName: notification.senderName,
        senderProfilePic: notification.senderProfilePicture,
        eventId: notification.eventId,
        eventName: notification.eventName,
        positiveResponse: true,
        time: timeDiff.inHours == 0 ? "${timeDiff.inMinutes}min" : "${timeDiff.inHours}hr",
      );
    } else if (notification.notificationType == "no") {
      final notiTime = DateTime.parse(notification.notificationTime);
      final timeDiff = currentTime.difference(notiTime);
      return ResponseNotiCard(
        senderName: notification.senderName,
        senderProfilePic: notification.senderProfilePicture,
        eventId: notification.eventId,
        eventName: notification.eventName,
        positiveResponse: false,
        time: timeDiff.inHours == 0 ? "${timeDiff.inMinutes}min" : "${timeDiff.inHours}hr",
      );
    } else {
      final notiTime = DateTime.parse(notification.notificationTime);
      final timeDiff = currentTime.difference(notiTime);
      return ResponseNotiCard(
        senderName: notification.senderName,
        senderProfilePic: notification.senderProfilePicture,
        eventId: notification.eventId,
        eventName: notification.eventName,
        positiveResponse: false,
        confirmResponse: true,
        time: timeDiff.inHours == 0 ? "${timeDiff.inMinutes}min" : "${timeDiff.inHours}hr",
      );
    }
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
}
