import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/controllers/navigation_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/groups/group_model.dart';
import 'package:zipbuzz/pages/groups/add_group_or_community_members.dart';
import 'package:zipbuzz/pages/groups/edit_group_screen.dart';
import 'package:zipbuzz/pages/groups/group_members_screen.dart';
import 'package:zipbuzz/pages/home/home.dart';
import 'package:zipbuzz/pages/home/widgets/bottom_bar.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';

class GroupDetailsScreen extends ConsumerStatefulWidget {
  static const id = '/groups/group-details';
  final int? groupId;
  final bool redirectToMembers;
  const GroupDetailsScreen({super.key, this.groupId, this.redirectToMembers = false});

  @override
  ConsumerState<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends ConsumerState<GroupDetailsScreen> {
  late GroupModel group;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(groupControllerProvider.notifier).getGroupDetails(
            groupId: widget.groupId,
          );
      if (widget.redirectToMembers) {
        navigatorKey.currentState!.pushNamed(GroupMembersScreen.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer(
        builder: (context, ref, child) {
          if (ref.watch(groupControllerProvider).loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            );
          }
          if (ref.watch(groupControllerProvider).currentGroup == null) {
            return Center(
              child: IconButton(
                onPressed: () {
                  ref.read(groupControllerProvider.notifier).getGroupDetails();
                },
                icon: const Icon(Icons.refresh_rounded),
              ),
            );
          }
          group = ref.watch(groupControllerProvider).currentGroup!;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildCoverImages(),
                const SizedBox(height: 16),
                Text(
                  group.name,
                  style: AppStyles.h2.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  group.description,
                  style: AppStyles.h3.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                _buildDetailTab("Members", onTap: () {
                  navigatorKey.currentState!.pushNamed(GroupMembersScreen.id);
                }),
                _buildDetailTab("Links and Media"),
                // _buildPublicToggleButton(),
                const SizedBox(height: 16),
                _buildInviteMembersButton(),
                _buildExitButton(),
                _buildDeleteButton()
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomBar(
        selectedTab: ref.watch(homeTabControllerProvider).selectedTab.index,
        pop: () {
          navigatorKey.currentState!.pushNamedAndRemoveUntil(Home.id, (route) => false);
        },
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Consumer(builder: (context, ref, child) {
      if (!ref.watch(groupControllerProvider).isAdmin) return const SizedBox();
      return InkWell(
        onTap: () {
          ref.read(groupControllerProvider.notifier).archiveGroup();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryColor),
          ),
          child: Text(
            "Archive/Delete Group",
            style: AppStyles.h4.copyWith(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildExitButton() {
    return GestureDetector(
      onTap: () async {
        final userId = ref.read(userProvider).id;
        final admin = ref.read(groupControllerProvider).admins.any((e) => e.userId == userId);
        if (admin && ref.read(groupControllerProvider).admins.length == 1) {
          showSnackBar(
            message: "You are the only admin in the group.",
            duration: 5,
          );
          return;
        }
        final groupName = group.name;
        await ref.read(groupControllerProvider.notifier).deleteGroupMember(userId);
        navigatorKey.currentState!.pushNamedAndRemoveUntil(Home.id, (route) => false);
        Future.delayed(const Duration(milliseconds: 500));
        ref.read(groupControllerProvider.notifier).fetchCommunityAndGroupDescriptions();
        showSnackBar(message: "You have exited $groupName");
      },
      child: Container(
        margin: const EdgeInsets.only(top: 32, bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryColor),
        ),
        child: Text(
          "Exit from Group",
          style: AppStyles.h4.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildInviteMembersButton() {
    return Consumer(builder: (context, ref, child) {
      final user = ref.read(userProvider);
      final admin = ref.watch(groupControllerProvider).admins.any((e) => e.userId == user.id);
      if (!admin) return const SizedBox();
      return GestureDetector(
        onTap: () async {
          ref.read(groupControllerProvider.notifier).clearSelectedContacts();
          ref.read(groupControllerProvider.notifier).contactSearchController.clear();
          await navigatorKey.currentState!.pushNamed(AddGroupOrCommunityMembers.id);
          await navigatorKey.currentState!.pushNamed(GroupMembersScreen.id);
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
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    });
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          navigatorKey.currentState!.pop();
        },
        icon: const Icon(Icons.arrow_back_ios),
      ),
      elevation: 0,
      actions: [
        Consumer(builder: (context, ref, child) {
          if (!ref.watch(groupControllerProvider).isAdmin) return const SizedBox();
          return IconButton(
            onPressed: _moveToEditScreen,
            icon: const Icon(Icons.edit_rounded, color: AppColors.primaryColor),
          );
        })
      ],
    );
  }

  void _moveToEditScreen() {
    try {
      ref.read(groupControllerProvider.notifier).initEditGroup(group);
      navigatorKey.currentState!.push(NavigationController.getTransition(const EditGroupScreen()));
    } catch (e) {
      showSnackBar(message: "Please wait till the details are fetched and try again");
    }
  }

  Widget _buildPublicToggleButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Available to Public",
              style: AppStyles.h4.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.greyColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 74,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.borderGrey,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: group.listed ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Container(
                  height: 24,
                  width: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailTab(String title, {Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16).copyWith(top: 0),
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
                title,
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

  Widget _buildCoverImages() {
    return SizedBox(
      height: 160,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(group.banner),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(group.image),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
