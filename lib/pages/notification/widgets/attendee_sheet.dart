import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/models/notification_data.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/custom_text_field.dart';

class AttendeeNumberResponse extends ConsumerStatefulWidget {
  const AttendeeNumberResponse({
    super.key,
    required this.notification,
    this.inviteReply = true,
    required this.onSubmit,
    this.comment = "Sure, I'll be there!",
    required this.event,
  });
  final NotificationData notification;
  final bool inviteReply;
  final Function(BuildContext context, int attendees, TextEditingController commentController)
      onSubmit;
  final EventModel event;
  final String comment;

  @override
  ConsumerState<AttendeeNumberResponse> createState() => _AttendeeNumberResponseState();
}

class _AttendeeNumberResponseState extends ConsumerState<AttendeeNumberResponse> {
  int attendees = 1;
  final commentController = TextEditingController();
  final focusNode = FocusNode();
  final List<int> countController = [];

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
  void initState() {
    for (int i = 0; i < widget.event.ticketTypes.length; i++) {
      countController.add(0);
    }
    super.initState();
    commentController.text = widget.comment;
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
            CustomTextField(
              controller: commentController,
              focusNode: focusNode,
              hintText: "Comment (optional)",
            ),
            const SizedBox(height: 16),
            if (widget.event.ticketTypes.isEmpty) _nonTicktedAttendeeNumber(),
            if (widget.event.ticketTypes.isNotEmpty) _ticketedAttendeeNumber(),
            const SizedBox(height: 24),
            InkWell(
              onTap: () => widget.onSubmit(context, attendees, commentController),
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

  Widget _ticketedAttendeeNumber() {
    return Column(
      children: List.generate(widget.event.ticketTypes.length, (index) {
        final name = widget.event.ticketTypes[index].title;
        final price = widget.event.ticketTypes[index].price;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "$name :",
                  style: AppStyles.h4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "\$$price",
                style: AppStyles.h4.copyWith(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 32),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => _decreamentTicketCount(index),
                  icon: const Icon(
                    Icons.remove,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Text("${countController[index]}", style: AppStyles.h2),
              const SizedBox(width: 20),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => _increamentTicketCount(index),
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Row _nonTicktedAttendeeNumber() {
    return Row(
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
        Text("$attendees", style: AppStyles.h2),
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
    );
  }

  void _increamentTicketCount(int index) {
    setState(() {
      countController[index]++;
    });
  }

  void _decreamentTicketCount(int index) {
    if (countController[index] == 0) return;
    setState(() {
      countController[index]--;
    });
  }
}
