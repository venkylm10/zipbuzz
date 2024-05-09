import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/posts/make_request_model.dart';
import 'package:zipbuzz/models/notification_data.dart';
import 'package:zipbuzz/services/chat_services.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/services/notification_services.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/widgets/common/custom_text_field.dart';

import '../../models/events/join_request_model.dart';

class AttendeeNumberResponse extends ConsumerStatefulWidget {
  const AttendeeNumberResponse(
      {super.key, required this.notification, this.inviteReply = true, this.onSubmit});
  final NotificationData notification;
  final bool inviteReply;
  final VoidCallback? onSubmit;

  @override
  ConsumerState<AttendeeNumberResponse> createState() => _AttendeeNumberResponseState();
}

class _AttendeeNumberResponseState extends ConsumerState<AttendeeNumberResponse> {
  int attendees = 1;
  final commentController = TextEditingController();

  void increment() {
    setState(() {
      attendees++;
    });
  }

  void decrement() {
    if (attendees == 1) return;
    setState(() {
      attendees--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.inviteReply)
              CustomTextField(
                controller: commentController,
                hintText: "Comment (optional)",
              ),
            if (widget.inviteReply) const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  "Number of attendees:",
                  style: AppStyles.h4,
                ),
                const Expanded(child: SizedBox()),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: decrement,
                    icon: const Icon(
                      Icons.remove,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  "$attendees",
                  style: AppStyles.h2,
                ),
                const SizedBox(width: 20),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: increment,
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () async {
                final user = ref.read(userProvider);
                if (widget.inviteReply) {
                  await ref
                      .read(dioServicesProvider)
                      .updateNotification(widget.notification.id, "yes");
                  var model = MakeRequestModel(
                    userId: user.id,
                    eventId: widget.notification.eventId,
                    name: user.name,
                    phoneNumber: user.mobileNumber,
                    members: attendees,
                    userDecision: true,
                  );
                  await ref.read(dioServicesProvider).makeRequest(model);
                  await ref
                      .read(dioServicesProvider)
                      .increaseDecision(widget.notification.eventId, "yes");
                  NotificationServices.sendMessageNotification(
                    widget.notification.eventName,
                    "${user.name} RSVP'd Yes to the event",
                    widget.notification.deviceToken,
                    widget.notification.eventId,
                  );
                } else {
                  // TODO: Attendee Number
                  var model = JoinEventRequestModel(
                      eventId: widget.notification.id,
                      name: user.name,
                      phoneNumber: user.mobileNumber,
                      image: user.imageUrl,
                      userId: user.id);
                  await ref.read(dioServicesProvider).requestToJoinEvent(model);
                }
                navigatorKey.currentState!.pop();
                if (widget.onSubmit != null) widget.onSubmit!();
                if (commentController.text.trim().isNotEmpty) {
                  final event = await ref
                      .read(dbServicesProvider)
                      .getEventDetails(widget.notification.eventId);
                  await ref
                      .read(chatServicesProvider)
                      .sendMessage(event: event, message: commentController.text);
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(360),
                ),
                child: Center(
                  child: Text(
                    "Submit",
                    style: AppStyles.h3.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
