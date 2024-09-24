import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/notification_data.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class GroupAcceptCard extends ConsumerWidget {
  final NotificationData notification;
  final String time;
  final bool confirmed;
  const GroupAcceptCard({
    super.key,
    required this.notification,
    required this.time,
    this.confirmed = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.read(userProvider);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              currentUser.imageUrl,
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
                  currentUser.name,
                  style: AppStyles.h5.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  softWrap: true,
                ),
                Text(
                  confirmed
                      ? "${notification.senderName} has enrolled you into ${notification.groupName}"
                      : 'You requested to join ${notification.groupName} invited by ${notification.senderName}',
                  style: AppStyles.h5,
                ),
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
}
