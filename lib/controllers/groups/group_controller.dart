import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/groups/group_member_model.dart';
import 'package:zipbuzz/models/groups/post/create_group_model.dart';
import 'package:zipbuzz/models/groups/res/description_model.dart';
import 'package:zipbuzz/models/groups/res/group_description_res.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/services/image_picker.dart';
import 'package:zipbuzz/utils/tabs.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';

final groupControllerProvider = StateNotifierProvider<GroupController, GroupState>((ref) {
  return GroupController(ref: ref);
});

class GroupController extends StateNotifier<GroupState> {
  GroupController({required this.ref}) : super(GroupState());

  final Ref ref;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  void changeGroupEventsTab(GroupEventsTab tab) {
    state = state.copyWith(groupEventsTab: tab);
  }

  void changeCurrentTab(GroupTab tab) {
    state = state.copyWith(currentTab: tab);
  }

  void toggleCreatingGroup() {
    state = state.copyWith(creatingGroup: !state.creatingGroup);
  }

  void updateGroupVisibility(bool isPrivate) {
    state = state.copyWith(privateGroup: isPrivate);
  }

  void updateLoading(bool loading) {
    state = state.copyWith(loading: loading);
  }

  void pickProfileImage() async {
    final image = await ImageServices().pickImage(aspectRatios: [CropAspectRatioPreset.square]);
    if (image != null) {
      state = state.copyWith(profileImage: File(image.path));
    }
  }

  void pickBannerImage() async {
    final image = await ImageServices().pickImage(aspectRatios: [CropAspectRatioPreset.ratio16x9]);
    if (image != null) {
      state = state.copyWith(bannerImage: File(image.path));
    }
  }

  void createGroup() async {
    try {
      updateLoading(true);
      final name = nameController.text;
      final description = descriptionController.text;
      if (name.isEmpty || description.isEmpty) {
        updateLoading(false);
        showSnackBar(message: "Please fill all fields");
        return;
      }
      if (state.profileImage == null || state.bannerImage == null) {
        updateLoading(false);
        showSnackBar(message: "Please add profile and banner image");
        return;
      }
      final urls = await ref
          .read(dioServicesProvider)
          .addGroupImages(state.profileImage!, state.bannerImage!);
      final user = ref.read(userProvider);
      final model = CreateGroupModel(
        userId: user.id,
        groupName: name,
        groupDescription: description,
        groupImage: urls['group_image_url'] ?? 'zipbuzz-null',
        groupBanner: urls['group_banner_url'] ?? 'zipbuzz-null',
        groupListed: !state.privateGroup,
      );
      await ref.read(dbServicesProvider).createGroup(model);
      toggleCreatingGroup();
      await fetchCommunityAndGroupDescriptions();
      updateLoading(false);
      showSnackBar(message: "Group created successfully");
    } catch (e) {
      updateLoading(false);
      showSnackBar(message: "Failed to create group");
    }
  }

  void updateCurrentGroupDescription(GroupDescriptionModel groupDescription) {
    state = state.copyWith(currentGroupDescription: groupDescription);
  }

  Future<void> fetchCommunityAndGroupDescriptions() async {
    state = state.copyWith(fetchingList: true);
    try {
      final user = ref.read(userProvider);
      final res = await ref.read(dioServicesProvider).getCommunityAndGroupsDescriptions(user.id);
      state = state.copyWith(
        currentGroups: res.groups,
        currentCommunities: res.communities,
      );
    } catch (e) {
      debugPrint("ERROR FETCHING GROUPS AND COMMUNITIES DESCRIPTIONS: $e");
      showSnackBar(message: "Error fetching groups and communities");
    }
    state = state.copyWith(fetchingList: false);
  }

  Future<void> getGroupMembers() async {
    state = state.copyWith(fetchingMembers: true);
    try {
      final res =
          await ref.read(dioServicesProvider).getGroupMembers(state.currentGroupDescription!.id);
      state = state.copyWith(
        admins: res.admins,
        members: res.members,
      );
    } catch (e) {
      debugPrint("ERROR FETCHING GROUP MEMBERS: $e");
      showSnackBar(message: "Error fetching group members");
    }
    state = state.copyWith(fetchingMembers: false);
  }

  void updateCurrentGroupMember(GroupMemberModel member, bool isAdmin) {
    state = state.copyWith(currentGroupMember: member, isAdmin: isAdmin);
  }
}

class GroupState {
  final bool loading;
  final GroupTab currentTab;
  final GroupEventsTab groupEventsTab;
  final bool creatingGroup;
  final File? profileImage;
  final File? bannerImage;
  final bool privateGroup;
  final GroupDescriptionModel? currentGroupDescription;
  final bool fetchingList;
  final List<DescriptionModel> currentGroups;
  final List<DescriptionModel> currentCommunities;
  final bool fetchingMembers;
  final List<GroupMemberModel> admins;
  final List<GroupMemberModel> members;
  final GroupMemberModel? currentGroupMember;
  final bool isAdmin;
  GroupState({
    this.loading = false,
    this.groupEventsTab = GroupEventsTab.upcoming,
    this.currentTab = GroupTab.all,
    this.creatingGroup = false,
    this.profileImage,
    this.bannerImage,
    this.privateGroup = false,
    this.currentGroupDescription,
    this.fetchingList = false,
    this.currentGroups = const [],
    this.currentCommunities = const [],
    this.fetchingMembers = false,
    this.admins = const [],
    this.members = const [],
    this.currentGroupMember,
    this.isAdmin = false,
  });

  GroupState copyWith({
    bool? loading,
    GroupEventsTab? groupEventsTab,
    GroupTab? currentTab,
    bool? creatingGroup,
    File? profileImage,
    File? bannerImage,
    bool? privateGroup,
    GroupDescriptionModel? currentGroupDescription,
    bool? fetchingList,
    List<DescriptionModel>? currentGroups,
    List<DescriptionModel>? currentCommunities,
    bool? fetchingMembers,
    List<GroupMemberModel>? admins,
    List<GroupMemberModel>? members,
    GroupMemberModel? currentGroupMember,
    bool? isAdmin,
  }) {
    return GroupState(
      loading: loading ?? this.loading,
      groupEventsTab: groupEventsTab ?? this.groupEventsTab,
      currentTab: currentTab ?? this.currentTab,
      creatingGroup: creatingGroup ?? this.creatingGroup,
      profileImage: profileImage ?? this.profileImage,
      bannerImage: bannerImage ?? this.bannerImage,
      privateGroup: privateGroup ?? this.privateGroup,
      currentGroupDescription: currentGroupDescription ?? this.currentGroupDescription,
      fetchingList: fetchingList ?? this.fetchingList,
      currentGroups: currentGroups ?? this.currentGroups,
      currentCommunities: currentCommunities ?? this.currentCommunities,
      fetchingMembers: fetchingMembers ?? this.fetchingMembers,
      admins: admins ?? this.admins,
      members: members ?? this.members,
      currentGroupMember: currentGroupMember ?? this.currentGroupMember,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
