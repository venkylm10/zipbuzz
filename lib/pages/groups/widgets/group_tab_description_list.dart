import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/community/community_controller.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/models/groups/res/description_model.dart';
import 'package:zipbuzz/models/groups/res/group_description_res.dart';
import 'package:zipbuzz/pages/community/community_detail_page.dart';
import 'package:zipbuzz/pages/groups/group_events_screen.dart';
import 'package:zipbuzz/pages/home/widgets/no_upcoming_events_banner.dart';
import 'package:zipbuzz/pages/notification/notification_page.dart';
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(
            color: AppColors.primaryColor,
          ),
        ),
      );
    }
    return tab == GroupTab.communities
        ? _buildCommunityList(communities, ref)
        : _buildGroupsList(tab, allGroups, ref);
  }

  Widget _buildGroupsList(GroupTab tab, List<DescriptionModel> allGroups, WidgetRef ref) {
    final groups = tab == GroupTab.all
        ? allGroups.where((e) {
            return e.permissionType == 'a' || e.permissionType == 'o' || e.permissionType == 'm';
          }).toList()
        : allGroups.where((e) {
            return e.permissionType == 'a' || e.permissionType == 'o' || e.permissionType == 'm';
          }).toList();
    final pendingOrRequestedGroups =
        allGroups.where((e) => e.permissionType == 'i' || e.permissionType == 'p').toList();
    if (groups.isEmpty && pendingOrRequestedGroups.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 44),
        child: NoUpcomingEventsBanner(
          title: "No groups to show",
          subtitle: "Create a group to get started",
          onTap: (ref) {
            ref.read(groupControllerProvider.notifier).toggleCreatingGroup();
          },
          buttonLabel: "Create Group",
        ),
      );
    }
    final length = groups.length + pendingOrRequestedGroups.length + 1;
    return ListView.builder(
      itemCount: length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index < groups.length) {
          return _buildJoinedGroups(groups, index, ref);
        } else if (index != length - 1) {
          return _buildPendingOrRequestedGroups(index, groups, pendingOrRequestedGroups, ref);
        }
        return const SizedBox(height: 100);
      },
    );
  }

  Column _buildPendingOrRequestedGroups(int index, List<DescriptionModel> groups,
      List<DescriptionModel> pendingOrRequestedGroups, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index == groups.length && pendingOrRequestedGroups.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Pending/Requested Groups",
              style: AppStyles.h4.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        _buildGroupTitleCard(
          pendingOrRequestedGroups[index - groups.length],
          ref,
          redirectToNotificationScreen: true,
        ),
      ],
    );
  }

  Column _buildJoinedGroups(List<DescriptionModel> groups, int index, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (groups.isNotEmpty && index == 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 8),
            child: Text(
              "Joined Groups",
              style: AppStyles.h4.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        _buildGroupTitleCard(groups[index], ref),
      ],
    );
  }

  Widget _buildCommunityList(List<DescriptionModel> communities, WidgetRef ref) {
    if (communities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 44),
        child: NoUpcomingEventsBanner(
          title: "No communities to show",
          subtitle: "Create a community to get started",
          onTap: (ref) {
            ref.read(communityControllerProvider.notifier).toggleCreatingCommunity();
          },
          buttonLabel: "Create Community",
        ),
      );
    }
    return ListView.builder(
      itemCount: communities.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return _buildCommuityTitleCard(communities[index], ref);
      },
    );
  }

  Widget _buildCommuityTitleCard(DescriptionModel description, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(communityControllerProvider.notifier).updateLoading(true);
        ref.read(communityControllerProvider.notifier).updateCurrentDesc(description);
        navigatorKey.currentState!.pushNamed(CommunityDetailPage.id);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderGrey),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.network(
                description.profileImage,
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
            ),
            const SizedBox(width: 8),
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

  Widget _buildGroupTitleCard(DescriptionModel description, WidgetRef ref,
      {bool redirectToNotificationScreen = false}) {
    if (description.archive) return const SizedBox();
    return GestureDetector(
      onTap: () async {
        if (redirectToNotificationScreen) {
          final events = ref.read(eventsControllerProvider).currentMonthEvents;
          await navigatorKey.currentState!.pushNamed(NotificationPage.id, arguments: {
            'group_id': description.id,
          });
          ref.read(eventsControllerProvider.notifier).fixHomeEvents(events);
          ref.read(eventsControllerProvider.notifier).fetchEvents();
          return;
        }
        // Update the current group description
        if (description.type == 'group') {
          debugPrint("Group Id: ${description.id}");
          ref.read(groupControllerProvider.notifier).resetController();
          final groupDescription = GroupDescriptionModel(
            id: description.id,
            groupName: description.name,
            groupDescription: description.description,
            groupProfileImage: description.profileImage,
          );
          ref
              .read(groupControllerProvider.notifier)
              .updateCurrentGroupDescription(groupDescription);
          ref.read(groupControllerProvider.notifier).getGroupMembers();
          await navigatorKey.currentState!.pushNamed(GroupEventsScreen.id);
          ref.read(groupControllerProvider.notifier).fetchCommunityAndGroupDescriptions();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderGrey),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.network(
                description.profileImage,
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
            ),
            const SizedBox(width: 8),
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
            if (!redirectToNotificationScreen)
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
