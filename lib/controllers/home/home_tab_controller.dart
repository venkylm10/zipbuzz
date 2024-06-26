import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/models/interests/responses/interest_model.dart';
import 'package:zipbuzz/pages/events/event_tab.dart';
import 'package:zipbuzz/pages/home/home_tab.dart';
import 'package:zipbuzz/pages/profile/profile_tab.dart';

enum InterestViewType {
  user,
  all,
}

final homeTabControllerProvider = StateNotifierProvider<HomeTabController, HomeTabState>((ref) {
  return HomeTabController(ref: ref);
});

class HomeTabController extends StateNotifier<HomeTabState> {
  HomeTabController({required this.ref})
      : super(HomeTabState(
          rowInterests: false,
          isSearching: false,
          index: 0,
          homeTabIndex: 0,
          previousOffset: 0,
          selectedCategory: '',
          interestViewType: InterestViewType.user,
          currentInterests: [],
        ));

  final Ref ref;

  var tabs = const [
    HomeTab(),
    EventsTab(),
    ProfileTab(),
  ];

  final pageScrollController = ScrollController();
  final rowScrollController = ScrollController();
  final bodyScrollController = ScrollController();
  final queryController = TextEditingController();
  final categoryPageKey = GlobalKey();
  final rowCategoryKey = GlobalKey();
  final homeButtonsKey = GlobalKey();

  void scrollToRowCategory() {
    Scrollable.ensureVisible(
      rowCategoryKey.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void updateRowInterests(bool rowInterests) {
    state = state.copyWith(rowInterests: rowInterests);
  }

  void updateIndex(int index) {
    ref.read(homeTabControllerProvider.notifier).selectCategory(category: "");
    state = state.copyWith(homeTabIndex: index);
  }

  Future<bool> backToHomeTab() async {
    state = state.copyWith(homeTabIndex: 0);
    return false;
  }

  void selectCategory({String category = ''}) {
    state = state.copyWith(selectedCategory: category);
  }

  bool updatePageIndex(BuildContext context) {
    int currentIndex = state.index;
    final index = ((pageScrollController.offset + 100) / MediaQuery.of(context).size.width).floor();
    state = state.copyWith(index: index);
    return currentIndex != index;
  }

  void updateSearching(bool isSearching) {
    if (isSearching) {
      scrollToCalender();
    } else {
      scrollToInteresets();
    }
    state = state.copyWith(isSearching: isSearching);
  }

  void toggleInterestView() {
    if (state.interestViewType == InterestViewType.user) {
      state = state.copyWith(interestViewType: InterestViewType.all);
      return;
    }
    state = state.copyWith(interestViewType: InterestViewType.user);
  }

  void updateCurrentInterests(List<InterestModel> interests) {
    state = state.copyWith(currentInterests: interests);
  }

  bool containsInterest(String activity) {
    return state.currentInterests.any((interest) => interest.activity == activity);
  }

  void toggleHomeTabInterest(InterestModel interest) {
    if (containsInterest(interest.activity)) {
      if (state.currentInterests.length <= 3) {
        return;
      }
      final interests =
          state.currentInterests.where((element) => element.activity != interest.activity).toList();
      state = state.copyWith(currentInterests: interests);
      return;
    }
    final contains = ref.read(userProvider).interests.contains(interest.activity);
    if (!contains) {
      var interests = ref.read(userProvider).interests;
      interests.add(interest.activity);
      ref.read(userProvider).copyWith(interests: interests);
    }
    addInterest(interest);
  }

  void addInterest(InterestModel interest) {
    final interests = state.currentInterests;
    interests.add(interest);
    state = state.copyWith(currentInterests: interests);
  }

  bool containsQuery(EventModel event) {
    final query = queryController.text.trim().toLowerCase();
    final res = event.title.toLowerCase().contains(query) ||
        event.about.toLowerCase().contains(query) ||
        event.hostName.toLowerCase().contains(query) ||
        event.category.toLowerCase().contains(query);
    return res;
  }

  void refresh() {
    state = state.copyWith();
  }

  void updateUserInterests() {
    final updatedInterests = state.currentInterests.map((e) => e.activity).toList();
    ref.read(userProvider.notifier).update(
          (state) => state.copyWith(
            interests: updatedInterests,
          ),
        );
  }

  void scrollToCalender() {
    if (homeButtonsKey.currentContext == null) return;
    Scrollable.ensureVisible(
      homeButtonsKey.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void scrollToInteresets() {
    if (categoryPageKey.currentContext == null) return;
    Scrollable.ensureVisible(
      categoryPageKey.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}

class HomeTabState {
  bool isSearching;
  int index;
  int homeTabIndex;
  double previousOffset;
  String selectedCategory;
  InterestViewType interestViewType;
  List<InterestModel> currentInterests;
  bool rowInterests;

  HomeTabState({
    required this.isSearching,
    required this.index,
    required this.homeTabIndex,
    required this.previousOffset,
    required this.selectedCategory,
    required this.interestViewType,
    required this.currentInterests,
    required this.rowInterests,
  });

  HomeTabState copyWith({
    bool? isSearching,
    int? index,
    int? homeTabIndex,
    double? previousOffset,
    String? selectedCategory,
    InterestViewType? interestViewType,
    List<InterestModel>? currentInterests,
    bool? rowInterests,
  }) {
    return HomeTabState(
      rowInterests: rowInterests ?? this.rowInterests,
      isSearching: isSearching ?? this.isSearching,
      index: index ?? this.index,
      homeTabIndex: homeTabIndex ?? this.homeTabIndex,
      previousOffset: previousOffset ?? this.previousOffset,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      interestViewType: interestViewType ?? this.interestViewType,
      currentInterests: currentInterests ?? this.currentInterests,
    );
  }
}
