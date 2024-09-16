import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/models/notification_data.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class GroupAcceptCard extends ConsumerWidget {
  final NotificationData notification;
  final String time;
  const GroupAcceptCard({
    super.key,
    required this.notification,
    required this.time,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      'Joined Group - ${notification.groupName}',
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
        ],
      ),
    );
  }
}
