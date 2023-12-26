import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/controllers/navigation_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/pages/chat/chat_page.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

class EventHosts extends ConsumerStatefulWidget {
  const EventHosts({
    super.key,
    required this.event,
    required this.isPreview,
  });
  final EventModel event;
  final bool isPreview;

  @override
  ConsumerState<EventHosts> createState() => _EventHostsState();
}

class _EventHostsState extends ConsumerState<EventHosts> {
  void navigateToChatPage() async {
    if (widget.isPreview) {
      showSnackBar(message: "Only for published events", duration: 2);
      return;
    }
    if (GetStorage().read(BoxConstants.guestUser) != null) {
      showSnackBar(message: "You need to be signed in send messages to anyone", duration: 2);
      await Future.delayed(const Duration(seconds: 2));
      ref.read(newEventProvider.notifier).showSignInForm();
      return;
    }
    NavigationController.routeTo(
      route: ChatPage.id,
      arguments: {"event": widget.event},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildHost(widget.event.hostId, widget.event.hostName, widget.event.hostPic),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => navigateToChatPage(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: AppColors.primaryColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                SvgPicture.asset(Assets.icons.group_chat, height: 16),
                const SizedBox(width: 8),
                Text(
                  "Group Chat",
                  style: AppStyles.h5.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Padding buildHost(int hostId, String hostName, String hostPic) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: AppColors.greyColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: AppColors.greyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Image.network(
                  hostPic,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            hostName,
            style: AppStyles.h5,
          ),
        ],
      ),
    );
  }
}
