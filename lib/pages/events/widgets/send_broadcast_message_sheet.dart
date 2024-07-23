import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/event_invite_members.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/models/events/posts/broadcast_post_model.dart';
import 'package:zipbuzz/pages/events/widgets/event_host_guest_list.dart';
import 'package:zipbuzz/services/chat_services.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/custom_text_field.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';

class SendBroadcastMessageSheet extends ConsumerStatefulWidget {
  final EventModel event;
  final List<EventInviteMember> guests;
  const SendBroadcastMessageSheet({
    super.key,
    required this.event,
    required this.guests,
  });

  @override
  ConsumerState<SendBroadcastMessageSheet> createState() => _SendBroadcastMessageSheetState();
}

class _SendBroadcastMessageSheetState extends ConsumerState<SendBroadcastMessageSheet> {
  late TextEditingController commentController;
  late FocusNode focusNode;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    commentController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: commentController,
            focusNode: focusNode,
            hintText: "Broadcast message to all invitees",
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () {
              postBroadcastMessage();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(360),
              ),
              child: Center(
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Post Message",
                        style: AppStyles.h3.copyWith(
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (focusNode.hasFocus)
            SizedBox(
              height: MediaQuery.of(context).viewInsets.bottom,
            ),
        ],
      ),
    );
  }

  void postBroadcastMessage() async {
    if (loading) return;
    setState(() {
      loading = true;
    });
    try {
      final rsvpMembers = ref.read(eventRequestMembersProvider);
      final allGuests = rsvpMembers
          .map((e) => EventInviteMember(
                name: e.name,
                phone: e.phone,
                image: e.image,
                status: e.status,
              ))
          .where((e) => e.status != 'declined')
          .toList();

      for (var e in widget.guests) {
        final contains = allGuests.any((element) => element.phone.contains(e.phone));
        if (!contains && e.status != 'declined') {
          allGuests.add(e);
        }
      }
      final message = commentController.text.trim();
      if (message.isEmpty) return;
      final user = ref.read(userProvider);
      final rsvpNumbers =
          allGuests.map((e) => e.phone).where((e) => e != user.mobileNumber).toList();
      final model = BroadcastPostModel(
        broadcastMessage: message,
        phoneNumbers: rsvpNumbers,
        eventName: widget.event.title,
        eventId: widget.event.id,
        hostId: widget.event.hostId,
      );
      if (rsvpNumbers.isNotEmpty) {
        await ref.read(dioServicesProvider).sendBroadcastMessage(model);
      }
      await ref.read(chatServicesProvider).sendMessage(
            event: widget.event,
            message: message,
          );
      showSnackBar(message: "Broadcast message sent successfully");
      loading = false;
      navigatorKey.currentState!.pop();
    } catch (e) {
      loading = false;
      navigatorKey.currentState!.pop();
      showSnackBar(message: "Failed to send broadcast message");
    }
  }
}
