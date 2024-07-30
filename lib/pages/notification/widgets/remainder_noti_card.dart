import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:zipbuzz/models/notification_data.dart';
import 'package:zipbuzz/pages/events/event_details_page.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';
import 'package:zipbuzz/pages/events/widgets/event_host_guest_list.dart';

class RemainderNotiCard extends ConsumerWidget {
  const RemainderNotiCard({
    super.key,
    required this.notification,
    required this.time,
    required this.rebuildCall,
  });

  final NotificationData notification;
  final String time;
  final VoidCallback rebuildCall;

  void navigateToEventDetails(WidgetRef ref) async {
    showSnackBar(message: "Getting event details...");
    final event = await ref.read(dbServicesProvider).getEventDetails(notification.eventId);
    final dominantColor = await getDominantColor(event.bannerPath);
    ref.read(guestListTagProvider.notifier).update((state) => "Invited");
    await navigatorKey.currentState!.pushNamed(EventDetailsPage.id, arguments: {
      "event": event,
      "dominantColor": dominantColor,
      "isPreview": false,
      "rePublish": false,
      "randInt": 0,
    });
    rebuildCall();
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
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              notification.senderProfilePicture,
              height: 44,
              width: 44,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () => navigateToEventDetails(ref),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.senderName,
                    style: AppStyles.h5.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    softWrap: true,
                  ),
                  Text(
                    '${notification.senderName} has remainded you for the event - ${notification.eventName}',
                    style: AppStyles.h5,
                  ),
                ],
              ),
            ),
          ),
          Text(
            time,
            style: AppStyles.h6,
          ),
        ],
      ),
    );
  }
}
