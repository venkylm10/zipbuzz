import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/utils/tabs.dart';

final groupControllerProvider = StateNotifierProvider<GroupController, GroupState>((ref) {
  return GroupController();
});

class GroupController extends StateNotifier<GroupState> {
  GroupController() : super(GroupState());

  void changeTab(GroupTab tab) {
    state = state.copyWith(currentTab: tab);
  }
}

class GroupState {
  final GroupTab currentTab;
  GroupState({this.currentTab = GroupTab.all});

  GroupState copyWith({GroupTab? currentTab}) {
    return GroupState(currentTab: currentTab ?? this.currentTab);
  }
}
