import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/interests/requests/user_interests_update_model.dart';
import 'package:zipbuzz/models/location/location_model.dart';
import 'package:zipbuzz/models/user/requests/user_details_request_model.dart';
import 'package:zipbuzz/models/user/requests/user_details_update_request_model.dart';
import 'package:zipbuzz/models/user/requests/user_id_request_model.dart';
import 'package:zipbuzz/models/user/user_model.dart';
import 'package:zipbuzz/pages/home/home.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/services/location_services.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/widgets/loader.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';

final personaliseControllerProvider =
    StateNotifierProvider<PersonoliseControllerProvider, PersonaliseController>(
        (ref) => PersonoliseControllerProvider(ref: ref));

class PersonoliseControllerProvider extends StateNotifier<PersonaliseController> {
  PersonoliseControllerProvider({required Ref ref}) : super(PersonaliseController(ref: ref));
}

class PersonaliseController {
  final Ref ref;
  PersonaliseController({required this.ref}) {
    emailController.text = ref.read(userProvider).email;
  }
  final box = GetStorage();
  final zipcodeController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final nameController = TextEditingController();
  var countryDialCode = "1";
  var selectedInterests = <String>['Hangouts'];
  var userLocation = LocationModel(
    city: "",
    country: "",
    countryDialCode: "",
    zipcode: "",
    neighborhood: "-",
  );

  var showMobileNumber = false;
  var showEmailId = false;

  void updateMobileNumber(String number) {
    mobileController.text = number;
  }

  void updateShowMobile(bool val) {
    showMobileNumber = val;
  }

  void updateShowEmailId(bool val) {
    showEmailId = val;
  }

  void clearFields() async {
    selectedInterests.clear();
    userLocation = ref.read(userLocationProvider);
    emailController.text = ref.read(userProvider).email;
  }

  Future<void> initialiseLoggedInUser() async {
    ref.read(loadingTextProvider.notifier).reset();
    final user = ref.read(userProvider);

    if (user.email != 'null@zipbuzz.com') {
      emailController.text = user.email;
    } else {
      emailController.text = "";
    }

    if (user.mobileNumber != 'zipbuzz-null' && user.mobileNumber != '+11234567890') {
      mobileController.text = user.mobileNumber.substring(user.mobileNumber.length - 10);
      var temp = user.mobileNumber.substring(0, user.mobileNumber.length - 10);
      if (temp[0] == '+') {
        countryDialCode = temp.substring(1);
      } else {
        countryDialCode = temp;
      }
    } else {
      mobileController.text = "";
    }
    nameController.text = user.name;
    if (user.zipcode != 'zipbuzz-null') {
      zipcodeController.text = user.zipcode;
    } else {
      zipcodeController.text = "95050";
    }
    selectedInterests.clear();
    selectedInterests.addAll(user.interests);
  }

  void updateCountryCode(String code) {
    countryDialCode = code;
  }

  void updateInterests(String interest) {
    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
    // showSnackBar(message: "$selectedInterests");
  }

  Future<bool> validate() async {
    if (mobileController.text.isEmpty) {
      showSnackBar(message: "Please enter mobile number");
      return false;
    }
    if (mobileController.text.length != 10 ||
        mobileController.text.contains(RegExp(r'[a-zA-Z]')) ||
        mobileController.text == '1234567890') {
      showSnackBar(message: "Please enter valid mobile number");
      return false;
    }
    if (emailController.text.isEmpty) {
      showSnackBar(message: "Please enter email");
      return false;
    } else if (await newEmail()) {
      showSnackBar(message: "Email already in use. Please use another email.");
      return false;
    }
    if (selectedInterests.isEmpty) {
      showSnackBar(message: "Please select at least one interest");
      return false;
    }
    return true;
  }

  Future<bool> newEmail() async {
    final currentEmail = ref.read(userProvider).email;
    final email = emailController.text.trim();
    if (currentEmail == email) {
      return false;
    }
    final token = await FirebaseMessaging.instance.getToken() ?? 'zipbuzz-null';
    final id = await ref
        .read(dioServicesProvider)
        .getUserId(UserIdRequestModel(email: email, deviceToken: token));
    return id != null;
  }

  Future<bool> newPhone() async {
    final currentNumber = ref.read(userProvider).mobileNumber;
    final mobileNumber = "$countryDialCode${mobileController.text.trim()}";
    if (currentNumber == mobileNumber) {
      return true;
    }
    return !(await ref.read(dioServicesProvider).checkPhone(mobileNumber));
  }

  void sumbitInterests() async {
    final check = await validate();
    if (check) {
      if (zipcodeController.text.trim().isEmpty) {
        zipcodeController.text = 95050.toString();
      }
      final newUser = await newPhone();
      if (!newUser) {
        showSnackBar(
          message: "Mobile number already in use. Please use another number.",
          duration: 2,
        );
        return;
      }
      try {
        await ref
            .read(userLocationProvider.notifier)
            .getLocationFromZipcode(zipcodeController.text.trim());
        final localUid = ref.read(userProvider).email.split("@").first;
        final currentUser = FirebaseAuth.instance.currentUser;
        UserModel updatedUser;
        if (currentUser != null) {
          updatedUser = ref.read(userProvider).copyWith(
                name: localUid == currentUser.uid ? nameController.text.trim() : null,
                email: emailController.text.trim(),
                zipcode: zipcodeController.text.trim(),
                mobileNumber: "+$countryDialCode${mobileController.text.trim()}",
                interests: selectedInterests,
              );
        } else {
          updatedUser = ref.read(userProvider).copyWith(
                name: nameController.text.trim(),
                email: emailController.text.trim(),
                zipcode: zipcodeController.text.trim(),
                mobileNumber: "+$countryDialCode${mobileController.text.trim()}",
                interests: selectedInterests,
              );
        }
        box.write(BoxConstants.countryDialCode, countryDialCode);
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
              UserInterestsUpdateModel(userId: updatedUser.id, interests: selectedInterests),
            );
        ref.read(loadingTextProvider.notifier).updateLoadingText("Updating user data...");
        await ref.read(dbServicesProvider).updateUser(userDetailsUpdateRequestModel);

        // Reading id after id is being updated in createUser method
        final id = GetStorage().read(BoxConstants.id);

        // posting users interests
        ref.read(loadingTextProvider.notifier).updateLoadingText("Personalising the app...");
        box.write('user_interests', selectedInterests);

        // showSnackBar(message: "2 $selectedInterests");
        final requestModel = UserDetailsRequestModel(userId: id);
        await ref.read(dbServicesProvider).getOwnUserData(requestModel);
        debugPrint("UPDATED USER DATA SUCCESSFULLY");
        final user = ref.read(userProvider);
        ref.read(newEventProvider.notifier).updateHostId(id);
        ref.read(newEventProvider.notifier).updateHostName(user.name);
        ref.read(newEventProvider.notifier).updateHostPic(user.imageUrl);
        await ref.read(eventsControllerProvider.notifier).fetchEvents();
        ref.read(loadingTextProvider.notifier).reset();
        navigatorKey.currentState!.pushNamedAndRemoveUntil(Home.id, (route) => false);
      } catch (e) {
        ref.read(loadingTextProvider.notifier).reset();
        debugPrint("Error updating user in personalise page: $e");
      }
    }
  }

  void clearController() {
    emailController.clear();
    mobileController.clear();
    nameController.clear();
    zipcodeController.clear();
    selectedInterests.clear();
    selectedInterests.add('Hangouts');
  }
}
