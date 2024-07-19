import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:zipbuzz/controllers/events/edit_event_controller.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/pages/events/event_details_page.dart';
import 'package:zipbuzz/services/contact_services.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class EventInviteMoreGuestsButton extends ConsumerWidget {
  final EventModel event;
  final VoidCallback inviteContacts;
  const EventInviteMoreGuestsButton({super.key, required this.event, required this.inviteContacts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        inviteMoreGuests(ref);
      },
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
                "Invite More Guests",
                style: AppStyles.h3.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fixInviteMoreContacts(WidgetRef ref) async {
    final numbers = event.eventMembers.map((e) => e.phone).toList();
    final matchingContacts = ref.read(contactsServicesProvider).getMatchingContacts(numbers);
    await Future.delayed(const Duration(milliseconds: 500));
    ref.read(editEventControllerProvider.notifier).updateSelectedContactsList(matchingContacts);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void inviteMoreGuests(WidgetRef ref) async {
    ref.read(eventsControllerProvider.notifier).updateLoadingState(true);
    ref.read(editEventControllerProvider.notifier).eventId = event.id;
    ref.read(editEventControllerProvider.notifier).updateEvent(event);
    ref.read(editEventControllerProvider.notifier).resetInvites();
    ref.read(editEventControllerProvider.notifier).initialiseHyperLinks();
    ref.read(editEventControllerProvider.notifier).updateOldInvites(event.eventMembers.map(
          (e) {
            var phone = e.phone.replaceAll(RegExp(r'[\s()-]+'), "").replaceAll(" ", "");
            if (phone.length > 10) {
              phone = phone.substring(phone.length - 10);
            }
            return phone;
          },
        ).toList());
    await fixInviteMoreContacts(ref);
    await showPreview(ref);
    ref.read(eventsControllerProvider.notifier).updateLoadingState(false);
    ref.read(editEventControllerProvider.notifier).updateBannerImage(null);
  }

  Future<void> showPreview(WidgetRef ref) async {
    final dominantColor = await getDominantColor(ref);
    final event = ref.read(editEventControllerProvider);
    navigatorKey.currentState!.pushNamed(
      EventDetailsPage.id,
      arguments: {
        'event': ref.read(editEventControllerProvider),
        'rePublish': true,
        'dominantColor': dominantColor,
        'randInt': 0,
      },
    );
    await Future.delayed(const Duration(milliseconds: 500));
    inviteContacts();
    ref.read(eventsControllerProvider.notifier).updateLoadingState(false);
    ref.read(editEventControllerProvider.notifier).updateEvent(event);
  }

  Future<Color> getDominantColor(WidgetRef ref) async {
    Color dominantColor = Colors.green;
    final image = NetworkImage(ref.read(editEventControllerProvider).bannerPath);
    final generator = await PaletteGenerator.fromImageProvider(image);
    dominantColor = generator.dominantColor!.color;
    return dominantColor;
  }
}
