import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/pages/events/event_tab.dart';
import 'package:zipbuzz/pages/home/home_tab.dart';
import 'package:zipbuzz/pages/map/map_tab.dart';
import 'package:zipbuzz/pages/profile/profile_tab.dart';

enum InterestViewType {
  user,
  all,
}

final homeTabControllerProvider = StateNotifierProvider<HomeTabController, HomeTabState>((ref) {
  return HomeTabController();
});

class HomeTabController extends StateNotifier<HomeTabState> {
  HomeTabController()
      : super(HomeTabState(
          isSearching: true,
          index: 0,
          homeTabIndex: 0,
          previousOffset: 0,
          selectedCategory: '',
          interestViewType: InterestViewType.user,
        ));

  var tabs = const [
    HomeTab(),
    EventsTab(),
    MapTab(),
    ProfileTab(),
  ];

  final pageScrollController = ScrollController();
  final rowScrollController = ScrollController();
  final bodyScrollController = ScrollController();
  final queryController = TextEditingController();
  final categoryPageKey = GlobalKey();
  final rowCategoryKey = GlobalKey();

  void updateIndex(int index) {
    state = state.copyWith(homeTabIndex: index);
  }

  Future<bool> backToHomeTab() async {
    state = state.copyWith(homeTabIndex: 0);
    return false;
  }

  void updateBodyScrollController() {
    if (bodyScrollController.offset > 120 && state.isSearching) {
      state = state.copyWith(isSearching: false);
    } else if (bodyScrollController.offset < 120 && !state.isSearching) {
      state = state.copyWith(isSearching: true);
    }
    state = state.copyWith(previousOffset: bodyScrollController.offset);
  }

  void updatePageIndex(BuildContext context) {
    final index = ((pageScrollController.offset + 100) / MediaQuery.of(context).size.width).floor();

    state = state.copyWith(index: index);
  }

  void updateSearching(bool isSearching) {
    state = state.copyWith(isSearching: isSearching);
  }

  void toggleInterestView() {
    if (state.interestViewType == InterestViewType.user) {
      state = state.copyWith(interestViewType: InterestViewType.all);
      return;
    }
    state = state.copyWith(interestViewType: InterestViewType.user);
  }
}

class HomeTabState {
  bool isSearching;
  int index;
  int homeTabIndex;
  double previousOffset;
  String selectedCategory;
  InterestViewType interestViewType;

  HomeTabState({
    required this.isSearching,
    required this.index,
    required this.homeTabIndex,
    required this.previousOffset,
    required this.selectedCategory,
    required this.interestViewType,
  });

  HomeTabState copyWith({
    bool? isSearching,
    int? index,
    int? homeTabIndex,
    double? previousOffset,
    String? selectedCategory,
    InterestViewType? interestViewType,
  }) {
    return HomeTabState(
      isSearching: isSearching ?? this.isSearching,
      index: index ?? this.index,
      homeTabIndex: homeTabIndex ?? this.homeTabIndex,
      previousOffset: previousOffset ?? this.previousOffset,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      interestViewType: interestViewType ?? this.interestViewType,
    );
  }
}
