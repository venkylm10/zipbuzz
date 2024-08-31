import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/groups/post/accept_group_model.dart';
import 'package:zipbuzz/models/notification_data.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';

class GroupInviteAceeptCard extends ConsumerWidget {
  final NotificationData notification;
  final String time;
  final VoidCallback rebuild;
  const GroupInviteAceeptCard({
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
              final user = ref.read(userProvider);
              final model = AcceptGroupModel(
                groupId: notification.groupId,
                userId: user.id,
                groupUserAddedBy: notification.senderId,
              );
              await ref.read(groupControllerProvider.notifier).acceptInvite(model);
              clicked = false;
              rebuild();
              showSnackBar(message: "Group invite accepted for ${notification.groupName}");
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