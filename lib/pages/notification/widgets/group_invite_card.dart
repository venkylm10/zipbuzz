import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/groups/post/accept_group_model.dart';
import 'package:zipbuzz/models/notification_data.dart';
import 'package:zipbuzz/models/trace_log_model.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/utils/action_code.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';

class GroupInviteCard extends ConsumerWidget {
  final NotificationData notification;
  final String time;
  final VoidCallback rebuild;
  const GroupInviteCard({
    super.key,
    required this.notification,
    required this.time,
    required this.rebuild,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var clicked = false;
    return Padding(
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
                child: InkWell(
                  onTap: () {},
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
                        '${notification.senderName} has invited to join the group - ${notification.groupName}',
                        style: AppStyles.h5,
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                time,
                style: AppStyles.h6,
              ),
            ],
          ),
          GestureDetector(
            onTap: () async {
              if (clicked) return;
              ref.read(eventsControllerProvider.notifier).updateLoadingState(true);
              try {
                final user = ref.read(userProvider);
                final model = AcceptGroupModel(
                  groupId: notification.groupId,
                  userId: user.id,
                  groupUserAddedBy: notification.senderId,
                );
                await ref.read(groupControllerProvider.notifier).acceptInvite(model);
                await ref.read(dioServicesProvider).updateRespondedNotification(
                      ref.read(userProvider).id,
                      notification.senderId,
                      groupId: notification.groupId,
                      notificationType: 'group_accepted',
                    );
                debugPrint("Group invite accepted for ${notification.groupName}");
                clicked = false;
                ref.read(eventsControllerProvider.notifier).updateLoadingState(false);
                await Future.delayed(const Duration(milliseconds: 300));
                rebuild();
                showSnackBar(message: "Group invite accepted for ${notification.groupName}");
                final trace = TraceLogModel(
                  userId: user.id,
                  actionCode: ActionCode.GroupJoin,
                  actionDetails:
                      "Group invite accepted for ${notification.groupName}, id: ${notification.groupId}",
                  groupId: model.groupId,
                  successFlag: true,
                );
                ref.read(dioServicesProvider).traceLog(trace);
              } catch (e) {
                ref.read(eventsControllerProvider.notifier).updateLoadingState(false);
                final user = ref.read(userProvider);
                final trace = TraceLogModel(
                  userId: user.id,
                  actionCode: ActionCode.GroupJoin,
                  actionDetails:
                      "Failed invite accepted for ${notification.groupName}, id: ${notification.groupId}",
                  groupId: notification.groupId,
                  successFlag: false,
                );
                ref.read(dioServicesProvider).traceLog(trace);
                showSnackBar(message: "Something went wrong");
              }
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
    );
  }
}
