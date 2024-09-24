import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/controllers/navigation_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/notification_data.dart';
import 'package:zipbuzz/pages/groups/group_details_screen.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class GroupMemberRequestCard extends ConsumerWidget {
  final NotificationData notification;
  final String time;
  final bool confirmed;

  const GroupMemberRequestCard({
    super.key,
    required this.notification,
    required this.time,
    this.confirmed = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var clicked = false;
    return GestureDetector(
      onTap: () async {
        await navigatorKey.currentState!.push(
          NavigationController.getTransition(
            GroupDetailsScreen(groupId: notification.groupId),
          ),
        );
        ref.read(eventsControllerProvider.notifier).updateLoadingState(true);
        await ref.read(homeTabControllerProvider.notifier).getNotifications();
        ref.read(eventsControllerProvider.notifier).updateLoadingState(false);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
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
                      Text(
                        confirmed
                            ? '${notification.senderName} is now a member of ${notification.groupName}'
                            : '${notification.senderName} accepted invitation to ${notification.groupName}',
                        style: AppStyles.h5,
                      ),
                    ],
                  ),
                ),
                Text(time, style: AppStyles.h6),
              ],
            ),
            if (!confirmed)
              GestureDetector(
                onTap: () async {
                  if (clicked) return;
                  clicked = true;
                  await acceptMemberRequest(ref);
                  clicked = false;
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Accept',
                    style: AppStyles.h5.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> acceptMemberRequest(WidgetRef ref) async {
    try {
      ref.read(eventsControllerProvider.notifier).updateLoadingState(true);
      await ref.read(groupControllerProvider.notifier).addMemberToGroup(notification.senderId);
      await ref.read(dioServicesProvider).updateRespondedNotification(
            ref.read(userProvider).id,
            notification.senderId,
            groupId: notification.groupId,
            notificationType: 'group_member_confirm',
          );
      await ref.read(homeTabControllerProvider.notifier).getNotifications();
    } catch (e) {
      debugPrint(e.toString());
    }
    ref.read(eventsControllerProvider.notifier).updateLoadingState(false);
  }
}
