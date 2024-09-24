import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/models/groups/res/group_description_res.dart';
import 'package:zipbuzz/pages/groups/add_group_members.dart';
import 'package:zipbuzz/pages/groups/widgets/group_member_card.dart';
import 'package:zipbuzz/pages/home/home.dart';
import 'package:zipbuzz/pages/home/widgets/bottom_bar.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(groupControllerProvider.notifier).getGroupMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupDes = ref.read(groupControllerProvider).currentGroupDescription;
    return Scaffold(
      appBar: _buildAppBar(groupDes),
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width,
            child: ref.watch(groupControllerProvider).fetchingMembers
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
          ),
          Positioned.fill(
            child: Consumer(
              builder: (context, ref, child) {
                return ref.watch(groupControllerProvider).loading
                    ? Container(
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      )
                    : const SizedBox();
              },
            ),
          )
        ],
      ),
      floatingActionButton: _buildInviteMembersButton(),
      bottomNavigationBar: BottomBar(
        selectedTab: ref.watch(homeTabControllerProvider).selectedTab.index,
        pop: () {
          navigatorKey.currentState!.pushNamedAndRemoveUntil(Home.id, (route) => false);
        },
      ),
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
            return GroupMemberCard(member: admins[index], isAdmin: true);
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
          "Invited",
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
            return GroupMemberCard(member: invites[index], invitee: true);
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
            return GroupMemberCard(member: members[index]);
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
}
