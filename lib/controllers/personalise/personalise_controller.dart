import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/interests/requests/user_interests_update_model.dart';
import 'package:zipbuzz/models/location/location_model.dart';
import 'package:zipbuzz/models/user/requests/user_details_request_model.dart';
import 'package:zipbuzz/models/user/requests/user_details_update_request_model.dart';
import 'package:zipbuzz/pages/home/home.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/services/location_services.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/widgets/common/loader.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

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
  var countryDialCode = "+1";
  var selectedInterests = <String>[];
  var userLocation = LocationModel(city: "", country: "", countryDialCode: "", zipcode: "");

  void initialise() async {
    userLocation = ref.read(userLocationProvider);
    emailController.text = ref.read(userProvider).email;
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
  }

  bool validate() {
    // if (!emailCheck()) {
    //   showSnackBar(message: "Please use own email, This will be used for further communication");
    //   return false;
    // }
    if (mobileController.text.isEmpty) {
      showSnackBar(message: "Please enter mobile number");
      return false;
    }
    if (mobileController.text.length != 10) {
      showSnackBar(message: "Please enter valid mobile number");
      return false;
    }
    if (selectedInterests.length < 3) {
      showSnackBar(message: "Please select at least 3 interests");
      return false;
    }
    return true;
  }

  bool emailCheck() {
    // Define the regular expression pattern
    RegExp emailPattern = RegExp(r'^[a-z]+\d+@zbuzz\.com$');

    // Check if the input text matches the pattern
    if (emailPattern.hasMatch(emailController.text.trim())) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> checkPhone() async {
    final mobileNumber = "$countryDialCode${mobileController.text.trim()}";
    return await ref.read(dioServicesProvider).checkPhone(mobileNumber);
  }

  void sumbitInterests() async {
    final check = validate();
    if (check) {
      if (zipcodeController.text.trim().isEmpty) {
        zipcodeController.text = 95050.toString();
      }
      final newUser = await checkPhone();
      if (!newUser) {
        showSnackBar(
          message: "Mobile number already in use. Please use another number.",
          duration: 2,
        );
        return;
      }
      try {
        var location = ref.read(userLocationProvider);
        if (location.zipcode != zipcodeController.text.trim()) {
          ref.read(loadingTextProvider.notifier).updateLoadingText("Udating your location...");
          await ref
              .read(userLocationProvider.notifier)
              .getLocationFromZipcode(zipcodeController.text.trim());
        }
        final localUid = ref.read(userProvider).email.split("@").first;
        final currentUser = FirebaseAuth.instance.currentUser!;

        location = ref.read(userLocationProvider);
        final updatedUser = ref.read(userProvider).copyWith(
              name: localUid == currentUser.uid ? nameController.text.trim() : null,
              email: emailController.text.trim(),
              zipcode: zipcodeController.text.trim(),
              mobileNumber: "$countryDialCode${mobileController.text.trim()}",
              interests: selectedInterests,
            );
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
        );
        await ref.read(dioServicesProvider).updateUserInterests(
              UserInterestsUpdateModel(userId: updatedUser.id, interests: updatedUser.interests),
            );
        ref.read(loadingTextProvider.notifier).updateLoadingText("Updating user data...");
        await ref.read(dbServicesProvider).updateUser(userDetailsUpdateRequestModel);

        // Reading id after id is being updated in createUser method
        final id = GetStorage().read(BoxConstants.id);

        // posting users interests
        ref.read(loadingTextProvider.notifier).updateLoadingText("Personalising the app...");
        box.write('user_interests', selectedInterests);
        final requestModel = UserDetailsRequestModel(userId: id);
        await ref.read(dbServicesProvider).getUserData(requestModel);
        debugPrint("UPDATED USER DATA SUCCESSFULLY");
        final user = ref.read(userProvider);
        ref.read(newEventProvider.notifier).updateHostId(id);
        ref.read(newEventProvider.notifier).updateHostName(user.name);
        ref.read(newEventProvider.notifier).updateHostPic(user.imageUrl);
        ref.read(loadingTextProvider.notifier).reset();
        navigatorKey.currentState!.pushNamedAndRemoveUntil(Home.id, (route) => false);
      } catch (e) {
        debugPrint("Error crearting user in personalise page: $e");
      }
    }
  }

  void clearController() {
    emailController.clear();
    mobileController.clear();
    nameController.clear();
    zipcodeController.clear();
    selectedInterests.clear();
  }
}
