import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:zipbuzz/pages/event_details/event_details_page.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';
import 'package:zipbuzz/widgets/event_details_page/event_host_guest_list.dart';

import '../../services/db_services.dart';
import '../../utils/constants/globals.dart';

class ResponseNotiCard extends ConsumerWidget {
  const ResponseNotiCard({
    super.key,
    required this.senderName,
    required this.senderProfilePic,
    required this.eventId,
    required this.eventName,
    required this.positiveResponse,
    this.confirmResponse = false,
    required this.time,
    this.accepted = false,
  });

  final String senderName;
  final String senderProfilePic;
  final int eventId;
  final String eventName;
  final bool positiveResponse;
  final bool confirmResponse;
  final String time;
  final bool accepted;

  void navigateToEventDetails(WidgetRef ref) async {
    showSnackBar(message: "Getting event details...");
    final event = await ref.read(dbServicesProvider).getEventDetails(eventId);
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
  Widget build(BuildContext context, WidgetRef ref) {
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
                senderProfilePic,
                height: 44,
                width: 44,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: MediaQuery.of(context).size.width - 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    senderName,
                    style: AppStyles.h5.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    softWrap: true,
                  ),
                  accepted
                      ? Text(
                          "$senderName has accepted your request for $eventName",
                          style: AppStyles.h5.copyWith(
                            color: AppColors.greyColor,
                          ),
                        )
                      : confirmResponse
                          ? positiveResponse
                              ? Text(
                                  "You have requested for $eventName",
                                  style: AppStyles.h5.copyWith(
                                    color: AppColors.greyColor,
                                  ),
                                )
                              : Text(
                                  "You have declined for $eventName",
                                  style: AppStyles.h5.copyWith(
                                    color: AppColors.greyColor,
                                  ),
                                )
                          : RichText(
                              softWrap: true,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "$senderName - RSVP'd ",
                                    style: AppStyles.h5.copyWith(
                                      color: AppColors.greyColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${positiveResponse ? "Yes" : "No"} ',
                                    style: AppStyles.h5.copyWith(
                                      color: positiveResponse
                                          ? AppColors.positiveGreen
                                          : AppColors.negativeRed,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' to your invite for $eventName',
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
            const Spacer(),
            Text(
              time,
              style: AppStyles.h6,
            ),
          ],
        ),
      ),
    );
  }
}
