import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/event_invite_members.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/pages/events/widgets/send_broadcast_message_sheet.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/globals.dart';

class SendBroadcastMessageButton extends ConsumerWidget {
  const SendBroadcastMessageButton({
    super.key,
    required this.event,
    required this.guests,
  });

  final EventModel event;
  final List<EventInviteMember> guests;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider);
    if (user.id != event.hostId) return const SizedBox();
    return InkWell(
      onTap: () async {
        await showModalBottomSheet(
          context: navigatorKey.currentContext!,
          isScrollControlled: true,
          enableDrag: true,
          builder: (context) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SendBroadcastMessageSheet(
                event: event,
                guests: guests,
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 1,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Image.asset(Assets.icons.broadcastIcon, height: 24),
      ),
    );
  }
}
