import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/models/events/event_invite_members.dart';
import 'package:zipbuzz/services/contact_services.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/widgets/common/custom_text_field.dart';

final newInvitesProvider = StateProvider<List<EventInviteMember>>((ref) => []);

class EventInvite extends ConsumerStatefulWidget {
  static const id = "/invite";
  const EventInvite({super.key});

  @override
  ConsumerState<EventInvite> createState() => _EventInviteState();
}

class _EventInviteState extends ConsumerState<EventInvite> {
  late TextEditingController searchController;
  bool isMounted = true;
  @override
  void initState() {
    searchController = TextEditingController();
    super.initState();
    resetContacts();
  }

  void resetContacts() async {
    if (isMounted) await ref.read(contactsServicesProvider).updateAllContacts();
    if (isMounted) setState(() {});
  }

  @override
  void dispose() {
    isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedContacts = ref.watch(newEventProvider.notifier).eventInvites;
    final contactSearchResult = ref.watch(newEventProvider.notifier).contactSearchResult;
    return Container(
      height: MediaQuery.of(context).size.height * .75,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 5,
                    width: 36,
                    decoration: BoxDecoration(
                      color: AppColors.lightGreyColor,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "Invite People",
                style: AppStyles.h2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: searchController,
                hintText: "Search by name or number",
                borderRadius: 30,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: SvgPicture.asset(
                    Assets.icons.searchBarIcon,
                    colorFilter: const ColorFilter.mode(AppColors.lightGreyColor, BlendMode.srcIn),
                  ),
                ),
                onChanged: (query) {
                  updateSearchResult(query);
                },
                maxLines: 1,
              ),
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      "Invited (${selectedContacts.length})",
                      style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
                    ),
                    const SizedBox(height: 12),
                    buildInvitedContacts(selectedContacts),
                    const SizedBox(height: 24),
                    Text(
                      "My Address book",
                      style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
                    ),
                    const SizedBox(height: 12),
                    buildSearchResult(contactSearchResult, selectedContacts),
                    const SizedBox(height: 60),
                  ],
                ),
              )
            ],
          ),
          buildInviteButton(),
        ],
      ),
    );
  }

  Align buildInviteButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onTap: () => navigatorKey.currentState!.pop(),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: AppColors.primaryColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(Assets.icons.people_outline, height: 16),
              const SizedBox(width: 8),
              Text(
                "Invite",
                style: AppStyles.h3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                "(${ref.read(newEventProvider).attendees}/${ref.read(newEventProvider).capacity})",
                style: AppStyles.h3.copyWith(
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateSearchResult(String query) {
    if (query.isEmpty) {
      ref.read(newEventProvider.notifier).resetContactSearch();
    } else {
      ref.read(newEventProvider.notifier).updateContactSearchResult(query);
    }
    setState(() {});
  }

  Widget buildInvitedContacts(List<Contact> selectedContacts) {
    final selectSearchContacts = selectedContacts.where(
      (element) {
        return element.displayName.toLowerCase().contains(searchController.text);
      },
    ).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        selectSearchContacts.length,
        (index) {
          return buildContactCard(
            selectSearchContacts[index],
            isSelected: true,
          );
        },
      ),
    );
  }

  Widget buildSearchResult(List<Contact> contactSearchResult, List<Contact> selectedContacts) {
    final nonSelectedSearchedContact = contactSearchResult.where((element) {
      return !selectedContacts.contains(element);
    }).toList();
    return Column(
      children: List.generate(nonSelectedSearchedContact.length, (index) {
        final contact = nonSelectedSearchedContact[index];
        return buildContactCard(contact, isSelected: false);
      }),
    );
  }

  Widget buildContactCard(Contact contact, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        ref.read(newEventProvider.notifier).updateSelectedContact(contact);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 5),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            buildAvatar(contact),
            const SizedBox(width: 12),
            Text(
              contact.displayName,
              style: AppStyles.h4.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Expanded(child: SizedBox()),
            SvgPicture.asset(
              isSelected ? Assets.icons.checkbox_checked : Assets.icons.checkbox_unchecked,
              height: 20,
              width: 20,
            )
          ],
        ),
      ),
    );
  }

  Widget buildAvatar(Contact contact) {
    if (contact.photo != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.memory(contact.photo!, fit: BoxFit.cover),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset(Assets.images.default_contact_avatar),
        ),
      );
    }
  }
}
