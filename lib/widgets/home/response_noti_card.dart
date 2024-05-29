import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/pages/event_details/event_details_page.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';
import 'package:zipbuzz/widgets/event_details_page/event_host_guest_list.dart';

import '../../services/db_services.dart';
import '../../services/dio_services.dart';
import '../../services/notification_services.dart';
import '../../utils/constants/globals.dart';

class ResponseNotiCard extends ConsumerStatefulWidget {
  const ResponseNotiCard({
    super.key,
    required this.senderId,
    required this.senderName,
    required this.senderProfilePic,
    required this.eventId,
    required this.eventName,
    required this.positiveResponse,
    this.confirmResponse = false,
    required this.time,
    this.accepted = false,
    required this.notificationId,
    required this.senderDeviceToken,
    required this.notificationType,
  });

  final int senderId;
  final String senderName;
  final String senderProfilePic;
  final int notificationId;
  final int eventId;
  final String eventName;
  final bool positiveResponse;
  final bool confirmResponse;
  final String time;
  final bool accepted;
  final String senderDeviceToken;
  final String notificationType;

  @override
  ConsumerState<ResponseNotiCard> createState() => _ResponseNotiCardState();
}

class _ResponseNotiCardState extends ConsumerState<ResponseNotiCard> {
  var status = "";
  var notificationType = "";
  @override
  void initState() {
    status = !widget.confirmResponse && widget.positiveResponse ? "Confirm" : "Confirmed";
    notificationType = widget.notificationType;
    print("notificationType: $notificationType");
    setState(() {});
    super.initState();
  }

  void navigateToEventDetails(WidgetRef ref) async {
    showSnackBar(message: "Getting event details...");
    final event = await ref.read(dbServicesProvider).getEventDetails(widget.eventId);
    final dominantColor = await getDominantColor(event.bannerPath);
    ref.read(guestListTagProvider.notifier).update((state) => "Invited");
    await navigatorKey.currentState!.pushNamed(EventDetailsPage.id, arguments: {
      "event": event,
      "dominantColor": dominantColor,
      "isPreview": false,
      "rePublish": false,
      "randInt": 0,
    });
  }

  Future<Color> getDominantColor(String bannerPath) async {
    Color dominantColor = Colors.green;
    final image = NetworkImage(bannerPath);
    final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
      image,
    );
    dominantColor = generator.dominantColor!.color;
    return dominantColor;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          navigateToEventDetails(ref);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                widget.senderProfilePic,
                height: 44,
                width: 44,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.senderName,
                    style: AppStyles.h5.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    softWrap: true,
                  ),
                  widget.accepted
                      ? Text(
                          "${widget.senderName} has accepted your request for ${widget.eventName}",
                          style: AppStyles.h5.copyWith(
                            color: AppColors.greyColor,
                          ),
                        )
                      : widget.confirmResponse
                          ? widget.positiveResponse
                              ? Text(
                                  "You have requested for ${widget.eventName}",
                                  style: AppStyles.h5.copyWith(
                                    color: AppColors.greyColor,
                                  ),
                                )
                              : Text(
                                  "You have declined for ${widget.eventName}",
                                  style: AppStyles.h5.copyWith(
                                    color: AppColors.greyColor,
                                  ),
                                )
                          : notificationType == "confirmed"
                              ? Text(
                                  "Confirmed ${widget.senderName} for ${widget.eventName}",
                                  style: AppStyles.h5.copyWith(
                                    color: AppColors.greyColor,
                                  ),
                                )
                              : RichText(
                                  softWrap: true,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "${widget.senderName} - RSVP'd ",
                                        style: AppStyles.h5.copyWith(
                                          color: AppColors.greyColor,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '${widget.positiveResponse ? "Yes" : "No"} ',
                                        style: AppStyles.h5.copyWith(
                                          color: widget.positiveResponse
                                              ? AppColors.positiveGreen
                                              : AppColors.negativeRed,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' to your invite for ${widget.eventName}',
                                        style: AppStyles.h5.copyWith(
                                          color: AppColors.greyColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                ],
              ),
            ),
            if (!widget.confirmResponse && widget.positiveResponse)
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () async {
                    if (status == "Confirmed") return;
                    setState(() {
                      status = "Confirmed";
                    });
                    final user = ref.read(userProvider);
                    try {
                      await ref
                        .read(dioServicesProvider)
                        .editUserStatus(widget.eventId, widget.senderId, "confirm");
                    } catch (e) {
                      debugPrint(e.toString());
                    }
                    try {
                      await ref
                        .read(dioServicesProvider)
                        .updateRespondedNotification(widget.senderId, user.id, widget.eventId);
                    } catch (e) {
                      debugPrint(e.toString());
                    }
                    try {
                      await ref
                        .read(dioServicesProvider)
                        .updateUserNotification(widget.notificationId, "confirmed");
                    } catch (e) {
                      debugPrint(e.toString());
                    }
                    
                    showSnackBar(
                        message: "Confirmed ${widget.senderName} for ${widget.eventName}.");
                    NotificationServices.sendMessageNotification(
                      widget.eventName,
                      "${user.name} has confirmed your invitation to ${widget.eventName}.",
                      widget.senderDeviceToken,
                      widget.eventId,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFFEAF6ED),
                    ),
                    child: Text(
                      status,
                      style: AppStyles.h5.copyWith(
                        color: Colors.green.shade500,
                      ),
                    ),
                  ),
                ),
              ),
            Text(
              widget.time,
              style: AppStyles.h6,
            ),
          ],
        ),
      ),
    );
  }
}
