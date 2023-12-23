import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';

class Home extends ConsumerWidget {
  static const id = '/home';
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(homeTabControllerProvider);
    final tabs = ref.read(homeTabControllerProvider.notifier).tabs;
    return Scaffold(
      body: tabs[selectedTab],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        currentIndex: selectedTab,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppStyles.h5.copyWith(color: AppColors.primaryColor),
        unselectedLabelStyle: AppStyles.h5.copyWith(color: AppColors.greyColor),
        fixedColor: AppColors.primaryColor,
        onTap: (value) {
          ref.read(homeTabControllerProvider.notifier).updateIndex(value);
          if (value == 0) {
            ref.read(homeTabControllerProvider.notifier).isSearching = true;
          }
        },
        items: [
          BottomNavigationBarItem(
            label: 'Home',
            icon: SvgPicture.asset(
              Assets.icons.home,
              colorFilter: ColorFilter.mode(
                selectedTab == 0 ? AppColors.primaryColor : AppColors.greyColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          BottomNavigationBarItem(
            label: 'My Events',
            icon: SvgPicture.asset(
              Assets.icons.events,
              colorFilter: ColorFilter.mode(
                selectedTab == 1 ? AppColors.primaryColor : AppColors.greyColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          BottomNavigationBarItem(
            label: 'Map',
            icon: SvgPicture.asset(
              Assets.icons.map,
              colorFilter: ColorFilter.mode(
                selectedTab == 2 ? AppColors.primaryColor : AppColors.greyColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          BottomNavigationBarItem(
            label: 'Profile',
            icon: SvgPicture.asset(
              Assets.icons.person,
              colorFilter: ColorFilter.mode(
                selectedTab == 3 ? AppColors.primaryColor : AppColors.greyColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
