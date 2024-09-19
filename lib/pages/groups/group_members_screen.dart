import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/controllers/navigation_controller.dart';
import 'package:zipbuzz/models/groups/group_member_model.dart';
import 'package:zipbuzz/models/groups/res/group_description_res.dart';
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
      appBar: _buildAppBar(groupDes),
      body: ref.watch(groupControllerProvider).fetchingMembers
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildAdmins(),
                const SizedBox(height: 8),
                _buildMembers(),
                const SizedBox(height: 8),
                _buildInvites(),
              ],
            ),
      floatingActionButton: _buildInviteMembersButton(),
    );
  }

  AppBar _buildAppBar(GroupDescriptionModel? groupDes) {
    return AppBar(
      title: Text(
        groupDes!.groupName,
        style: AppStyles.h2.copyWith(fontWeight: FontWeight.w600),
      ),
      leadingWidth: 80,
      leading: Row(
        children: [
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              navigatorKey.currentState!.pop();
            },
            child: const Icon(Icons.arrow_back_ios),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.network(
              groupDes.groupProfileImage,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: CupertinoActivityIndicator(),
                  ),
                );
              },
            ),
          )
        ],
      ),
      elevation: 0,
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
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return _buildMemberCard(admins[index], isAdmin: true);
          },
        ),
      ],
    );
  }

  Widget _buildInvites() {
    final invites = ref.watch(groupControllerProvider).invites;
    if (invites.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Invites",
          style: AppStyles.h3.copyWith(
            color: AppColors.greyColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          itemCount: invites.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return _buildMemberCard(invites[index], invitee: true);
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
          "Group members",
          style: AppStyles.h3.copyWith(
            color: AppColors.greyColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          itemCount: members.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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

  GestureDetector _buildMemberCard(GroupMemberModel member,
      {bool isAdmin = false, bool invitee = false}) {
    return GestureDetector(
      onTap: () {
        if (invitee) return;
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(member.profilePicture),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name == 'zipbuzz-null' ? member.phone : member.name,
                    style: AppStyles.h4.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.greyColor,
                    ),
                  ),
                  if (member.name != 'zipbuzz-null' && member.phone != 'zipbuzz-null')
                    Text(
                      member.phone,
                      style: AppStyles.h5.copyWith(
                        color: AppColors.lightGreyColor,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (!invitee) const Icon(Icons.arrow_forward_ios_rounded, size: 14)
          ],
        ),
      ),
    );
  }
}
