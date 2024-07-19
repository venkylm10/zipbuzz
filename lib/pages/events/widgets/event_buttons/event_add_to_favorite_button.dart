import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';

class EventAddToFavoriteButton extends ConsumerStatefulWidget {
  final EventModel event;
  const EventAddToFavoriteButton({super.key, required this.event});

  @override
  ConsumerState<EventAddToFavoriteButton> createState() => _EventAddToFavoriteButtonState();
}

class _EventAddToFavoriteButtonState extends ConsumerState<EventAddToFavoriteButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        addToFavorite(ref);
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

  Future<void> addToFavorite(WidgetRef ref) async {
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
    await ref.read(eventsControllerProvider.notifier).fetchEvents();
  }
}
