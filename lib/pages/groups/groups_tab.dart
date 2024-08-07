import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/pages/groups/create_group_form.dart';
import 'package:zipbuzz/pages/groups/widgets/create_group_button.dart';
import 'package:zipbuzz/pages/groups/widgets/group_tab_description_list.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/tabs.dart';

class GroupsTab extends ConsumerStatefulWidget {
  const GroupsTab({super.key});

  @override
  ConsumerState<GroupsTab> createState() => _GroupsTabState();
}

class _GroupsTabState extends ConsumerState<GroupsTab> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (value) => ref.read(homeTabControllerProvider.notifier).backToHomeTab(),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ref.watch(groupControllerProvider).creatingGroup
              ? const CreateGroupForm()
              : Column(
                  children: [
                    _buildGroupTabs(ref),
                    const SizedBox(height: 16),
                    const GroupTabDescriptionList(),
                  ],
                ),
        ),
        floatingActionButton: const CreateGroupButton(),
      ),
    );
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
    );
  }

  Row _buildGroupTabs(WidgetRef ref) {
    return Row(
      children: List.generate(
        GroupTab.values.length,
        (index) {
          final tab = GroupTab.values[index];
          final currentTab = ref.watch(groupControllerProvider).currentTab;
          final first = index == 0;
          return Expanded(
            flex: first ? 2 : 3,
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
