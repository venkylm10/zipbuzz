import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/widgets/event_details_page/published_event_alert.dart';

class InviteGuestAlert extends ConsumerStatefulWidget {
  const InviteGuestAlert({super.key});

  @override
  ConsumerState<InviteGuestAlert> createState() => _InviteGuestAlertState();
}

class _InviteGuestAlertState extends ConsumerState<InviteGuestAlert> {
  void publishEvent() async {
    navigatorKey.currentState!.pop();
    await ref.read(newEventProvider.notifier).publishEvent();
    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (context) {
        return const PublishedEventAlertBox();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      content: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "You haven't invited any Guests. Do you want to continue?",
              style: AppStyles.h4,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      navigatorKey.currentState!.pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(360),
                      ),
                      child: Center(
                        child: Text(
                          "No",
                          style: AppStyles.h3.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      publishEvent();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(360),
                      ),
                      child: Center(
                        child: Text(
                          "Yes",
                          style: AppStyles.h3.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
