import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/navigation_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/pages/chat/chat_page.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

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
  void navigateToChatPage() {
    if (widget.isPreview) return;
    NavigationController.routeTo(
        route: ChatPage.id, arguments: {"event": widget.event});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      //TODO: Update host and co-hosts
      children: [
        buildHost(widget.event.hostId, widget.event.hostName, widget.event.hostPic),
        // Column(
        //   children: List.generate(
        //     widget.event.coHosts.length,
        //     (index) {
        //       final coHost = widget.coHosts[index];
        //       return buildHost(coHost.id, coHost.name, coHost.imageUrl);
        //     },
        //   ),
        // )
      ],
    );
  }

  Padding buildHost(int hostId, String hostName, String hostPic) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
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
          const Expanded(child: SizedBox()),
          GestureDetector(
            onTap: () => navigateToChatPage(),
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  "Message",
                  style: AppStyles.h4.copyWith(color: AppColors.primaryColor),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
