import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';

enum AppTabs {
  home,
  events,
  groups,
  profile,
}

extension AppTabsExtension on AppTabs {
  String get name {
    switch (this) {
      case AppTabs.home:
        return 'Home';
      case AppTabs.events:
        return 'My Events';
      case AppTabs.groups:
        return 'Groups';
      case AppTabs.profile:
        return 'Profile';
    }
  }

  int get index {
    switch (this) {
      case AppTabs.home:
        return 0;
      case AppTabs.events:
        return 1;
      case AppTabs.groups:
        return 2;
      case AppTabs.profile:
        return 3;
    }
  }

  String get iconPath {
    switch (this) {
      case AppTabs.home:
        return Assets.icons.home;
      case AppTabs.events:
        return Assets.icons.events;
      case AppTabs.groups:
        return Assets.icons.group_tab;
      case AppTabs.profile:
        return Assets.icons.person;
    }
  }

  Widget get unSelectedIcon {
    switch (this) {
      case AppTabs.home:
      case AppTabs.events:
      case AppTabs.profile:
        return SvgPicture.asset(
          iconPath,
          colorFilter: const ColorFilter.mode(
            AppColors.greyColor,
            BlendMode.srcIn,
          ),
        );
      case AppTabs.groups:
        return Image.asset(iconPath, height: 20);
    }
  }

  Widget get selectedIcon {
    switch (this) {
      case AppTabs.home:
      case AppTabs.events:
      case AppTabs.profile:
        return SvgPicture.asset(
          iconPath,
          colorFilter: const ColorFilter.mode(
            AppColors.primaryColor,
            BlendMode.srcIn,
          ),
        );
      case AppTabs.groups:
        return Image.asset(
          iconPath,
          height: 20,
          color: AppColors.primaryColor,
        );
    }
  }

  static AppTabs fromIndex(int index) {
    switch (index) {
      case 0:
        return AppTabs.home;
      case 1:
        return AppTabs.events;
      case 2:
        return AppTabs.groups;
      case 3:
        return AppTabs.profile;
      default:
        return AppTabs.home;
    }
  }
}

enum GroupTab {
  all,
  personal,
  communities,
}

extension GroupTabExtension on GroupTab {
  String get name {
    switch (this) {
      case GroupTab.all:
        return 'All';
      case GroupTab.personal:
        return 'Personal';
      case GroupTab.communities:
        return 'Communities';
      default:
        return '';
    }
  }

  int get index {
    switch (this) {
      case GroupTab.all:
        return 0;
      case GroupTab.personal:
        return 1;
      case GroupTab.communities:
        return 2;
      default:
        return 0;
    }
  }

  static GroupTab fromIndex(int index) {
    switch (index) {
      case 0:
        return GroupTab.all;
      case 1:
        return GroupTab.personal;
      case 2:
        return GroupTab.communities;
      default:
        return GroupTab.all;
    }
  }
}
