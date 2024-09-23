import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/controllers/profile/edit_profile_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/notification_data.dart';
import 'package:zipbuzz/pages/notification/widgets/broadcast_noti_card.dart';
import 'package:zipbuzz/pages/notification/widgets/group_accepted_card.dart';
import 'package:zipbuzz/pages/notification/widgets/group_invite_card.dart';
import 'package:zipbuzz/pages/notification/widgets/reminder_noti_card.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/back_button.dart';
import 'package:zipbuzz/utils/widgets/custom_bezel.dart';
import 'package:zipbuzz/pages/notification/widgets/invite_noti_card.dart';
import 'package:zipbuzz/pages/notification/widgets/response_noti_card.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationPage extends ConsumerStatefulWidget {
  static const id = "/notification_page";
  final int? groupId;
  const NotificationPage({super.key, this.groupId});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  final currentTime = DateTime.now();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateNotification();
      _scrollToHighlightedCard();
    });
  }

  void updateNotification() async {
    ref.read(editProfileControllerProvider).resetNotificationCount();
    ref.read(userProvider.notifier).update((state) => state.copyWith(notificationCount: 0));
  }

  void _scrollToHighlightedCard() async {
    await ref.read(homeTabControllerProvider.notifier).getNotifications();
    if (widget.groupId == null) return;
    final notifications = ref.read(homeTabControllerProvider).notifications;
    final int index = notifications.indexWhere(
      (notification) => notification.groupId == widget.groupId,
    );
    if (index != -1) {
      _scrollController.animateTo(
        index * 100.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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
                  child: Padding(
                    padding: const EdgeInsets.all(16).copyWith(bottom: 0),
                    child: Consumer(builder: (context, ref, child) {
                      final notifications = ref.watch(homeTabControllerProvider).notifications;
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: notifications.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          return buildNotificationCard(notifications[index]);
                        },
                      );
                    }),
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
      case 'group_accepted' || 'group_confirmed':
        return GroupAcceptCard(
          notification: notification,
          time: timeago.format(notiTime, locale: 'en_short'),
          confirmed: notification.notificationType == 'group_confirmed',
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
