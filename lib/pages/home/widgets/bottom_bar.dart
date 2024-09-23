import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/user/requests/user_details_request_model.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/tabs.dart';

class BottomBar extends ConsumerWidget {
  const BottomBar({
    super.key,
    required this.selectedTab,
    this.pop,
  });

  final int selectedTab;
  final VoidCallback? pop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomNavigationBar(
      elevation: 0,
      currentIndex: selectedTab,
      showUnselectedLabels: true,
      showSelectedLabels: true,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: AppStyles.h5.copyWith(color: AppColors.primaryColor),
      unselectedLabelStyle: AppStyles.h5.copyWith(color: AppColors.greyColor),
      fixedColor: AppColors.primaryColor,
      onTap: (value) async {
        final userId = ref.read(userProvider).id;
        final tab = AppTabsExtension.fromIndex(value);
        ref.read(homeTabControllerProvider.notifier).updateSelectedTab(tab);
        await Future.delayed(const Duration(milliseconds: 100));
        if (tab == AppTabs.home) {
          ref.read(homeTabControllerProvider.notifier).updateSearching(false);
          ref.read(newEventProvider.notifier).resetNewEvent();
          ref.read(homeTabControllerProvider.notifier).queryController.clear();
          ref.read(homeTabControllerProvider.notifier).refresh();
        } else if (tab == AppTabs.events) {
          final user = ref.read(userProvider);
          ref.read(newEventProvider.notifier).updateHostId(user.id);
          ref.read(newEventProvider.notifier).updateHostName(user.name);
          ref.read(newEventProvider.notifier).updateHostPic(user.imageUrl);
          ref.read(eventsControllerProvider.notifier).fetchUserEvents();
        } else if (tab == AppTabs.groups) {
          ref.read(groupControllerProvider.notifier).fetchCommunityAndGroupDescriptions();
        } else {
          pop != null ? pop!() : null;
          await ref
              .read(dbServicesProvider)
              .getOwnUserData(UserDetailsRequestModel(userId: userId));
          ref.read(newEventProvider.notifier).resetNewEvent();
          return;
        }
        pop != null ? pop!() : null;
      },
      items: List.generate(AppTabs.values.length, (index) {
        final tab = AppTabsExtension.fromIndex(index);
        return BottomNavigationBarItem(
          icon: selectedTab == index ? tab.selectedIcon : tab.unSelectedIcon,
          label: tab.name,
        );
      }),
    );
  }
}
