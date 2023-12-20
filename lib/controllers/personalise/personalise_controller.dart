import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/interests/posts/user_interests_post_model.dart';
import 'package:zipbuzz/models/location/location_model.dart';
import 'package:zipbuzz/models/user/user_model.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/firebase_providers.dart';
import 'package:zipbuzz/services/location_services.dart';
import 'package:zipbuzz/utils/constants/defaults.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

final personaliseControllerProvider =
    StateNotifierProvider<PersonoliseControllerProvider, PersonaliseController>(
        (ref) => PersonoliseControllerProvider(ref: ref));

class PersonoliseControllerProvider extends StateNotifier<PersonaliseController> {
  PersonoliseControllerProvider({required Ref ref}) : super(PersonaliseController(ref: ref));
}

class PersonaliseController {
  final Ref ref;
  PersonaliseController({required this.ref});
  final box = GetStorage();
  final zipcodeController = TextEditingController();
  final mobileController = TextEditingController();
  var selectedInterests = <String>[];
  var userLocation = LocationModel(city: "", country: "", countryDialCode: "", zipcode: "");

  // TODO: fix location services

  // Future<void> initialise() async {
  //   await ref.read(userLocationProvider.notifier).getCurrentLocation();
  //   userLocation = ref.read(userLocationProvider);
  //   zipcodeController.text = userLocation.zipcode;
  //   mobileController.text = ref.read(authProvider).currentUser!.phoneNumber ?? "9998887779";
  // }

  void updateInterests(String interest) {
    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
  }

  bool validate() {
    if (zipcodeController.text.isEmpty) {
      showSnackBar(message: "Please enter zipcode");
      return false;
    }

    if (zipcodeController.text.length != 6) {
      showSnackBar(message: "Please enter valid zipcode");
      return false;
    }
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

  void sumbitInterests() async {
    final check = validate();
    final countryDialCode = userLocation.countryDialCode;
    if (check) {
      try {
        final auth = ref.read(authProvider);
        final location = ref.read(userLocationProvider);
        UserModel newUser = UserModel(
          id: 1,
          name: auth.currentUser?.displayName ?? '',
          mobileNumber: "$countryDialCode${mobileController.text.trim()}",
          email: auth.currentUser?.email ?? '',
          imageUrl: ref.read(defaultsProvider).profilePictureUrl,
          handle: "",
          isAmbassador: false,
          about: "New to Zipbuzz",
          eventsHosted: 0,
          rating: 0.toDouble(),
          zipcode: zipcodeController.text.trim(),
          interests: selectedInterests,
          eventUids: [],
          pastEventUids: [],
          instagramId: "null",
          linkedinId: "null",
          twitterId: "null",
          city: location.city,
          country: location.country,
          countryDialCode: location.countryDialCode,
        );

        // creating new user
        await ref.read(dbServicesProvider).createUser(user: newUser);

        // Reading id after id is being updated in createUser method
        final id = GetStorage().read('id');
        ref.read(userProvider.notifier).update((state) => newUser.copyWith(id: id));
        final userInterestPostModel =
            UserInterestPostModel(userId: id, interests: selectedInterests);

        ref.read(newEventProvider.notifier).updateHostId(id);
        ref.read(newEventProvider.notifier).updateHostName(newUser.name);
        ref.read(newEventProvider.notifier).updateHostPic(newUser.imageUrl);

        // posting users interests
        await ref.read(dbServicesProvider).postUserInterests(userInterestPostModel);
        box.write('user_interests', newUser.interests);
        debugPrint("USER CREATED SUCCESSFULLY");
      } catch (e) {
        debugPrint("Error crearting user in personalise page: $e");
      }
    }
  }
}
