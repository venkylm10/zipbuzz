import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/notification_data.dart';
import 'package:zipbuzz/pages/events/event_details_page.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';
import 'package:zipbuzz/pages/events/widgets/event_host_guest_list.dart';

import '../../../services/db_services.dart';
import '../../../services/dio_services.dart';
import '../../../utils/constants/globals.dart';

class ResponseNotiCard extends ConsumerStatefulWidget {
  const ResponseNotiCard({
    super.key,
    required this.notification,
    required this.time,
    required this.rebuild,
  });

  final NotificationData notification;
  final String time;
  final VoidCallback rebuild;

  @override
  ConsumerState<ResponseNotiCard> createState() => _ResponseNotiCardState();
}

class _ResponseNotiCardState extends ConsumerState<ResponseNotiCard> {
  var status = "";
  var notificationType = "";
  @override
  void initState() {
    notificationType = widget.notification.notificationType;
    status = notificationType == 'yes' ? "Confirm" : "Confirmed";
    setState(() {});
    super.initState();
  }

  void navigateToEventDetails(WidgetRef ref) async {
    showSnackBar(message: "Getting event details...");
    final event = await ref.read(dbServicesProvider).getEventDetails(widget.notification.eventId);
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
      child: InkWell(
        onTap: () {
          navigateToEventDetails(ref);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                widget.notification.senderProfilePicture,
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
                    widget.notification. senderName,
                    style: AppStyles.h5.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    softWrap: true,
                  ),
                  buildNotificationText(),
                ],
              ),
            ),
            buildConfirmButton(),
            Text(
              widget.time,
              style: AppStyles.h6,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNotificationText() {
    switch (notificationType) {
      case 'requested':
        return Text(
          "You have requested for ${widget.notification.eventName}",
          style: AppStyles.h5.copyWith(
            color: AppColors.greyColor,
          ),
        );
      case 'declined':
        return Text(
          "You have declined for ${widget.notification.eventName}",
          style: AppStyles.h5.copyWith(
            color: AppColors.greyColor,
          ),
        );
      case "accepted":
        return Text(
          "You have accepted ${widget.notification.eventName}",
          style: AppStyles.h5.copyWith(
            color: AppColors.greyColor,
          ),
        );
      case "confirmed":
        return Text(
          "${widget.notification.senderName} is confirmed for ${widget.notification.eventName}",
          style: AppStyles.h5.copyWith(
            color: AppColors.greyColor,
          ),
        );
      case "yes" || "no":
        final positive = notificationType == 'yes';
        return RichText(
          softWrap: true,
          text: TextSpan(
            children: [
              TextSpan(
                text: "${widget.notification.senderName} - RSVP'd ",
                style: AppStyles.h5.copyWith(
                  color: AppColors.greyColor,
                ),
              ),
              TextSpan(
                text: '${positive ? "Yes" : "No"} ',
                style: AppStyles.h5.copyWith(
                  color: positive ? AppColors.positiveGreen : AppColors.negativeRed,
                ),
              ),
              TextSpan(
                text: ' to your invite for ${widget.notification.eventName}',
                style: AppStyles.h5.copyWith(
                  color: AppColors.greyColor,
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox();
    }
  }

  Widget buildConfirmButton() {
    final show = widget.notification.notificationType == 'yes';
    if (!show) return const SizedBox();
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () async {
          if (status == "Confirmed") return;
          setState(() {
            status = "Confirmed";
            notificationType = "confirmed";
          });
          final user = ref.read(userProvider);
          try {
            await ref
                .read(dioServicesProvider)
                .editUserStatus(widget.notification.eventId, widget.notification.senderId, "confirm");
          } catch (e) {
            debugPrint(e.toString());
          }
          try {
            await ref
                .read(dioServicesProvider)
                .updateRespondedNotification(widget.notification.senderId, user.id, eventId: widget.notification.eventId);
          } catch (e) {
            debugPrint(e.toString());
          }
          try {
            await ref
                .read(dioServicesProvider)
                .updateUserNotification(widget.notification.id, "confirmed");
          } catch (e) {
            debugPrint(e.toString());
          }
          showSnackBar(message: "Confirmed ${widget.notification.senderName} for ${widget.notification.eventName}.");
          await Future.delayed(const Duration(seconds: 2));
          widget.rebuild();
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
    );
  }
}
