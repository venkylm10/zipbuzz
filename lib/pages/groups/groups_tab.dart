import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';

class GroupsTab extends ConsumerWidget {
  const GroupsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop,result) => ref.read(homeTabControllerProvider.notifier).backToHomeTab(),
      child: const Scaffold(
        body: Center(child: Text("Groups")),
      ),
    );
  }
}
