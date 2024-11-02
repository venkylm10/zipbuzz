import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:zipbuzz/controllers/navigation_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/community/post/add_community_model.dart';
import 'package:zipbuzz/models/community/res/community_details_model.dart';
import 'package:zipbuzz/models/groups/res/community_and_group_res.dart';
import 'package:zipbuzz/models/groups/res/description_model.dart';
import 'package:zipbuzz/pages/groups/add_group_or_community_members.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/services/image_picker.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';

final communityControllerProvider = StateNotifierProvider<CommunityController, CommunityState>(
    (ref) => CommunityController(ref: ref));

class CommunityController extends StateNotifier<CommunityState> {
  final Ref ref;
  CommunityController({required this.ref}) : super(const CommunityState());

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  void toggleCreatingCommunity() {
    state = state.copyWith(creatingCommunity: !state.creatingCommunity);
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

  Future<void> createCommunity() async {
    state = state.copyWith(loading: true);
    try {
      final image = await ref.read(dioServicesProvider).addCommunityImage(state.profileImage!);
      final banner = await ref.read(dioServicesProvider).addCommunityBanner(state.bannerImage!);
      final model = AddCommunityModel(
        communityName: nameController.text.trim(),
        communityDescription: descriptionController.text.trim(),
        communityImage: image,
        communityBanner: banner,
        userId: ref.read(userProvider).id,
      );
      await ref.read(dioServicesProvider).createCommunity(model);
      showSnackBar(message: "Community created successfully");
      navigatorKey.currentState!.push(
        NavigationController.getTransition(
          const AddGroupOrCommunityMembers(isCommunity: true),
        ),
      );
      nameController.clear();
      descriptionController.clear();
      state = state.copyWith(
        loading: false,
        creatingCommunity: false,
        removeFiles: true,
        profileImage: null,
        bannerImage: null,
      );
    } catch (e) {
      debugPrint("Error creating community: $e");
      showSnackBar(message: "Error creating community");
      state = state.copyWith(loading: false);
      return;
    }
  }

  void updateLoading(bool loading) {
    state = state.copyWith(loading: loading);
  }

  void updateCurrentDesc(DescriptionModel model) {
    state = state.copyWith(currentCommunityDescription: model);
  }

  Future<void> getCommunityDetails(int communityId) async {
    try {
      state = state.copyWith(loading: true);
      final community = await ref
          .read(dioServicesProvider)
          .getCommunityDetails(ref.read(userProvider).id, communityId);
      state = state.copyWith(currentCommunity: community);
    } catch (e) {
      debugPrint("Error getting community details: $e");
      showSnackBar(message: "Error getting community details");
    }
    state = state.copyWith(loading: false);
  }
}

class CommunityState {
  final bool creatingCommunity;
  final File? profileImage;
  final File? bannerImage;
  final bool loading;
  final CommunityDetailsModel? currentCommunity;
  final DescriptionModel? currentCommunityDescription;
  const CommunityState({
    this.loading = false,
    this.creatingCommunity = false,
    this.profileImage,
    this.bannerImage,
    this.currentCommunity,
    this.currentCommunityDescription,
  });

  CommunityState copyWith({
    bool? creatingCommunity,
    File? profileImage,
    File? bannerImage,
    bool? loading,
    CommunityDetailsModel? currentCommunity,
    DescriptionModel? currentCommunityDescription,
    bool removeFiles = false,
  }) {
    return CommunityState(
      creatingCommunity: creatingCommunity ?? this.creatingCommunity,
      profileImage: removeFiles ? profileImage : profileImage ?? this.profileImage,
      bannerImage: removeFiles ? bannerImage : bannerImage ?? this.bannerImage,
      loading: loading ?? this.loading,
      currentCommunity: currentCommunity ?? this.currentCommunity,
      currentCommunityDescription: currentCommunityDescription ?? this.currentCommunityDescription,
    );
  }
}
