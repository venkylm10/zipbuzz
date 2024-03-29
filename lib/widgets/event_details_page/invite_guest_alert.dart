import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class InviteGuestAlert extends ConsumerStatefulWidget {
  const InviteGuestAlert({super.key});

  @override
  ConsumerState<InviteGuestAlert> createState() => _InviteGuestAlertState();
}

class _InviteGuestAlertState extends ConsumerState<InviteGuestAlert> {
  void publishEvent() async {
    await ref.read(newEventProvider.notifier).publishEvent();
    navigatorKey.currentState!.pop();
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
                  child: GestureDetector(
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
                  child: GestureDetector(
                    onTap: () {
                      navigatorKey.currentState!.pop();
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
