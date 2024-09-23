import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/pages/groups/create_group_form.dart';
import 'package:zipbuzz/pages/home/home.dart';
import 'package:zipbuzz/pages/home/widgets/bottom_bar.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class EditGroupScreen extends ConsumerWidget {
  const EditGroupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            navigatorKey.currentState!.pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Text("Edit Group", style: AppStyles.h2),
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: CreateGroupForm(editing: true),
      ),
      bottomNavigationBar: BottomBar(
          selectedTab: ref.watch(homeTabControllerProvider).selectedTab.index,
          pop: () {
            navigatorKey.currentState!.pushNamedAndRemoveUntil(Home.id, (route) => false);
          },
        ),
    );
  }
}
