import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/edit_event_controller.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';

class CreateEventGuestListType extends ConsumerWidget {
  final bool rePublish;
  const CreateEventGuestListType({super.key, this.rePublish = false});

  void togglePrivacy(WidgetRef ref) {
    rePublish
        ? ref.read(editEventControllerProvider.notifier).toggleGuestListPrivacy()
        : ref.read(newEventProvider.notifier).toggleGuestListPrivacy();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivate = rePublish
        ? ref.watch(editEventControllerProvider).privateGuestList
        : ref.watch(newEventProvider).privateGuestList;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Guest list",
          style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => togglePrivacy(ref),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.bgGrey,
              border: Border.all(
                color: isPrivate ? AppColors.borderGrey : AppColors.primaryColor,
              ),
            ),
            child: Row(
              children: [
                Radio(
                  value: true,
                  groupValue: !isPrivate,
                  toggleable: true,
                  activeColor: AppColors.primaryColor,
                  onChanged: (value) {
                    togglePrivacy(ref);
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Make guest list public", style: AppStyles.h4),
                    Text(
                      "Anyone can view the guest list",
                      style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Default:",
                style: AppStyles.h4.copyWith(
                  color: AppColors.primaryColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
              TextSpan(
                text: " Private (only you can see it)",
                style: AppStyles.h4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
