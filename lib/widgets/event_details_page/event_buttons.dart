import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/pages/event_details/event_invite.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

class EventButtons extends ConsumerWidget {
  const EventButtons({
    required this.event,
    this.isPreview = false,
    super.key,
  });

  final EventModel event;
  final bool? isPreview;

  void publishEvent(WidgetRef ref) async {
    await ref.read(newEventProvider.notifier).publishEvent();
    navigatorKey.currentState!.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return !isPreview!
        ? Container(
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
          )
        : Container(
            width: double.infinity,
            height: 104,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Column(
                children: [
                  Row(
                    children: [
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
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ref.read(newEventProvider.notifier).publishEvent();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Text(
                            "Publish",
                            style: AppStyles.h3.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
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
