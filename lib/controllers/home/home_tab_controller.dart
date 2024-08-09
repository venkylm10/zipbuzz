import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/models/interests/responses/interest_model.dart';
import 'package:zipbuzz/pages/events/event_tab.dart';
import 'package:zipbuzz/pages/groups/groups_tab.dart';
import 'package:zipbuzz/pages/home/home_tab.dart';
import 'package:zipbuzz/pages/profile/profile_tab.dart';
import 'package:zipbuzz/utils/tabs.dart';

enum InterestViewType { user, all }

final homeTabControllerProvider = StateNotifierProvider<HomeTabController, HomeTabState>((ref) {
  return HomeTabController(ref: ref);
});

class HomeTabController extends StateNotifier<HomeTabState> {
  HomeTabController({required this.ref})
      : super(
          HomeTabState(
            isSearching: false,
            index: 0,
            selectedTab: AppTabs.home,
            previousOffset: 0,
            selectedCategory: '',
            interestViewType: InterestViewType.user,
            currentInterests: [],
          ),
        );

  final Ref ref;

  final tabs = const [
    HomeTab(),
    EventsTab(),
    GroupsTab(),
    ProfileTab(),
  ];

  final pageScrollController = ScrollController();
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

  void updateSelectedTab(AppTabs tab) {
    ref.read(homeTabControllerProvider.notifier).selectCategory(category: "");
    state = state.copyWith(selectedTab: tab);
  }

  Future<bool> backToHomeTab() async {
    state = state.copyWith(selectedTab: AppTabs.home);
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

  Future<void> toggleHomeCategory(String interest) async {
    updateRowInterests(true);
    if (state.selectedCategory != interest) {
      selectCategory(category: interest);
      await Future.delayed(const Duration(milliseconds: 500));
    } else {
      ref.read(homeTabControllerProvider.notifier).selectCategory(category: '');
    }
  }

  void toggleHomeCalenderVisibility() {
    state = state.copyWith(homeCalenderVisible: !state.homeCalenderVisible);
  }
}

class HomeTabState {
  bool isSearching;
  int index;
  AppTabs selectedTab;
  double previousOffset;
  String selectedCategory;
  InterestViewType interestViewType;
  List<InterestModel> currentInterests;
  bool homeCalenderVisible;

  HomeTabState({
    required this.isSearching,
    required this.index,
    required this.selectedTab,
    required this.previousOffset,
    required this.selectedCategory,
    required this.interestViewType,
    required this.currentInterests,
    this.homeCalenderVisible = false,
  });

  HomeTabState copyWith({
    bool? isSearching,
    int? index,
    AppTabs? selectedTab,
    double? previousOffset,
    String? selectedCategory,
    InterestViewType? interestViewType,
    List<InterestModel>? currentInterests,
    bool? rowInterests,
    bool? homeCalenderVisible,
  }) {
    return HomeTabState(
      isSearching: isSearching ?? this.isSearching,
      index: index ?? this.index,
      selectedTab: selectedTab ?? this.selectedTab,
      previousOffset: previousOffset ?? this.previousOffset,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      interestViewType: interestViewType ?? this.interestViewType,
      currentInterests: currentInterests ?? this.currentInterests,
      homeCalenderVisible: homeCalenderVisible ?? this.homeCalenderVisible,
    );
  }
}
