import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:zipbuzz/controllers/events/edit_event_controller.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/controllers/navigation_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/pages/events/widgets/create_event_urls.dart';
import 'package:zipbuzz/pages/events/widgets/create_event_ticket_type_fields.dart';
import 'package:zipbuzz/services/contact_services.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/pages/events/event_details_page.dart';
import 'package:zipbuzz/pages/events/create_event_form.dart';
import 'package:zipbuzz/utils/widgets/broad_divider.dart';
import 'package:zipbuzz/pages/events/widgets/add_hosts.dart';
import 'package:zipbuzz/pages/events/widgets/event_type_and_capacity.dart';
import 'package:zipbuzz/pages/events/widgets/add_event_photos.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';

class CreateEventTab extends ConsumerStatefulWidget {
  const CreateEventTab({
    super.key,
    this.rePublish = false,
    this.groupEvent = false,
  });
  final bool rePublish;
  final bool groupEvent;

  @override
  ConsumerState<CreateEventTab> createState() => _CreateEventState();
}

class _CreateEventState extends ConsumerState<CreateEventTab> {
  String category = allInterests.first.activity;
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  int randInt = 0;

  @override
  void initState() {
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  var newIsPrivate = false;

  @override
  Widget build(BuildContext context) {
    newIsPrivate = widget.rePublish
        ? ref.watch(editEventControllerProvider).isPrivate
        : ref.watch(newEventProvider).isPrivate;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CreateEventForm(),
          broadDivider(),
          const AddHosts(),
          const SizedBox(height: 16),
          const EventTypeAndCapacity(),
          broadDivider(),
          const AddEventPhotos(),
          broadDivider(),
          CreateEventUrls(rebuild: () {
            setState(() {});
          }),
          CreateEventTicketTypeFields(rePublish: widget.rePublish),
          _showAndInviteGuestsButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  InkWell _showAndInviteGuestsButton() {
    return InkWell(
      onTap: () => _showPreview(),
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(Assets.icons.save_event),
            const SizedBox(width: 8),
            Text(
              widget.groupEvent ? "Invite Group" : "Invite Guests",
              style: AppStyles.h3.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Color> _getDominantColor() async {
    try {
      final previewBanner = ref.read(newEventProvider.notifier).bannerImage;
      Color dominantColor = Colors.green;
      if (previewBanner != null) {
        final image = FileImage(previewBanner);
        final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
          image,
        );
        dominantColor = generator.dominantColor!.color;
      } else {
        final image = NetworkImage(interestBanners[ref.read(newEventProvider).category]!);
        final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
          image,
        );
        dominantColor = generator.dominantColor!.color;
      }
      return dominantColor;
    } catch (e) {
      return Colors.green;
    }
  }

  void _showPreview() async {
    if (ref.read(newEventProvider.notifier).validateNewEvent()) {
      final dominantColor = await _getDominantColor();
      ref.read(newEventProvider.notifier).updateHyperlinks();
      final paypalLink = ref.read(newEventProvider.notifier).paypalLinkController.text.trim();
      final venmoLink = ref.read(newEventProvider.notifier).venmoIdController.text.trim();
      var event = ref.read(newEventProvider);
      event = event.copyWith(
        paypalLink: paypalLink.isNotEmpty ? paypalLink : 'zipbuzz-null',
      );
      event = event.copyWith(
        venmoLink: venmoLink.isNotEmpty ? venmoLink : 'zipbuzz-null',
      );
      ref.read(newEventProvider.notifier).updateEvent(event);
      final clone = ref.read(newEventProvider.notifier).cloneEvent;
      if (widget.groupEvent) {
        try {
          ref.read(groupControllerProvider.notifier).updateLoading(true);
          await ref.read(groupControllerProvider.notifier).getGroupMembers();
          final members = [
            ...ref.read(groupControllerProvider).admins,
            ...ref.read(groupControllerProvider).members,
          ];
          final phones = members.map((e) => e.phone).toList();
          final matchingContacts = ref.read(contactsServicesProvider).getMatchingContacts(phones);
          final nonContactMembers = members.where((e) {
            if (e.phone == 'zipbuzz-null') return false;
            if (e.phone == ref.read(userProvider).mobileNumber) {
              return false;
            }
            final val = !matchingContacts.any(
              (ele) => ele.phones.contains(e.phone),
            );
            return val;
          }).map((e) => ContactModel(
                displayName: e.name,
                phones: [e.phone],
                imageUrl: e.profilePicture,
              ));
          matchingContacts.addAll(nonContactMembers);
          ref.read(newEventProvider.notifier).updateInvites(matchingContacts);
        } catch (e) {
          showSnackBar(message: "Something went wrong. Please try again later.");
          debugPrint(e.toString());
        }
        ref.read(groupControllerProvider.notifier).updateLoading(false);
      }
      navigatorKey.currentState!.push(
        NavigationController.getTransition(
          EventDetailsPage(
            event: ref.read(newEventProvider),
            isPreview: true,
            dominantColor: dominantColor,
            clone: clone,
            groupEvent: widget.groupEvent,
            rePublish: false,
            showBottomBar: false,
          ),
        ),
      );
    }
  }
}
