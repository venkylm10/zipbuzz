import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zipbuzz/controllers/events/edit_event_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/pages/events/edit_event_page.dart';
import 'package:zipbuzz/pages/events/widgets/event_buttons/event_edit_share_button.dart';
import 'package:zipbuzz/services/contact_services.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/loader.dart';

class EventEditButton extends ConsumerWidget {
  final EventModel event;
  const EventEditButton({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                editEvent(ref);
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
            child: EventEditShareButton(event: event),
          )
        ],
      ),
    );
  }

  void editEvent(WidgetRef ref) async {
    ref.read(editEventControllerProvider.notifier).eventId = event.id;
    ref.read(editEventControllerProvider.notifier).updateEvent(event);
    ref.read(editEventControllerProvider.notifier).resetInvites();
    ref.read(editEventControllerProvider.notifier).initialiseHyperLinks();
    await fixEditContacts(ref);
    await navigatorKey.currentState!.pushNamed(EditEventPage.id);
    ref.read(editEventControllerProvider.notifier).updateBannerImage(null);
  }

  Future<void> fixEditContacts(WidgetRef ref) async {
    ref.read(loadingTextProvider.notifier).updateLoadingText("Just a sec..");
    final numbers = event.eventMembers.map((e) => e.phone).toList();
    ref.read(editEventControllerProvider.notifier).updateOldInvites(numbers);
    final matchingContacts = ref.read(contactsServicesProvider).getMatchingContacts(numbers);
    await Future.delayed(const Duration(milliseconds: 500));
    ref.read(editEventControllerProvider.notifier).updateSelectedContactsList(matchingContacts);
    await Future.delayed(const Duration(milliseconds: 500));
    ref.read(loadingTextProvider.notifier).reset();
  }
}
