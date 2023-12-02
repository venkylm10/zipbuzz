import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/controllers/events_tab_controler.dart';
import 'package:zipbuzz/controllers/home_tab_controller.dart';

class EventsTab extends ConsumerWidget {
  const EventsTab({super.key});

  void updateIndex(int index, WidgetRef ref) {
    ref.read(eventTabControllerProvider.notifier).updateIndex(index);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(eventTabControllerProvider);
    final tabs = ref.watch(eventTabControllerProvider.notifier).tabs;
    final tabTitles = ref.read(eventTabControllerProvider.notifier).tabTitles;
    return PopScope(
      canPop: false,
      onPopInvoked: (value) =>
          ref.read(homeTabControllerProvider.notifier).backToHomeTab(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "My Events",
            style: AppStyles.h2.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
          leading: const SizedBox(),
          centerTitle: true,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SingleChildScrollView(
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
                      tabs.length,
                      (index) => Expanded(
                        child: GestureDetector(
                          onTap: () {
                            updateIndex(index, ref);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: selectedTab == index
                                  ? AppColors.bgGrey
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                tabTitles[index],
                                style: AppStyles.h5.copyWith(
                                  color: selectedTab == index
                                      ? AppColors.primaryColor
                                      : AppColors.textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                tabs[selectedTab],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
