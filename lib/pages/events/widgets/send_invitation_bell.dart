import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/models/events/posts/send_invite_notification_model.dart';
import 'package:zipbuzz/pages/events/widgets/event_host_guest_list.dart';
import 'package:zipbuzz/pages/events/widgets/event_remainder_pop_up.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';

class SendNotificationBell extends ConsumerWidget {
  const SendNotificationBell({
    super.key,
    required this.event,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 6,
    ),
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  final EventModel event;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider);
    if (user.id != event.hostId) return const SizedBox();
    return InkWell(
      onTap: () async {
        showDialog(
          context: navigatorKey.currentContext!,
          barrierDismissible: true,
          builder: (context) {
            return EventReminderPopUp(
              onConfirm: () async {
                final rsvpNumbers = ref
                    .read(eventRequestMembersProvider)
                    .map((e) => e.phone)
                    .where((e) => e != user.mobileNumber)
                    .toList();
                if (rsvpNumbers.isEmpty) {
                  navigatorKey.currentState!.pop();
                  showSnackBar(message: "No one to send notification to");
                  return;
                }
                final model = SendInviteNotificationModel(
                    senderName: user.name,
                    phoneNumbers: rsvpNumbers,
                    eventName: event.title,
                    eventId: event.id,
                    hostId: user.id);
                navigatorKey.currentState!.pop();
                await ref.read(dioServicesProvider).sendInviteNotification(model);
              },
            );
          },
        );
      },
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 1,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.notifications_active_rounded,
          size: 24,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}
