import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/models/notification_data.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/widgets/common/custom_text_field.dart';

class AttendeeNumberResponse extends ConsumerStatefulWidget {
  const AttendeeNumberResponse({
    super.key,
    required this.notification,
    this.inviteReply = true,
    required this.onSubmit,
    this.event,
    this.addComment = true,
  });
  final NotificationData notification;
  final bool inviteReply;
  final Function(int attendees, TextEditingController commentController) onSubmit;
  final EventModel? event;
  final bool addComment;

  @override
  ConsumerState<AttendeeNumberResponse> createState() => _AttendeeNumberResponseState();
}

class _AttendeeNumberResponseState extends ConsumerState<AttendeeNumberResponse> {
  int attendees = 1;
  final commentController = TextEditingController();
  final focusNode = FocusNode();

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
            if (widget.addComment)
              CustomTextField(
                controller: commentController,
                focusNode: focusNode,
                hintText: "Comment (optional)",
              ),
            if (widget.addComment) const SizedBox(height: 16),
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
              onTap: () => widget.onSubmit(attendees, commentController),
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
            if (focusNode.hasFocus)
              SizedBox(
                height: MediaQuery.of(context).viewInsets.bottom,
              ),
          ],
        ),
      ),
    );
  }
}
