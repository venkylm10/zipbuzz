import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/controllers/events/edit_event_controller.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/pages/events/edit_event_page.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/widgets/event_details_page/event_invite.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/widgets/common/loader.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

class EventButtons extends StatelessWidget {
  const EventButtons({
    required this.event,
    this.isPreview = false,
    this.rePublish = false,
    super.key,
  });

  final EventModel event;
  final bool? isPreview;
  final bool? rePublish;

  void publishEvent(WidgetRef ref) async {
    await ref.read(newEventProvider.notifier).publishEvent();
    navigatorKey.currentState!.pop();
  }

  @override
  Widget build(BuildContext context) {
    return !isPreview! ? eventDetailsButtons() : eventPreviewButtons();
  }

  Widget eventPreviewButtons() {
    return Container(
      width: double.infinity,
      height: 104,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Column(
          children: [
            Row(
              children: [
                // Event Link button
                Expanded(
                  child: GestureDetector(
                    onTap: showSnackBar,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.bgGrey,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.borderGrey),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(Assets.icons.link, height: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Event link",
                              style: AppStyles.h5.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Event Invite button
                Expanded(
                  child: GestureDetector(
                    onTap: inviteContacts,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.bgGrey,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.borderGrey),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(Assets.icons.people, height: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Invite people",
                              style: AppStyles.h5.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Publish button
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final loadingText = ref.watch(loadingTextProvider);
                  return GestureDetector(
                    onTap: () {
                      if (loadingText == null) {
                        ref.read(newEventProvider.notifier).publishEvent();
                      }
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget eventDetailsButtons() {
    final userId = GetStorage().read(BoxConstants.id);
    if (userId == event.hostId) {
      if (rePublish!) {
        return eventRePublishButtons();
      }
      return editShareButtonss();
    }
    return eventJoinButton();
  }

  Widget eventRePublishButtons() {
    return Consumer(
      builder: (context, ref, child) {
        final loadingText = ref.watch(loadingTextProvider);
        return GestureDetector(
          onTap: () {
            if (loadingText == null) {
              ref.read(editEventControllerProvider.notifier).rePublishEvent();
            }
          },
          child: Container(
            height: 48,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: loadingText == null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(Assets.icons.arrow_repeat, height: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Re-Publish",
                          style: AppStyles.h3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
      },
    );
  }

  Widget eventJoinButton() {
    return Container(
      width: double.infinity,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: showSnackBar,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(Assets.icons.add_fill, height: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Join ",
                          style: AppStyles.h3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "(${event.attendees}/${event.capacity})",
                          style: AppStyles.h4.copyWith(color: AppColors.lightGreyColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: showSnackBar,
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 10,
                      sigmaY: 10,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        Assets.icons.send_fill,
                        height: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: showSnackBar,
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 10,
                      sigmaY: 10,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        Assets.icons.heart_fill,
                        height: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget editShareButtonss() {
    return Consumer(builder: (context, ref, child) {
      return Container(
        width: double.infinity,
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    ref.read(editEventControllerProvider.notifier).eventId = event.id;
                    ref.read(editEventControllerProvider.notifier).updateEvent(event);
                    await navigatorKey.currentState!.pushNamed(EditEventPage.id);
                    ref.read(editEventControllerProvider.notifier).updateBannerImage(null);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            Assets.icons.edit,
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Edit",
                            style: AppStyles.h3.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: showSnackBar,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgGrey,
                      border: Border.all(color: AppColors.borderGrey),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            Assets.icons.send_fill,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              Colors.grey.shade800,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Share",
                            style: AppStyles.h3.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  void inviteContacts() async {
    await showModalBottomSheet(
      context: navigatorKey.currentContext!,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: const EventInvite(),
        );
      },
    );
  }
}
