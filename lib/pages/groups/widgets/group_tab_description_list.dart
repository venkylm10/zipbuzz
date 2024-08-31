import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/groups/res/description_model.dart';
import 'package:zipbuzz/models/groups/res/group_description_res.dart';
import 'package:zipbuzz/pages/groups/group_events_screen.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/tabs.dart';

class GroupTabDescriptionList extends ConsumerWidget {
  const GroupTabDescriptionList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(groupControllerProvider).currentTab;
    final allGroups = ref.watch(groupControllerProvider).currentGroups;
    final communities = ref.watch(groupControllerProvider).currentCommunities;
    if (ref.watch(groupControllerProvider).fetchingList) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
        ),
      );
    }
    return tab == GroupTab.communities
        ? _buildCommunityList(communities, ref)
        : _buildGroupsList(tab, allGroups, ref);
  }

  Widget _buildGroupsList(GroupTab tab, List<DescriptionModel> allGroups, WidgetRef ref) {
    final user = ref.read(userProvider);
    final groups =
        tab == GroupTab.all ? allGroups : allGroups.where((e) => e.creatorId == user.id).toList();
    if (groups.isEmpty) {
      return Center(
        child: Text(
          "No groups to show",
          style: AppStyles.h4.copyWith(
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
            color: AppColors.lightGreyColor,
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: groups.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return _buildGroupTitleCard(groups[index], ref);
      },
    );
  }

  Widget _buildCommunityList(List<DescriptionModel> communities, WidgetRef ref) {
    if (communities.isEmpty) {
      return Center(
        child: Text(
          "No communities to show",
          style: AppStyles.h4.copyWith(
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
            color: AppColors.lightGreyColor,
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: communities.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return _buildGroupTitleCard(communities[index], ref);
      },
    );
  }

  Widget _buildGroupTitleCard(DescriptionModel description, WidgetRef ref) {
    if (description.archive) return const SizedBox();
    return GestureDetector(
      onTap: () async {
        // Update the current group description
        if (description.type == 'group') {
          debugPrint("Group Id: ${description.id}");
          ref.read(groupControllerProvider.notifier).resetController();
          final groupDescription = GroupDescriptionModel(
            id: description.id,
            groupName: description.name,
            groupDescription: description.description,
          );
          ref
              .read(groupControllerProvider.notifier)
              .updateCurrentGroupDescription(groupDescription);
          ref.read(groupControllerProvider.notifier).getGroupMembers();
          await navigatorKey.currentState!.pushNamed(GroupEventsScreen.id);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderGrey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                description.name,
                style: AppStyles.h4.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              ">",
              style: AppStyles.h4.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
