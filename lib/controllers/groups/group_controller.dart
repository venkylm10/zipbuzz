import 'dart:async';
import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:zipbuzz/controllers/navigation_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/groups/group_member_model.dart';
import 'package:zipbuzz/models/groups/group_model.dart';
import 'package:zipbuzz/models/groups/post/accept_group_model.dart';
import 'package:zipbuzz/models/groups/post/edit_group_model.dart';
import 'package:zipbuzz/models/groups/post/invite_group_member_model.dart';
import 'package:zipbuzz/models/groups/post/create_group_model.dart';
import 'package:zipbuzz/models/groups/res/description_model.dart';
import 'package:zipbuzz/models/groups/res/group_description_res.dart';
import 'package:zipbuzz/pages/groups/add_group_members.dart';
import 'package:zipbuzz/pages/home/home.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/services/image_picker.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
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
  final contactSearchController = TextEditingController();
  List<Contact> allContacts = [];

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
    final image =
        await ImageServices().pickImage(aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1));
    if (image != null) {
      state = state.copyWith(
        profileImage: File(image.path),
        bannerImage: state.bannerImage,
      );
    }
  }

  void pickBannerImage() async {
    final image =
        await ImageServices().pickImage(aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9));
    if (image != null) {
      state = state.copyWith(
        bannerImage: File(image.path),
        profileImage: state.profileImage,
      );
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
      final groupId = await ref.read(dbServicesProvider).createGroup(model);
      await fetchCommunityAndGroupDescriptions();
      final desc = state.currentGroups.firstWhere((e) => e.id == groupId);
      state = state.copyWith(
        currentGroupDescription: GroupDescriptionModel(
            id: desc.id, groupName: desc.name, groupDescription: desc.description),
      );
      await getGroupMembers();
      updateLoading(false);
      toggleCreatingGroup();
      navigatorKey.currentState!.push(
        NavigationController.getTransition(const AddGroupMembers()),
      );
      showSnackBar(message: "Group created successfully");
    } catch (e) {
      updateLoading(false);
      showSnackBar(message: "Failed to create group");
    }
  }

  void updateGroup() async {
    try {
      final currentGroup = state.currentGroup!;
      updateLoading(true);
      final name = nameController.text;
      final description = descriptionController.text;
      if (name.isEmpty || description.isEmpty) {
        updateLoading(false);
        showSnackBar(message: "Please fill all fields");
        return;
      }
      String image = state.currentGroup!.image;
      String banner = state.currentGroup!.banner;
      if (state.profileImage != null) {
        final url =
            await ref.read(dioServicesProvider).uploadInvidualGroupImage(state.profileImage!);
        image = url ?? image;
      }
      if (state.bannerImage != null) {
        final url = await ref
            .read(dioServicesProvider)
            .uploadInvidualGroupImage(state.bannerImage!, profileImage: false);
        banner = url ?? image;
      }
      final user = ref.read(userProvider);
      final model = EditGroupModel(
        userId: user.id,
        groupId: currentGroup.id,
        name: name,
        description: description,
        banner: banner,
        image: image,
        listed: currentGroup.listed,
      );
      await ref.read(dioServicesProvider).updateGroup(model);
      await fetchCommunityAndGroupDescriptions();
      final desc = state.currentGroups.firstWhere((e) => e.id == currentGroup.id);
      state = state.copyWith(
        currentGroupDescription: GroupDescriptionModel(
          id: desc.id,
          groupName: desc.name,
          groupDescription: desc.description,
        ),
        currentGroup: currentGroup.copyWith(
          name: name,
          description: description,
          image: image,
          banner: banner,
          listed: model.listed,
        ),
      );
      await getGroupMembers();
      updateLoading(false);
      state = state.copyWith(
        removingFiles: true,
        profileImage: null,
        bannerImage: null,
      );
      navigatorKey.currentState!.pop();
      showSnackBar(message: "Group updated successfully");
    } catch (e) {
      updateLoading(false);
      showSnackBar(message: "Failed to update group");
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

  Future<void> getGroupDetails() async {
    state = state.copyWith(loading: true);
    try {
      final group = await ref
          .read(dioServicesProvider)
          .getGroupDetails(ref.read(userProvider).id, state.currentGroupDescription!.id);
      state = state.copyWith(currentGroup: group);
      state = state.copyWith(loading: false);
    } catch (e) {
      showSnackBar(message: "Something went wrong while fetching group details");
      debugPrint(e.toString());
      state = state.copyWith(loading: false);
    }
  }

  Future<void> getGroupMembers() async {
    state = state.copyWith(fetchingMembers: true);
    try {
      final res =
          await ref.read(dioServicesProvider).getGroupMembers(state.currentGroupDescription!.id);
      final user = ref.read(userProvider);
      final admin = res.admins.any((e) => e.userId == user.id);
      state = state.copyWith(
        admins: res.admins,
        members: res.members,
        isAdmin: admin,
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

  Future<void> archiveGroup() async {
    try {
      updateLoading(true);
      final user = ref.read(userProvider);
      await ref.read(dioServicesProvider).archiveGroup(user.id, state.currentGroupDescription!.id);
      state = state.copyWith(
        currentGroups:
            state.currentGroups.where((e) => e.id != state.currentGroupDescription!.id).toList(),
      );
      updateLoading(false);
      navigatorKey.currentState!.pushNamedAndRemoveUntil(Home.id, (_) => false);
      showSnackBar(message: "Archived Group : ${state.currentGroupDescription!.groupName}");
      await Future.delayed(const Duration(seconds: 1));
      fetchCommunityAndGroupDescriptions();
      resetController();
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar(
          message:
              "Something went wrong while archiving ${state.currentGroupDescription!.groupName}");
    }
    updateLoading(false);
  }

  // Edit Group
  void initEditGroup(GroupModel group) {
    nameController.text = group.name;
    descriptionController.text = group.description;
    state = state.copyWith(
      privateGroup: !group.listed,
    );
  }

  void resetController() {
    nameController.clear();
    descriptionController.clear();
    state = state.copyWith(
      loading: false,
      creatingGroup: false,
      privateGroup: true,
      admins: [],
      members: [],
      isAdmin: false,
    );
    state = state.copyWith(
      removingFiles: true,
      profileImage: null,
      bannerImage: null,
    );
  }

  // Contacts
  void updateAllContacts(List<Contact> contacts) {
    allContacts = contacts;
    state = state.copyWith(contactSearchResult: allContacts);
  }

  Timer? _debounce;

  void updateContactSearchResult(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      _searchForContacts(query);
    });
  }

  void resetContactSearchResult() {
    state = state.copyWith(contactSearchResult: allContacts);
  }

  bool _contactInSearch(Contact element, String query) {
    var name = (element.displayName ?? "").toLowerCase().contains(query);
    var number = false;
    if (element.phones!.isNotEmpty) {
      number = element.phones!.any((e) {
        final phone = e.value!.replaceAll(RegExp(r'[\s()-]+'), "").replaceAll(" ", "");
        if (phone.length > 10) {
          return phone.substring(phone.length - 10).contains(query);
        }
        return phone.contains(query);
      });
    }
    return name || number;
  }

  void _searchForContacts(String query) {
    query = query.toLowerCase().trim();
    final contactSearchResult = allContacts.where(
      (element) {
        return _contactInSearch(element, query);
      },
    ).toList();
    final selectedContactsSearchResult = state.selectedContacts.where(
      (element) {
        return _contactInSearch(element, query);
      },
    ).toList();
    state = state.copyWith(
      contactSearchResult: contactSearchResult,
      selectedContactsSearchResult: selectedContactsSearchResult,
    );
  }

  void toggleSelectedContact(Contact contact) {
    var contacts = [...state.selectedContacts];
    var search = [...state.selectedContactsSearchResult];
    if (contacts.contains(contact)) {
      contacts.remove(contact);
      search.remove(contact);
    } else {
      contacts.add(contact);
      search.add(contact);
    }
    state = state.copyWith(
      selectedContacts: contacts,
      selectedContactsSearchResult: search,
    );
  }

  void inviteMembersToGroup() async {
    state = state.copyWith(invitingMembers: true);
    try {
      List<InviteGroupMemberModel> members = [];
      final userNumber = ref.read(userProvider).mobileNumber;
      final countryDialCode = userNumber.substring(0, userNumber.length - 10);
      for (var e in state.selectedContacts) {
        final user = ref.read(userProvider);
        var number = e.phones!.first.value!.replaceAll(RegExp(r'[\s()-]+'), "").replaceAll(" ", "");
        (" ", "");
        final code = number.substring(0, number.length - 10);
        if (number.length == 10) {
          number = countryDialCode + number;
        } else if (number.length > 10 && !number.startsWith("+")) {
          number = number.substring(number.length - 10);
          number = "+$code$number";
        }
        final member = InviteGroupMemberModel(
          groupId: state.currentGroupDescription!.id,
          userId: user.id,
          title: state.currentGroupDescription!.groupName,
          phoneNumber: number,
          invitingUserName: user.name,
        );
        members.add(member);
        await ref.read(dioServicesProvider).inviteToGroup(member);
      }
      state = state.copyWith(invitingMembers: false);
      navigatorKey.currentState!.pop();
    } catch (e) {
      debugPrint(e.toString());
    }
    state = state.copyWith(invitingMembers: false);
  }

  Future<void> acceptInvite(AcceptGroupModel model) async {
    await ref.read(dioServicesProvider).acceptGroup(model);
  }

  Future<void> updateGroupMemberStatus(int userId, String permissionType) async {
    try {
      return await ref.read(dioServicesProvider).updateGroupMember(
            userId,
            state.currentGroupDescription!.id,
            permissionType,
          );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteGroupMember(int userId) async {
    try {
      final isAdmin = state.admins.any((e) => e.userId == userId);
      await ref
          .read(dioServicesProvider)
          .deleteGroupMember(userId, state.currentGroupDescription!.id);
      state = state.copyWith(
        members: !isAdmin ? state.members.where((e) => e.userId != userId).toList() : null,
        admins: isAdmin ? state.admins.where((e) => e.userId != userId).toList() : null,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void clearSelectedContacts() {
    state = state.copyWith(selectedContacts: []);
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
  final List<Contact> selectedContacts;
  final List<Contact> contactSearchResult;
  final List<Contact> selectedContactsSearchResult;
  final bool invitingMembers;
  final GroupModel? currentGroup;
  GroupState({
    this.loading = false,
    this.groupEventsTab = GroupEventsTab.upcoming,
    this.currentTab = GroupTab.all,
    this.creatingGroup = false,
    this.profileImage,
    this.bannerImage,
    this.privateGroup = true,
    this.currentGroupDescription,
    this.fetchingList = false,
    this.currentGroups = const [],
    this.currentCommunities = const [],
    this.fetchingMembers = false,
    this.admins = const [],
    this.members = const [],
    this.currentGroupMember,
    this.isAdmin = false,
    this.selectedContacts = const [],
    this.contactSearchResult = const [],
    this.selectedContactsSearchResult = const [],
    this.invitingMembers = false,
    this.currentGroup,
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
    List<Contact>? selectedContacts,
    List<Contact>? contactSearchResult,
    List<Contact>? selectedContactsSearchResult,
    bool? invitingMembers,
    GroupModel? currentGroup,
    bool removingFiles = false,
  }) {
    return GroupState(
      loading: loading ?? this.loading,
      groupEventsTab: groupEventsTab ?? this.groupEventsTab,
      currentTab: currentTab ?? this.currentTab,
      creatingGroup: creatingGroup ?? this.creatingGroup,
      profileImage: removingFiles ? profileImage : profileImage ?? this.profileImage,
      bannerImage: removingFiles ? bannerImage : bannerImage ?? this.bannerImage,
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
      selectedContacts: selectedContacts ?? this.selectedContacts,
      contactSearchResult: contactSearchResult ?? this.contactSearchResult,
      invitingMembers: invitingMembers ?? this.invitingMembers,
      selectedContactsSearchResult:
          selectedContactsSearchResult ?? this.selectedContactsSearchResult,
      currentGroup: currentGroup ?? this.currentGroup,
    );
  }
}
