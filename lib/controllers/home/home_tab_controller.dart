import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/pages/events/event_tab.dart';
import 'package:zipbuzz/pages/home/home_tab.dart';
import 'package:zipbuzz/pages/map/map_tab.dart';
import 'package:zipbuzz/pages/profile/profile_tab.dart';

final homeTabControllerProvider = StateNotifierProvider<HomeTabController, int>((ref) {
  return HomeTabController();
});

class HomeTabController extends StateNotifier<int> {
  HomeTabController() : super(0);

  var tabs = const [
    HomeTab(),
    EventsTab(),
    MapTab(),
    ProfileTab(),
  ];

  void updateIndex(int index) {
    state = index;
  }

  Future<bool> backToHomeTab() async {
    state = 0;
    return false;
  }

  // home tab objects
  final pageScrollController = ScrollController();
  final rowScrollController = ScrollController();
  final bodyScrollController = ScrollController();
  final queryController = TextEditingController();
  final categoryPageKey = GlobalKey();
  final rowCategoryKey = GlobalKey();
  bool isSearching = true;
  int index = 0;
  double previousOffset = 0;
  String selectedCategory = '';

  void updateBodyScrollController() {
    if (bodyScrollController.offset > 120 && isSearching) {
      isSearching = false;
    } else if (bodyScrollController.offset < 120 && !isSearching) {
      isSearching = true;
    }
    previousOffset = bodyScrollController.offset;
  }

  void updatePageIndex(BuildContext context) {
    index = ((pageScrollController.offset + 100) / MediaQuery.of(context).size.width).floor();
  }
}
