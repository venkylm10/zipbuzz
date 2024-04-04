import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/posts/make_request_model.dart';
import 'package:zipbuzz/models/notification_data.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/services/notification_services.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class AttendeeNumberResponse extends ConsumerStatefulWidget {
  const AttendeeNumberResponse({super.key, required this.notification});
  final NotificationData notification;

  @override
  ConsumerState<AttendeeNumberResponse> createState() => _AttendeeNumberResponseState();
}

class _AttendeeNumberResponseState extends ConsumerState<AttendeeNumberResponse> {
  int attendees = 1;

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
                await ref
                    .read(dioServicesProvider)
                    .updateNotification(widget.notification.id, "yes");
                final user = ref.read(userProvider);
                var model = MakeRequestModel(
                  userId: user.id,
                  eventId: widget.notification.eventId,
                  name: user.name,
                  phoneNumber: user.mobileNumber,
                  members: attendees,
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
                navigatorKey.currentState!.pop();
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
