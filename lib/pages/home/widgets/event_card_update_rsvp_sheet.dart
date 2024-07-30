import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/services/chat_services.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/custom_text_field.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';

class EventCardRsvpUpdateSheet extends ConsumerStatefulWidget {
  final EventModel event;
  final Function(String, int) updateStatus;
  const EventCardRsvpUpdateSheet({
    super.key,
    required this.event,
    required this.updateStatus,
  });

  @override
  ConsumerState<EventCardRsvpUpdateSheet> createState() => _EventCardRsvpUpdateSheetState();
}

class _EventCardRsvpUpdateSheetState extends ConsumerState<EventCardRsvpUpdateSheet> {
  late int attendees;
  late TextEditingController commentController;
  late FocusNode focusNode;
  bool toAccept = true;
  bool clicked = false;

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
    attendees = widget.event.members;
    // toAccept = widget.event.status == 'declined' ? true : false;
    super.initState();
    focusNode = FocusNode();
    commentController = TextEditingController(
      text: "Sure, I'll be there!",
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text("RSVP : ", style: AppStyles.h4)),
              _buildYesButton(),
              _buildNoButton(),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: commentController,
            focusNode: focusNode,
            hintText: "Comment (optional)",
          ),
          const SizedBox(height: 16),
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
            onTap: changeRsvp,
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
    );
  }

  void changeRsvp() async {
    if (clicked) return;
    clicked = true;
    final user = ref.read(userProvider);
    await ref
        .read(dioServicesProvider)
        .updateRsvp(widget.event.id, user.id, attendees, toAccept ? "pending" : "declined");
    widget.updateStatus(toAccept ? "pending" : "declined", attendees);
    if (commentController.text.isEmpty) return;
    ref.read(chatServicesProvider).sendMessage(
          event: widget.event,
          message: commentController.text.trim(),
        );
    navigatorKey.currentState!.pop();
    showSnackBar(
      message: "RSVP updated '${toAccept ? "Yes" : "No"}' successfully",
    );
    clicked = false;
  }

  GestureDetector _buildNoButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          toAccept = !toAccept;
          if (toAccept) {
            commentController.text = "Sure, I'll be there!";
          } else {
            commentController.text = "Sorry, I can't make it!";
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12).copyWith(left: 16),
        decoration: BoxDecoration(
          color: !toAccept ? AppColors.primaryColor : Colors.white,
          border: Border.all(color: AppColors.primaryColor),
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(20),
          ),
        ),
        child: Text(
          "No",
          style: AppStyles.h5.copyWith(color: toAccept ? AppColors.primaryColor : Colors.white),
        ),
      ),
    );
  }

  GestureDetector _buildYesButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          toAccept = !toAccept;
          if (toAccept) {
            commentController.text = "Sure, I'll be there!";
          } else {
            commentController.text = "Sorry, I can't make it!";
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12).copyWith(left: 16),
        decoration: BoxDecoration(
          color: toAccept ? AppColors.primaryColor : Colors.white,
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(20),
          ),
          border: Border.all(color: AppColors.primaryColor),
        ),
        child: Text(
          "Yes",
          style: AppStyles.h5.copyWith(color: !toAccept ? AppColors.primaryColor : Colors.white),
        ),
      ),
    );
  }
}
