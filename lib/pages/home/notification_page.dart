import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/models/notification_data.dart';
import 'package:zipbuzz/services/dio_services.dart';
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
          "Notificaitions",
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
        },
        declineInvite: () async {
          await ref.read(dioServicesProvider).updateNotification(notification.id, "no");
          setState(() {});
        },
      );
    } else if (notification.notificationType == "yes") {
      final notiTime = DateTime.parse(notification.notificationTime);
      final timeDiff = currentTime.difference(notiTime);
      return ResponseNotiCard(
        hostName: notification.senderName,
        hostProfilePic: notification.senderProfilePicture,
        eventId: notification.eventId,
        positiveResponse: true,
        time: timeDiff.inHours == 0 ? "${timeDiff.inMinutes}min" : "${timeDiff.inHours}hr",
      );
    } else {
      final notiTime = DateTime.parse(notification.notificationTime);
      final timeDiff = currentTime.difference(notiTime);
      return ResponseNotiCard(
        hostName: notification.senderName,
        hostProfilePic: notification.senderProfilePicture,
        eventId: notification.eventId,
        positiveResponse: false,
        time: timeDiff.inHours == 0 ? "${timeDiff.inMinutes}min" : "${timeDiff.inHours}hr",
      );
    }
  }
}
