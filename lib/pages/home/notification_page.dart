import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/join_request_model.dart';
import 'package:zipbuzz/models/notification_data.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/services/notification_services.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/widgets/common/back_button.dart';
import 'package:zipbuzz/widgets/home/invite_noti_card.dart';
import 'package:zipbuzz/widgets/home/response_noti_card.dart';

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
    return Scaffold(
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
          await ref.read(dioServicesProvider).updateNotification(notification.id, "yes");
          setState(() {});
          final user = ref.read(userProvider);
          var model = JoinEventRequestModel(
              eventId: notification.eventId,
              name: user.name,
              phoneNumber: user.mobileNumber,
              image: user.imageUrl);
          await ref.read(dioServicesProvider).requestToJoinEvent(model);
          await ref.read(dioServicesProvider).increaseDecision(notification.eventId, "yes");
          NotificationServices.sendMessageNotification(
            notification.eventName,
            "${user.name} RSVP'd Yes to the event",
            notification.deviceToken,
            notification.eventId,
          );
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
        hostName: notification.senderName,
        hostProfilePic: notification.senderProfilePicture,
        eventId: notification.eventId,
        eventName: notification.eventName,
        positiveResponse: true,
        time: timeDiff.inHours == 0 ? "${timeDiff.inMinutes}min" : "${timeDiff.inHours}hr",
      );
    } else if (notification.notificationType == "no") {
      final notiTime = DateTime.parse(notification.notificationTime);
      final timeDiff = currentTime.difference(notiTime);
      return ResponseNotiCard(
        hostName: notification.senderName,
        hostProfilePic: notification.senderProfilePicture,
        eventId: notification.eventId,
        eventName: notification.eventName,
        positiveResponse: false,
        time: timeDiff.inHours == 0 ? "${timeDiff.inMinutes}min" : "${timeDiff.inHours}hr",
      );
    } else {
      final notiTime = DateTime.parse(notification.notificationTime);
      final timeDiff = currentTime.difference(notiTime);
      return ResponseNotiCard(
        hostName: notification.senderName,
        hostProfilePic: notification.senderProfilePicture,
        eventId: notification.eventId,
        eventName: notification.eventName,
        positiveResponse: false,
        confirmResponse: true,
        time: timeDiff.inHours == 0 ? "${timeDiff.inMinutes}min" : "${timeDiff.inHours}hr",
      );
    }
  }
}
