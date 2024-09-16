import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/profile/edit_profile_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/notification_data.dart';
import 'package:zipbuzz/pages/notification/widgets/broadcast_noti_card.dart';
import 'package:zipbuzz/pages/notification/widgets/group_accepted_card.dart';
import 'package:zipbuzz/pages/notification/widgets/group_invite_card.dart';
import 'package:zipbuzz/pages/notification/widgets/reminder_noti_card.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/back_button.dart';
import 'package:zipbuzz/utils/widgets/custom_bezel.dart';
import 'package:zipbuzz/pages/notification/widgets/invite_noti_card.dart';
import 'package:zipbuzz/pages/notification/widgets/response_noti_card.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationPage extends ConsumerStatefulWidget {
  static const id = "/notification_page";
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  final currentTime = DateTime.now();

  @override
  void initState() {
    updateNotification();
    super.initState();
  }

  void updateNotification() async {
    ref.read(editProfileControllerProvider).resetNotificationCount();
    await Future.delayed(const Duration(milliseconds: 500));
    ref.read(userProvider.notifier).update((state) => state.copyWith(notificationCount: 0));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
          body: SizedBox(
            height: size.height,
            width: size.width,
            child: Stack(
              children: [
                Positioned.fill(
                  child: FutureBuilder(
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
                buildLoader(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNotificationCard(NotificationData notification) {
    final time = notification.notificationTime.endsWith('Z')
        ? notification.notificationTime
        : "${notification.notificationTime}Z";
    final notiTime = DateTime.parse(time);
    switch (notification.notificationType) {
      case 'invited':
        return InviteNotiCard(
          notification: notification,
          time: timeago.format(notiTime, locale: 'en_short'),
          rebuildCall: () {
            setState(() {});
          },
        );
      case 'reminder':
        return ReminderNotiCard(
          notification: notification,
          time: timeago.format(notiTime, locale: 'en_short'),
          rebuildCall: () {
            setState(() {});
          },
        );
      case 'requested' || 'declined' || 'accepted' || 'confirmed' || 'yes' || 'no':
        return ResponseNotiCard(
          senderId: notification.senderId,
          senderName: notification.senderName,
          senderProfilePic: notification.senderProfilePicture,
          eventId: notification.eventId,
          eventName: notification.eventName,
          time: timeago.format(notiTime, locale: 'en_short'),
          notificationId: notification.id,
          senderDeviceToken: notification.deviceToken,
          notificationType: notification.notificationType,
          rebuild: () {
            setState(() {});
          },
        );
      case 'group_invited':
        return GroupInviteCard(
            notification: notification,
            time: timeago.format(notiTime, locale: 'en_short'),
            rebuild: () {
              setState(() {});
            });
      case 'group_accepted':
        return GroupAcceptCard(
          notification: notification,
          time: timeago.format(notiTime, locale: 'en_short'),
        );
      default:
        return BroadcastNotiCard(
          notification: notification,
          time: timeago.format(notiTime, locale: 'en_short'),
        );
    }
  }

  Widget buildLoader() {
    return Consumer(
      builder: (context, ref, child) {
        final loading = ref.watch(eventsControllerProvider).loading;
        return loading
            ? Positioned.fill(
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 4,
                      sigmaY: 4,
                    ),
                    child: const Center(
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox();
      },
    );
  }
}
