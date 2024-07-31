import 'package:flutter_riverpod/flutter_riverpod.dart';

final groupControllerProvider = StateNotifierProvider<GroupController, GroupState>((ref) {
  return GroupController();
});

class GroupController extends StateNotifier<GroupState> {
  GroupController() : super(GroupState());
}

class GroupState {
  
}

