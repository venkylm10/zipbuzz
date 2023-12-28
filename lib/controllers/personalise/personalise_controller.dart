import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/interests/posts/user_interests_post_model.dart';
import 'package:zipbuzz/models/location/location_model.dart';
import 'package:zipbuzz/models/user/user_model.dart';
import 'package:zipbuzz/pages/home/home.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/firebase_providers.dart';
import 'package:zipbuzz/services/location_services.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/utils/constants/defaults.dart';
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
  PersonaliseController({required this.ref});
  final box = GetStorage();
  final zipcodeController = TextEditingController();
  final mobileController = TextEditingController();
  var selectedInterests = <String>[];
  var userLocation = LocationModel(city: "", country: "", countryDialCode: "", zipcode: "");

  void initialise() {
    userLocation = ref.read(userLocationProvider);
    ref.read(homeTabControllerProvider.notifier).isSearching = true;
  }

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

    if (zipcodeController.text.length < 5) {
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
        var location = ref.read(userLocationProvider);
        if (location.zipcode != zipcodeController.text.trim()) {
          ref.read(loadingTextProvider.notifier).updateLoadingText("Udating your location...");
          await ref
              .read(userLocationProvider.notifier)
              .getLocationFromZipcode(zipcodeController.text.trim());
        }
        location = ref.read(userLocationProvider);
        final auth = ref.read(authProvider);
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
        ref.read(loadingTextProvider.notifier).updateLoadingText("Signing Up...");
        await ref.read(dbServicesProvider).createUser(user: newUser);

        // Reading id after id is being updated in createUser method
        final id = GetStorage().read(BoxConstants.id);
        ref.read(userProvider.notifier).update((state) => newUser.copyWith(id: id));
        final userInterestPostModel =
            UserInterestPostModel(userId: id, interests: selectedInterests);

        ref.read(newEventProvider.notifier).updateHostId(id);
        ref.read(newEventProvider.notifier).updateHostName(newUser.name);
        ref.read(newEventProvider.notifier).updateHostPic(newUser.imageUrl);

        // posting users interests
        ref.read(loadingTextProvider.notifier).updateLoadingText("Personalising the app...");
        await ref.read(dbServicesProvider).postUserInterests(userInterestPostModel);
        box.write('user_interests', newUser.interests);
        debugPrint("USER CREATED SUCCESSFULLY");
        ref.read(loadingTextProvider.notifier).reset();
        navigatorKey.currentState!.pushNamedAndRemoveUntil(Home.id, (route) => false);
      } catch (e) {
        debugPrint("Error crearting user in personalise page: $e");
      }
    }
  }
}
