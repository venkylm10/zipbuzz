import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/community/community_controller.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/pages/community/create_community_form.dart';
import 'package:zipbuzz/pages/community/widgets/create_community_button.dart';
import 'package:zipbuzz/pages/groups/create_group_form.dart';
import 'package:zipbuzz/pages/groups/widgets/create_group_button.dart';
import 'package:zipbuzz/pages/groups/widgets/group_tab_description_list.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/tabs.dart';

class GroupsTab extends ConsumerWidget {
  const GroupsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) =>
          ref.read(homeTabControllerProvider.notifier).backToHomeTab(),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildBody(ref),
        ),
        floatingActionButton: _createButton(),
      ),
    );
  }

  Widget _buildBody(WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        if (ref.watch(groupControllerProvider).creatingGroup) {
          return const CreateGroupForm();
        } else if (ref.watch(communityControllerProvider).creatingCommunity) {
          return const CreateCommunityForm();
        }
        return Column(
          children: [
            const SizedBox(height: 8),
            _buildGroupTabs(ref),
            const SizedBox(height: 16),
            const Expanded(child: GroupTabDescriptionList()),
          ],
        );
      },
    );
  }

  Consumer _createButton() {
    return Consumer(builder: (context, ref, child) {
      final tab = ref.watch(groupControllerProvider).currentTab;
      if (tab == GroupTab.communities) {
        return const CreateCommunityButton();
      }
      return const CreateGroupButton();
    });
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        "Groups",
        style: AppStyles.h2.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.primaryColor,
        ),
      ),
      leading: const SizedBox(),
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }

  Row _buildGroupTabs(WidgetRef ref) {
    return Row(
      children: List.generate(
        GroupTab.values.length - 1,
        (index) {
          final tab = GroupTab.values[index];
          final currentTab = ref.watch(groupControllerProvider).currentTab;
          return Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                ref.read(groupControllerProvider.notifier).changeCurrentTab(tab);
              },
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(360),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                margin: index == 1 ? const EdgeInsets.symmetric(horizontal: 8) : null,
                decoration: BoxDecoration(
                  color: currentTab == tab
                      ? AppColors.primaryColor
                      : AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(360),
                  border: Border.all(color: AppColors.borderGrey),
                ),
                child: Center(
                  child: Text(
                    tab.name,
                    style: AppStyles.h5.copyWith(
                      color: currentTab == tab ? Colors.white : null,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
