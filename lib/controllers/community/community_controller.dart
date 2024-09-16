import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:zipbuzz/services/image_picker.dart';

final communityControllerProvider =
    StateNotifierProvider<CommunityController, CommunityState>((ref) => CommunityController());

class CommunityController extends StateNotifier<CommunityState> {
  CommunityController() : super(const CommunityState());

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
}

class CommunityState {
  final bool creatingCommunity;
  final File? profileImage;
  final File? bannerImage;
  final bool loading;
  const CommunityState({
    this.loading = false,
    this.creatingCommunity = false,
    this.profileImage,
    this.bannerImage,
  });

  CommunityState removeFiles() {
    return CommunityState(
      creatingCommunity: creatingCommunity,
      profileImage: null,
      bannerImage: null,
    );
  }

  CommunityState copyWith({
    bool? creatingCommunity,
    File? profileImage,
    File? bannerImage,
    bool? loading,
    bool removeFiles = false,
  }) {
    return CommunityState(
      creatingCommunity: creatingCommunity ?? this.creatingCommunity,
      profileImage: removeFiles ? profileImage : profileImage ?? this.profileImage,
      bannerImage: removeFiles ? bannerImage : bannerImage ?? this.bannerImage,
    );
  }
}
