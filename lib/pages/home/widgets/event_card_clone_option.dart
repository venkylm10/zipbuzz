import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/controllers/events/events_tab_controler.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/pages/events/widgets/send_invitation_bell.dart';
import 'package:zipbuzz/pages/groups/create_group_event_screen.dart';
import 'package:zipbuzz/services/contact_services.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/tabs.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';

class EventCardActionItems extends ConsumerWidget {
  final EventModel event;
  const EventCardActionItems({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hostId = event.hostId;
    final userId = ref.read(userProvider).id;
    return Positioned(
      right: 10,
      top: 10,
      child: Row(
        children: [
          if (hostId == userId)
            InkWell(
              onTap: () => cloneEvent(ref),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  Assets.icons.copy,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primaryColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          if (userId == hostId)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: SendNotificationBell(
                event: event,
                padding: const EdgeInsets.all(8),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
        ],
      ),
    );
  }

  void cloneEvent(WidgetRef ref) async {
    await fixCloneEventContacts(ref);
    ref
        .read(homeTabControllerProvider.notifier)
        .updateSelectedTab(event.groupName == 'zipbuzz-null' ? AppTabs.events : AppTabs.groups);
    ref.read(newEventProvider.notifier).cloneEvent = true;
    ref.read(newEventProvider.notifier).updateCategory(event.category);
    final eventMembers = event.eventMembers.where((element) {
      var num = element.phone.replaceAll(RegExp(r'[\s()-]+'), "").replaceAll(" ", "");
      num = num.length > 10 ? num.substring(num.length - 10) : num;
      var userNumber = ref
          .read(userProvider)
          .mobileNumber
          .replaceAll(RegExp(r'[\s()-]+'), "")
          .replaceAll(" ", "");
      userNumber =
          userNumber.length > 10 ? userNumber.substring(userNumber.length - 10) : userNumber;
      return num != userNumber;
    }).toList();
    final clone = ref.read(newEventProvider).copyWith(
          title: event.title,
          about: event.about,
          category: event.category,
          endTime: "",
          location: event.location,
          capacity: event.capacity,
          bannerPath: event.bannerPath,
          iconPath: event.iconPath,
          attendees: eventMembers.length,
          eventMembers: eventMembers,
          imageUrls: event.imageUrls,
          isPrivate: event.isPrivate,
          privateGuestList: event.privateGuestList,
        );

    ref.read(eventTabControllerProvider.notifier).updateIndex(2);
    ref.read(newEventProvider.notifier).updateEvent(clone);
    ref.read(newEventProvider.notifier).cloneHyperLinks(event.hyperlinks);
    ref.read(newEventProvider.notifier).updateCategory(event.category);
    if (event.groupName != 'zipbuzz-null') {
      navigatorKey.currentState!.pushNamed(CreateGroupEventScreen.id);
    }
  }

  Future<void> fixCloneEventContacts(WidgetRef ref) async {
    showSnackBar(message: "Cloning event", duration: 1);
    final numbers = event.eventMembers
        .where((e) {
          var num = e.phone.replaceAll(RegExp(r'[\s()-]+'), "").replaceAll(" ", "");
          num = num.length > 10 ? num.substring(num.length - 10) : num;
          var userNumber = ref
              .read(userProvider)
              .mobileNumber
              .replaceAll(RegExp(r'[\s()-]+'), "")
              .replaceAll(" ", "");
          userNumber =
              userNumber.length > 10 ? userNumber.substring(userNumber.length - 10) : userNumber;
          return num != userNumber;
        })
        .map((e) => e.phone)
        .toList();
    final matchingContacts = ref.read(contactsServicesProvider).getMatchingContacts(numbers);
    await Future.delayed(const Duration(milliseconds: 500));
    ref.read(newEventProvider.notifier).updateSelectedContactsList(matchingContacts);
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
