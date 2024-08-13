import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/controllers/navigation_controller.dart';
import 'package:zipbuzz/models/groups/group_member_model.dart';
import 'package:zipbuzz/pages/groups/add_group_members.dart';
import 'package:zipbuzz/pages/groups/group_member_details_screen.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class GroupMembersScreen extends ConsumerStatefulWidget {
  static const id = '/groups/group-details/group-members';
  const GroupMembersScreen({super.key});

  @override
  ConsumerState<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends ConsumerState<GroupMembersScreen> {
  @override
  Widget build(BuildContext context) {
    final groupDes = ref.read(groupControllerProvider).currentGroupDescription;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          groupDes!.groupName,
          style: AppStyles.h2.copyWith(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () {
            navigatorKey.currentState!.pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        elevation: 0,
      ),
      body: ref.watch(groupControllerProvider).fetchingMembers
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAdmins(),
                  const SizedBox(height: 8),
                  _buildMembers(),
                ],
              ),
            ),
      floatingActionButton: _buildInviteMembersButton(),
    );
  }

  Widget _buildAdmins() {
    final admins = ref.watch(groupControllerProvider).admins;
    if (admins.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Admins",
          style: AppStyles.h3.copyWith(
            color: AppColors.greyColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          itemCount: admins.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return _buildMemberCard(admins[index], isAdmin: true);
          },
        ),
      ],
    );
  }

  Widget _buildMembers() {
    final members = ref.watch(groupControllerProvider).members;
    if (members.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Members",
          style: AppStyles.h3.copyWith(
            color: AppColors.greyColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          itemCount: members.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return _buildMemberCard(members[index]);
          },
        ),
      ],
    );
  }

  Widget _buildInviteMembersButton() {
    if (!ref.watch(groupControllerProvider).isAdmin) return const SizedBox();
    return GestureDetector(
      onTap: () async {
        ref.read(groupControllerProvider.notifier).clearSelectedContacts();
        ref.read(groupControllerProvider.notifier).contactSearchController.clear();
        await navigatorKey.currentState!.pushNamed(AddGroupMembers.id);
        ref.read(groupControllerProvider.notifier).getGroupMembers();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.buttonColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "Invite Members",
          style: AppStyles.h4.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  GestureDetector _buildMemberCard(GroupMemberModel member, {bool isAdmin = false}) {
    return GestureDetector(
      onTap: () {
        ref.read(groupControllerProvider.notifier).updateCurrentGroupMember(member, isAdmin);
        navigatorKey.currentState!.push(
          NavigationController.getTransition(
            GroupMemberDetailsScreen(userId: member.userId),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.bgGrey,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                member.name,
                style: AppStyles.h4.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.greyColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14)
          ],
        ),
      ),
    );
  }
}
