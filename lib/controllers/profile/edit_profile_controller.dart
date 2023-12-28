import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/user/requests/user_details_request_model.dart';
import 'package:zipbuzz/models/user/requests/user_details_update_request_model.dart';
import 'package:zipbuzz/models/user/user_model.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/location_services.dart';
import 'package:zipbuzz/services/storage_services.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/widgets/common/loader.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

final editProfileControllerProvider =
    StateProvider.autoDispose((ref) => EditProfileController(ref: ref));

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
    ref.read(loadingTextProvider.notifier).reset();
    if (GetStorage().read(BoxConstants.guestUser) != null) {
      showSnackBar(message: "You need to be signed in to edit profile", duration: 2);
      await Future.delayed(const Duration(seconds: 2));
      navigatorKey.currentState!.pop();
      ref.read(newEventProvider.notifier).showSignInForm();
      return;
    }

    debugPrint("updating user");
    try {
      if (ref.read(userProvider).zipcode != zipcodeController.text.trim()) {
        ref.read(loadingTextProvider.notifier).updateLoadingText("Updating Location..");
        try {
          await ref
              .read(userLocationProvider.notifier)
              .getLocationFromZipcode(zipcodeController.text.trim());
        } catch (e) {
          debugPrint("Error updating location: $e");
        }
      }

      String? newImageUrl;
      if (image != null) {
        ref.read(loadingTextProvider.notifier).updateLoadingText("Uploading profile pic...");
        newImageUrl = await ref
            .read(storageServicesProvider)
            .uploadProfilePic(id: userClone.id, file: image!);
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

      final userDetailsUpdateRequestModel = UserDetailsUpdateRequestModel(
        id: updatedUser.id,
        phoneNumber: updatedUser.mobileNumber,
        zipcode: updatedUser.zipcode,
        email: updatedUser.email,
        profilePicture: updatedUser.imageUrl,
        description: updatedUser.about,
        username: updatedUser.name,
        isAmbassador: updatedUser.isAmbassador,
        instagram: updatedUser.instagramId ?? "",
        linkedin: updatedUser.linkedinId ?? "",
        twitter: updatedUser.twitterId ?? "",
      );
      ref.read(loadingTextProvider.notifier).updateLoadingText("Updating user data...");
      await ref.read(dbServicesProvider).updateUser(userDetailsUpdateRequestModel);
      await ref
          .read(dbServicesProvider)
          .getUserData(UserDetailsRequestModel(userId: updatedUser.id));

      ref.read(loadingTextProvider.notifier).updateLoadingText("Getting new events...");
      await ref.read(eventsControllerProvider).getUserEvents();
      ref.read(eventsControllerProvider).updateUpcomingEvents();
      ref.read(loadingTextProvider.notifier).reset();
      navigatorKey.currentState!.pop();
      showSnackBar(message: "Updated successfully");
    } catch (e) {
      debugPrint("Error updating user: $e");
      showSnackBar(message: "Error updating user, try later..");
    }
  }
}
