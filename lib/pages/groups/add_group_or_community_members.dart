import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/services/contact_services.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/custom_text_field.dart';

class AddGroupOrCommunityMembers extends ConsumerStatefulWidget {
  static const id = '/groups/group-details/add-group-members';
  final bool isCommunity;
  const AddGroupOrCommunityMembers({super.key, this.isCommunity = false});

  @override
  ConsumerState<AddGroupOrCommunityMembers> createState() => _AddGroupMembersState();
}

class _AddGroupMembersState extends ConsumerState<AddGroupOrCommunityMembers> {
  @override
  void initState() {
    resetContacts();
    super.initState();
  }

  void resetContacts() async {
    await Future.delayed(const Duration(seconds: 1));
    ref.read(groupControllerProvider.notifier).resetContactSearchResult();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Members", style: AppStyles.h1),
        leading: IconButton(
          onPressed: () {
            navigatorKey.currentState!.pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              children: [
                CustomTextField(
                  controller: ref.read(groupControllerProvider.notifier).contactSearchController,
                  hintText: "Search contact",
                  onChanged: (val) {
                    ref.read(groupControllerProvider.notifier).updateContactSearchResult(val);
                  },
                  suffixIcon: GestureDetector(
                    onTap: () {
                      ref.read(groupControllerProvider.notifier).contactSearchController.clear();
                      ref.read(groupControllerProvider.notifier).updateContactSearchResult("");
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 12, top: 12),
                      child: Icon(
                        Icons.cancel_outlined,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSearchResult(),
              ],
            ),
          ),
          _buildLoader(),
        ],
      ),
      floatingActionButton: _buildInviteButton(),
    );
  }

  Widget _buildLoader() {
    if (!ref.watch(groupControllerProvider).invitingMembers) {
      return const SizedBox();
    }
    return Positioned.fill(
      child: Container(
        color: Colors.white12,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildInviteButton() {
    return Consumer(builder: (context, ref, child) {
      final selectedContacts = ref.watch(groupControllerProvider).selectedContacts.length;
      return GestureDetector(
        onTap: () {
          if (selectedContacts == 0) return;
          ref.read(groupControllerProvider.notifier).inviteMembersToGroup();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(360),
            color: const Color(0xff1F98A9),
          ),
          child: Text(
            "Invite ($selectedContacts)",
            style: AppStyles.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSearchResult() {
    return Consumer(builder: (context, ref, child) {
      final searchResults = ref.watch(groupControllerProvider).contactSearchResult;
      final selectedContactsSearchResult =
          ref.watch(groupControllerProvider).selectedContactsSearchResult;
      if (searchResults.isEmpty) {
        return Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              "No contacts found",
              style: AppStyles.h4.copyWith(
                color: AppColors.greyColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedContactsSearchResult.isNotEmpty)
            Text(
              "Selected Members",
              style: AppStyles.h5.copyWith(
                color: AppColors.greyColor,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (selectedContactsSearchResult.isNotEmpty) const SizedBox(height: 4),
          if (selectedContactsSearchResult.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(selectedContactsSearchResult.length, (index) {
                final contact = selectedContactsSearchResult[index];
                return _buildSelectedCardChip(contact);
              }),
            ),
          if (selectedContactsSearchResult.isNotEmpty) const SizedBox(height: 8),
          Text(
            "Search results",
            style: AppStyles.h5.copyWith(
              color: AppColors.greyColor,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          ListView.builder(
            itemCount: searchResults.length,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final contact = searchResults[index];
              return _buildMemberCard(contact);
            },
          )
        ],
      );
    });
  }

  Widget _buildSelectedCardChip(ContactModel contact) {
    return GestureDetector(
      onTap: () {
        ref.read(groupControllerProvider.notifier).toggleSelectedContact(contact);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              contact.displayName,
              style: AppStyles.h4.copyWith(color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.cancel_outlined, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(ContactModel contact) {
    return Consumer(builder: (context, ref, child) {
      final selected = ref.watch(groupControllerProvider).selectedContacts.contains(contact);
      return GestureDetector(
        onTap: () {
          ref.read(groupControllerProvider.notifier).toggleSelectedContact(contact);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border.all(color: selected ? AppColors.primaryColor : AppColors.borderGrey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contact.displayName,
                style: AppStyles.h4,
              ),
              Text(
                contact.phones.first,
                style: AppStyles.h5.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.greyColor,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
