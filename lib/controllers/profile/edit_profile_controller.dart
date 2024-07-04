import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/interests/requests/user_interests_update_model.dart';
import 'package:zipbuzz/models/user/requests/user_details_request_model.dart';
import 'package:zipbuzz/models/user/requests/user_details_update_request_model.dart';
import 'package:zipbuzz/models/user/user_model.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/services/location_services.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/widgets/loader.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';

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
  InterestViewType interestViewType = InterestViewType.user;

  void updateImage(File? updatedImage) {
    image = updatedImage;
  }

  void updateUserClone() {
    userClone = ref.read(userProvider).getClone();
  }

  void updateInterest(String interest) {
    if (userClone.interests.contains(interest)) {
      userClone.interests.remove(interest);
      return;
    }
    userClone.interests.add(interest);
  }

  void toggleInterestView() {
    interestViewType =
        interestViewType == InterestViewType.user ? InterestViewType.all : InterestViewType.user;
  }

  bool validateLocationCheck() {
    if (userClone.interests.length < 3) {
      showSnackBar(message: "Please select at least 3 interests");
      return false;
    }
    return true;
  }

  bool validate() {
    if (mobileController.text.isEmpty) {
      showSnackBar(message: "Please enter mobile number");
      return false;
    }
    if (mobileController.text.length != 10) {
      showSnackBar(message: "Please enter valid mobile number");
      return false;
    }
    if (userClone.interests.length < 3) {
      showSnackBar(message: "Please select at least 3 interests");
      return false;
    }
    return true;
  }

  Future<bool> checkPhone() async {
    final mobileNumber = mobileController.text.trim();
    if (ref.read(userProvider).mobileNumber == mobileNumber) {
      return true;
    }
    return !(await ref.read(dioServicesProvider).checkPhone(mobileNumber));
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
      if (zipcodeController.text.trim().length < 5) {
        zipcodeController.text = 95050.toString();
      }
      final newMobileNumber = await checkPhone();
      if (!newMobileNumber) {
        showSnackBar(
          message: "Mobile number already in use. Please use another number.",
          duration: 2,
        );
        return;
      }
      if (ref.read(userProvider).zipcode != zipcodeController.text.trim()) {
        ref.read(loadingTextProvider.notifier).updateLoadingText("Updating Location..");
        await ref
            .read(userLocationProvider.notifier)
            .getLocationFromZipcode(zipcodeController.text.trim());
      }

      var profileUrl = ref.read(userProvider).imageUrl;

      if (image != null) {
        ref.read(loadingTextProvider.notifier).updateLoadingText("Uploading profile pic...");
        profileUrl = await ref.read(dioServicesProvider).postUserImage(image!);
      }
      final updatedLocation = ref.read(userLocationProvider);
      final updatedUser = ref.read(userProvider).copyWith(
            name: nameController.text.trim(),
            about: aboutController.text.trim(),
            imageUrl: profileUrl,
            mobileNumber: mobileController.text.trim(),
            handle: handleController.text.trim(),
            linkedinId: linkedinIdControler.text.trim(),
            instagramId: instagramIdController.text.trim(),
            twitterId: twitterIdController.text.trim(),
            interests: userClone.interests,
            zipcode: updatedLocation.zipcode,
          );

      final userDetailsUpdateRequestModel = UserDetailsUpdateRequestModel(
        id: updatedUser.id,
        phoneNumber: updatedUser.mobileNumber,
        profilePicture: updatedUser.imageUrl,
        zipcode: updatedUser.zipcode,
        email: updatedUser.email,
        description: updatedUser.about,
        username: updatedUser.name,
        isAmbassador: updatedUser.isAmbassador,
        instagram: updatedUser.instagramId ?? "",
        linkedin: updatedUser.linkedinId ?? "",
        twitter: updatedUser.twitterId ?? "",
        interests: updatedUser.interests,
        notifictaionCount: updatedUser.notificationCount,
      );
      await ref.read(dioServicesProvider).updateUserInterests(
            UserInterestsUpdateModel(userId: updatedUser.id, interests: updatedUser.interests),
          );
      ref.read(loadingTextProvider.notifier).updateLoadingText("Updating user data...");
      await ref.read(dbServicesProvider).updateUser(userDetailsUpdateRequestModel);
      await ref
          .read(dbServicesProvider)
          .getUserData(UserDetailsRequestModel(userId: updatedUser.id));

      ref.read(loadingTextProvider.notifier).updateLoadingText("Getting new events...");
      await ref.read(eventsControllerProvider.notifier).fetchEvents();
      ref.read(loadingTextProvider.notifier).reset();
      showSnackBar(message: "Updated successfully");
      image = null;
    } catch (e) {
      debugPrint("Error updating user: $e");
      showSnackBar(message: "Error updating user, try later..");
    }
    interestViewType = InterestViewType.user;
  }

  Future<void> resetNotificationCount() async {
    final user = ref.read(userProvider);
    final userDetailsUpdateRequestModel = UserDetailsUpdateRequestModel(
      id: user.id,
      phoneNumber: user.mobileNumber,
      profilePicture: user.imageUrl,
      zipcode: user.zipcode,
      email: user.email,
      description: user.about,
      username: user.name,
      isAmbassador: user.isAmbassador,
      instagram: user.instagramId ?? "",
      linkedin: user.linkedinId ?? "",
      twitter: user.twitterId ?? "",
      interests: user.interests,
      notifictaionCount: user.notificationCount,
    );
    await ref.read(dbServicesProvider).updateUser(userDetailsUpdateRequestModel);
  }
}
