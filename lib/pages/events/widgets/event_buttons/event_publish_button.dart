import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/pages/events/widgets/invite_guest_alert.dart';
import 'package:zipbuzz/pages/events/widgets/published_event_alert.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/loader.dart';

class EventPublishButton extends ConsumerWidget {
  const EventPublishButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadingText = ref.watch(loadingTextProvider);
    return InkWell(
      onTap: () async {
        if (loadingText != null) return;
        if (ref.read(newEventProvider).eventMembers.isEmpty && !kIsWeb) {
          showDialog(
            context: navigatorKey.currentContext!,
            barrierDismissible: true,
            builder: (context) {
              return const InviteGuestAlert();
            },
          );
          return;
        }
        await ref.read(newEventProvider.notifier).publishEvent();
        publishedAlertBox(ref);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: loadingText == null
              ? Text(
                  "Publish",
                  style: AppStyles.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : Text(
                  loadingText,
                  style: AppStyles.h4.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Future<dynamic> publishedAlertBox(WidgetRef ref) {
    return showDialog(
        context: navigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (context) {
          return const PublishedEventAlertBox();
        });
  }
}
