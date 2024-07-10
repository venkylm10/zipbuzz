import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/utils/widgets/custom_bezel.dart';
import 'package:zipbuzz/pages/home/widgets/bottom_bar.dart';

class Home extends ConsumerWidget {
  static const id = '/home';
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(homeTabControllerProvider).homeTabIndex;
    final tabs = ref.read(homeTabControllerProvider.notifier).tabs;
    return CustomBezel(
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: tabs[selectedTab],
        ),
        bottomNavigationBar: BottomBar(selectedTab: selectedTab),
      ),
    );
  }
}
