import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/pages/events/event_tab.dart';
import 'package:zipbuzz/pages/home/home_tab.dart';
import 'package:zipbuzz/pages/map/map_tab.dart';
import 'package:zipbuzz/pages/profile/profile_tab.dart';

final homeTabControllerProvider =
    StateNotifierProvider<HomeTabController, int>((ref) {
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
}
