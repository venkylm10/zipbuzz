import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/tabs.dart';

class GroupEventScreenTabs extends StatelessWidget {
  const GroupEventScreenTabs({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Consumer(
      builder: (context, ref, child) {
        final selectedTab = ref.watch(groupControllerProvider).groupEventsTab;
        return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.borderGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: List.generate(
                GroupEventsTab.values.length,
                (index) {
                  final tab = GroupEventsTab.values[index];
                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        ref.read(groupControllerProvider.notifier).changeGroupEventsTab(tab);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: selectedTab == tab ? AppColors.bgGrey : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            GroupEventsTab.values[index].name,
                            style: AppStyles.h5.copyWith(
                              color:
                                  selectedTab == tab ? AppColors.primaryColor : AppColors.textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedTab.name,
                style: AppStyles.h4.copyWith(fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: () {
                  ref.read(groupControllerProvider.notifier).toggleEventCalendarVisibility();
                },
                child: SvgPicture.asset(
                  ref.watch(groupControllerProvider).showCalendar
                      ? Assets.icons.home_calender_visible
                      : Assets.icons.home_calender_not_visible,
                ),
              ),
            ],
          ),
        ],
      ),
    );
      },
    );
  }
}