import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/widgets/custom_bezel.dart';
import 'package:zipbuzz/pages/home/widgets/bottom_bar.dart';
import 'package:zipbuzz/utils/widgets/no_internet_screen.dart';

class Home extends ConsumerStatefulWidget {
  static const id = '/home';
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  @override
  void initState() {
    internetCheck();
    super.initState();
  }

  void internetCheck() async {
    final res = await checkInternet();
    if (!res) {
      navigatorKey.currentState!.pushNamed(NoInternetScreen.id);
    }
  }

  @override
  Widget build(BuildContext context) {
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
