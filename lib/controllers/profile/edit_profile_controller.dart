import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/user_model/user_model.dart';
import 'package:zipbuzz/services/location_services.dart';
import 'package:zipbuzz/services/storage_services.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

final editEventControllerProvider = StateProvider((ref) => EditProfileController(ref: ref));

class EditProfileController {
  final Ref ref;
  late UserModel userClone;
  EditProfileController({required this.ref}) {
    userClone = ref.read(userProvider).getClone();
    nameController.text = userClone.name;
    aboutController.text = userClone.about;
    zipcodeController.text = userClone.zipcode;
    mobileController.text = userClone.mobileNumber;
    handleController.text = userClone.handle;
    linkedinIdControler.text = userClone.linkedinId ?? "";
    instagramIdController.text = userClone.instagramId ?? "";
    twitterIdController.text = userClone.twitterId ?? "";
  }
  TextEditingController nameController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  TextEditingController zipcodeController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController handleController = TextEditingController();
  TextEditingController linkedinIdControler = TextEditingController();
  TextEditingController instagramIdController = TextEditingController();
  TextEditingController twitterIdController = TextEditingController();
  File? image;

  void updateImage(File? updatedImage) {
    image = updatedImage;
  }

  void updateInterest(String interest) {
    if (userClone.interests.contains(interest)) {
      userClone.interests.remove(interest);
      return;
    }
    userClone.interests.add(interest);
  }

  Future<void> saveChanges() async {
    debugPrint("updating user");
    try {
      await ref.read(userLocationProvider.notifier).updatestateFromZipcode(zipcodeController.text.trim());
      String? newImageUrl;
      if (image != null) {
        newImageUrl =
            await ref.read(storageServicesProvider).uploadProfilePic(uid: userClone.id.toString(), file: image!);
      }

      final updatedUser = ref.read(userProvider).copyWith(
            name: nameController.text.trim(),
            about: aboutController.text.trim(),
            mobileNumber: mobileController.text.trim(),
            imageUrl: newImageUrl,
            handle: handleController.text.trim(),
            linkedinId: linkedinIdControler.text.trim(),
            instagramId: instagramIdController.text.trim(),
            twitterId: twitterIdController.text.trim(),
            interests: userClone.interests,
          );

      // TODO: UPDATE USER
      // await ref
      //     .read(dbServicesProvider)
      //     .updateUser(updatedUser.id, updatedUser.toMap());
      ref.read(userProvider.notifier).update((state) => updatedUser);
      navigatorKey.currentState!.pop();
      showSnackBar(message: "Updated successfully");
    } catch (e) {
      debugPrint("Error updating user: $e");
      showSnackBar(message: "Error updating user, try later..");
    }
  }
}
