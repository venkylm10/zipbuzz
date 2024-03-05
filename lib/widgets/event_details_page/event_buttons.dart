import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zipbuzz/controllers/events/edit_event_controller.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/join_request_model.dart';
import 'package:zipbuzz/pages/events/edit_event_page.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/widgets/event_details_page/event_invite.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/widgets/common/loader.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

class EventButtons extends ConsumerStatefulWidget {
  const EventButtons({
    required this.event,
    this.isPreview = false,
    this.rePublish = false,
    super.key,
  });

  final EventModel event;
  final bool isPreview;
  final bool rePublish;

  @override
  ConsumerState<EventButtons> createState() => _EventButtonsState();
}

class _EventButtonsState extends ConsumerState<EventButtons> {
  void publishEvent(WidgetRef ref) async {
    await ref.read(newEventProvider.notifier).publishEvent();
    navigatorKey.currentState!.pop();
  }

  @override
  Widget build(BuildContext context) {
    return !widget.isPreview ? eventDetailsButtons() : eventPreviewButtons();
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
                if (!widget.isPreview)
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
                if (!widget.isPreview) const SizedBox(width: 8),
                // Event Invite button
                Expanded(
                  child: GestureDetector(
                    onTap: inviteContacts,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              Assets.icons.people,
                              height: 22,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Invite Guests",
                              style: AppStyles.h3.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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
                      if (loadingText != null) return;
                      if (ref.read(newEventProvider).eventMembers.isEmpty) {
                        showDialog(
                            context: navigatorKey.currentContext!,
                            barrierDismissible: true,
                            builder: (context) {
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
                                                ref.read(newEventProvider.notifier).publishEvent();
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
                            });
                        return;
                      }

                      ref.read(newEventProvider.notifier).publishEvent();
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
    if (userId == widget.event.hostId) {
      if (widget.rePublish) {
        return eventRePublishButtons();
      }
      return editShareButtons();
    } else if (widget.event.status == "requested") {
      return eventRequestedButton();
    } else if (widget.event.status == "confirmed") {
      return eventJoinedButton();
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

  Future<void> addToFavorite() async {
    if (GetStorage().read(BoxConstants.guestUser) != null) {
      showSnackBar(message: "You need to be signed in", duration: 2);
      await Future.delayed(const Duration(seconds: 2));
      ref.read(newEventProvider.notifier).showSignInForm();
      return;
    }
    widget.event.isFavorite = !widget.event.isFavorite;
    setState(() {});
    if (widget.event.isFavorite) {
      await ref.read(eventsControllerProvider.notifier).addEventToFavorites(widget.event.id);
    } else {
      await ref.read(eventsControllerProvider.notifier).removeEventFromFavorites(widget.event.id);
    }
    await ref.read(eventsControllerProvider.notifier).getAllEvents();
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
              child: Consumer(builder: (context, ref, child) {
                return GestureDetector(
                  onTap: () async {
                    widget.event.status = "requested";
                    setState(() {});
                    final user = ref.read(userProvider);
                    var model = JoinEventRequestModel(
                        eventId: widget.event.id,
                        name: user.name,
                        phoneNumber: user.mobileNumber,
                        image: user.imageUrl);
                    final res = await ref.read(dioServicesProvider).requestToJoinEvent(model);
                    if (res) {
                      showSnackBar(message: "Request sent successfully");
                    }
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
                            "(${widget.event.attendees}/${widget.event.capacity})",
                            style: AppStyles.h4.copyWith(color: AppColors.lightGreyColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(width: 8),
            buildShareButton(),
            const SizedBox(width: 8),
            buildAddToFavoriteButton(),
          ],
        ),
      ),
    );
  }

  Widget eventRequestedButton() {
    return Container(
      width: double.infinity,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Row(
          children: [
            Expanded(
              child: Consumer(builder: (context, ref, child) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Requested ",
                          style: AppStyles.h3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "(${widget.event.attendees}/${widget.event.capacity})",
                          style: AppStyles.h4.copyWith(color: AppColors.lightGreyColor),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(width: 8),
            buildShareButton(),
            const SizedBox(width: 8),
            buildAddToFavoriteButton(),
          ],
        ),
      ),
    );
  }

  Widget eventJoinedButton() {
    return Container(
      width: double.infinity,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Row(
          children: [
            Expanded(
              child: Consumer(builder: (context, ref, child) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Joined ",
                          style: AppStyles.h3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "(${widget.event.attendees}/${widget.event.capacity})",
                          style: AppStyles.h4.copyWith(color: AppColors.lightGreyColor),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(width: 8),
            buildShareButton(),
            const SizedBox(width: 8),
            buildAddToFavoriteButton(),
          ],
        ),
      ),
    );
  }

  GestureDetector buildAddToFavoriteButton() {
    return GestureDetector(
      onTap: () {
        addToFavorite();
      },
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
                colorFilter: ColorFilter.mode(
                  widget.event.isFavorite ? Colors.red.shade500 : AppColors.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Consumer buildShareButton() {
    return Consumer(builder: (context, ref, child) {
      return GestureDetector(
        onTap: () async {
          shareEvent(widget.event);
        },
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
      );
    });
  }

  Widget editShareButtons() {
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
                    ref.read(editEventControllerProvider.notifier).eventId = widget.event.id;
                    ref.read(editEventControllerProvider.notifier).updateEvent(widget.event);
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
                  onTap: () async {
                    shareEvent(widget.event);
                  },
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

  void shareEvent(EventModel event) {
    final eventUrl = event.inviteUrl;
    final article = "aeiou".contains(event.category[0].toLowerCase()) ? "an" : "a";
    Share.share(
        "Follow the link to find more details on the Event\n\n${event.hostName} has invited you for $article ${event.category} event via Buzz.Me:\n${event.title}\nInvitation: ${widget.event.about}\nDate: ${widget.event.date.substring(0, 10)} at ${widget.event.startTime}\nLocation: ${widget.event.location}\n\nMore details at : $eventUrl\n\nDownload Buzz.Me at <link> (later)");
  }
}
