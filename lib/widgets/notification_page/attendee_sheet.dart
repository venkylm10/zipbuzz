import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/posts/make_request_model.dart';
import 'package:zipbuzz/models/notification_data.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/services/notification_services.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/widgets/common/custom_text_field.dart';

class AttendeeNumberResponse extends ConsumerStatefulWidget {
  const AttendeeNumberResponse({super.key, required this.notification});
  final NotificationData notification;

  @override
  ConsumerState<AttendeeNumberResponse> createState() => _AttendeeNumberResponseState();
}

class _AttendeeNumberResponseState extends ConsumerState<AttendeeNumberResponse> {
  var alert = false;
  final numController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Number of attendees (including yourself)",
              style: AppStyles.h5,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: numController,
              hintText: "1",
              keyboardType: TextInputType.number,
            ),
            if (alert) const SizedBox(height: 8),
            if (alert)
              Text(
                "*Atleast 1 attendee is required to submit the response",
                style: AppStyles.h6.copyWith(
                  color: AppColors.negativeRed,
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () async {
                final num = int.parse(numController.text);
                if (num <= 1) {
                  setState(() {
                    alert = true;
                  });
                  return;
                }
                await ref
                    .read(dioServicesProvider)
                    .updateNotification(widget.notification.id, "yes");
                setState(() {});
                final user = ref.read(userProvider);
                var model = MakeRequestModel(
                  eventId: widget.notification.eventId,
                  name: user.name,
                  phoneNumber: user.mobileNumber,
                  members: 1,
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
          ],
        ),
      ),
    );
  }
}
