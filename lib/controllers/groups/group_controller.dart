import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/services/image_picker.dart';
import 'package:zipbuzz/utils/tabs.dart';

final groupControllerProvider = StateNotifierProvider<GroupController, GroupState>((ref) {
  return GroupController();
});

class GroupController extends StateNotifier<GroupState> {
  GroupController() : super(GroupState());

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  void changeTab(GroupTab tab) {
    state = state.copyWith(currentTab: tab);
  }

  void toggleCreatingGroup() {
    state = state.copyWith(creatingGroup: !state.creatingGroup);
  }

  Future<void> selectProfileImage() async {
    final image = await ImageServices().pickImage();
    if (image != null) {
      state = state.copyWith(profileImage: File(image.path));
    }
  }

  Future<void> selectBannerImage() async {
    final image = await ImageServices().pickImage();
    if (image != null) {
      state = state.copyWith(bannerImage: File(image.path));
    }
  }

  void updateGroupVisibility(bool isPrivate) {
    state = state.copyWith(privateGroup: isPrivate);
  }
}

class GroupState {
  final GroupTab currentTab;
  final bool creatingGroup;
  final File? profileImage;
  final File? bannerImage;
  final bool privateGroup;
  GroupState({
    this.currentTab = GroupTab.all,
    this.creatingGroup = false,
    this.profileImage,
    this.bannerImage,
    this.privateGroup = false,
  });

  GroupState copyWith({
    GroupTab? currentTab,
    bool? creatingGroup,
    File? profileImage,
    File? bannerImage,
    bool? privateGroup,
  }) {
    return GroupState(
      currentTab: currentTab ?? this.currentTab,
      creatingGroup: creatingGroup ?? this.creatingGroup,
      profileImage: profileImage ?? this.profileImage,
      bannerImage: bannerImage ?? this.bannerImage,
      privateGroup: privateGroup ?? this.privateGroup,
    );
  }
}
