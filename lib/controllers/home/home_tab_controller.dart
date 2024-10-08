import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/models/interests/responses/interest_model.dart';
import 'package:zipbuzz/models/notification_data.dart';
import 'package:zipbuzz/pages/events/event_tab.dart';
import 'package:zipbuzz/pages/groups/groups_tab.dart';
import 'package:zipbuzz/pages/home/home_tab.dart';
import 'package:zipbuzz/pages/profile/profile_tab.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/tabs.dart';
import 'package:zipbuzz/utils/widgets/loader.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';

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
            interestViewType: InterestViewType.user,
            currentInterests: [],
            queryInterests: [],
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
  final queryController = TextEditingController();
  final zipcodeControler = TextEditingController();
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
    state = state.copyWith(selectedTab: tab);
  }

  Future<bool> backToHomeTab() async {
    state = state.copyWith(selectedTab: AppTabs.home);
    return false;
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

  bool containsInterest(String activity, {bool querySheet = false}) {
    if (querySheet) {
      return state.queryInterests.any((interest) => interest.activity == activity);
    }
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

  void toggleQueryInterest(InterestModel interest) {
    if (containsInterest(interest.activity, querySheet: true)) {
      final interests =
          state.queryInterests.where((element) => element.activity != interest.activity).toList();
      state = state.copyWith(queryInterests: interests);
      updateInQuery();
      return;
    }
    addQueryInterest(interest);
    updateInQuery();
  }

  void addQueryInterest(InterestModel interest) {
    final interests = state.queryInterests;
    interests.add(interest);
    state = state.copyWith(queryInterests: interests);
  }

  void addInterest(InterestModel interest) {
    final interests = state.currentInterests;
    interests.add(interest);
    state = state.copyWith(currentInterests: interests);
  }

  bool containsQuery(EventModel event) {
    final query = queryController.text.trim().toLowerCase();
    var res = event.title.toLowerCase().contains(query) ||
        event.about.toLowerCase().contains(query) ||
        event.hostName.toLowerCase().contains(query) ||
        event.category.toLowerCase().contains(query);
    if (state.queryInterests.isNotEmpty) {
      res = res && state.queryInterests.any((interest) => event.category == interest.activity);
    }
    return res;
  }

  void resetInQuery() {
    queryController.clear();
    zipcodeControler.clear();
    state = state.copyWith(inQuery: false, queryInterests: []);
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

  void toggleHomeCalenderVisibility() {
    state = state.copyWith(homeCalenderVisible: !state.homeCalenderVisible);
  }

  void updateInQuery() {
    if (queryController.text.trim().isNotEmpty ||
        zipcodeControler.text.trim().isNotEmpty ||
        state.queryInterests.isNotEmpty) {
      state = state.copyWith(inQuery: true);
      return;
    }
    state = state.copyWith(inQuery: false);
  }

  void cloneUserDataToQuery() {
    final user = ref.read(userProvider);
    final interests = user.interests;
    final zipcode = user.zipcode;
    final models = allInterests.where((e) => interests.contains(e.activity)).toList();
    zipcodeControler.text = zipcode;
    state = state.copyWith(queryInterests: models, inQuery: false);
  }

  Future<void> getNotifications() async {
    List<NotificationData> notifications = [];
    ref.read(eventsControllerProvider.notifier).updateLoadingState(true);
    try {
      notifications = await ref.read(dioServicesProvider).getNotifications();
    } catch (e) {
      debugPrint("Error getting notifications: $e");
      notifications = state.notifications;
      showSnackBar(message: "Error getting notifications");
    }
    ref.read(loadingTextProvider.notifier).reset();
    ref.read(eventsControllerProvider.notifier).updateLoadingState(false);
    state = state.copyWith(notifications: notifications);
  }
}

class HomeTabState {
  bool isSearching;
  int index;
  AppTabs selectedTab;
  double previousOffset;
  InterestViewType interestViewType;
  List<InterestModel> currentInterests;
  List<InterestModel> queryInterests;
  bool inQuery;
  bool homeCalenderVisible;
  List<NotificationData> notifications;

  HomeTabState({
    required this.isSearching,
    required this.index,
    required this.selectedTab,
    required this.previousOffset,
    required this.interestViewType,
    required this.currentInterests,
    required this.queryInterests,
    this.homeCalenderVisible = false,
    this.inQuery = false,
    this.notifications = const [],
  });

  HomeTabState copyWith({
    bool? isSearching,
    int? index,
    AppTabs? selectedTab,
    double? previousOffset,
    InterestViewType? interestViewType,
    List<InterestModel>? currentInterests,
    List<InterestModel>? queryInterests,
    bool? rowInterests,
    bool? homeCalenderVisible,
    bool? inQuery,
    List<NotificationData>? notifications,
  }) {
    return HomeTabState(
      isSearching: isSearching ?? this.isSearching,
      index: index ?? this.index,
      selectedTab: selectedTab ?? this.selectedTab,
      previousOffset: previousOffset ?? this.previousOffset,
      interestViewType: interestViewType ?? this.interestViewType,
      currentInterests: currentInterests ?? this.currentInterests,
      homeCalenderVisible: homeCalenderVisible ?? this.homeCalenderVisible,
      queryInterests: queryInterests ?? this.queryInterests,
      inQuery: inQuery ?? this.inQuery,
      notifications: notifications ?? this.notifications,
    );
  }
}
