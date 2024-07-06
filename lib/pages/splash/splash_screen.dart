import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/controllers/events/edit_event_controller.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/controllers/personalise/personalise_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/user/requests/user_details_request_model.dart';
import 'package:zipbuzz/pages/home/home.dart';
import 'package:zipbuzz/pages/personalise/personalise_page.dart';
import 'package:zipbuzz/pages/sign-in/web_sign_page.dart';
import 'package:zipbuzz/pages/welcome/welcome_page.dart';
import 'package:zipbuzz/services/contact_services.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/services/location_services.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/widgets/loader.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static const id = '/';
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<SplashScreen> {
  final box = GetStorage();

  Future<void> getLoggedInUserData() async {
    ref.read(loadingTextProvider.notifier).updateLoadingText("Getting your Data...");
    final id = GetStorage().read(BoxConstants.id) as int?;
    if (id == null) {
      await GetStorage().erase();
      navigatorKey.currentState!.pushNamedAndRemoveUntil(SplashScreen.id, (_) => false);
      return;
    }
    final requestModel = UserDetailsRequestModel(userId: id);
    await ref.read(dbServicesProvider).getUserData(requestModel);
    await ref
        .read(userLocationProvider.notifier)
        .getLocationFromZipcode(ref.read(userProvider).zipcode);
    ref.read(newEventProvider.notifier).updateHostId(id);
    ref.read(newEventProvider.notifier).updateHostName(ref.read(userProvider).name);
    final location = ref.read(userLocationProvider);
    ref.read(userProvider.notifier).update(
          (state) => state.copyWith(
            zipcode: location.zipcode,
            city: location.city,
            country: location.country,
            countryDialCode: location.countryDialCode,
          ),
        );
    ref.read(loadingTextProvider.notifier).reset();
    final mobileNumber = ref.read(userProvider).mobileNumber;
    if (mobileNumber == "+11234567890" ||
        mobileNumber == "zipbuzz-null" ||
        ref.read(userProvider).zipcode == "zipbuzz-null") {
      ref.read(personaliseControllerProvider).initialiseLoggedInUser();
      navigatorKey.currentState!.pushReplacementNamed(PersonalisePage.id);
      return;
    }
    ref.read(contactsServicesProvider).updateAllContacts();
    navigatorKey.currentState!.pushNamedAndRemoveUntil(Home.id, (route) => false);
  }

  void buildNextScreen() async {
    await ref.read(dioServicesProvider).checkEmail("venkylm10@gmail.com");
    bool? login = box.read(BoxConstants.login) as bool?;
    await Future.delayed(const Duration(milliseconds: 500));
    await updateInterestsData();
    if (login != null && login) {
      await getLoggedInUserData();
      return;
    }
    await ref.read(dioServicesProvider).updateOnboardingDetails();
    if (kIsWeb) {
      navigatorKey.currentState!.pushNamedAndRemoveUntil(WebSignInPage.id, (route) => false);
    } else {
      navigatorKey.currentState!.pushNamedAndRemoveUntil(WelcomePage.id, (route) => false);
    }
  }

  Future<void> updateInterestsData() async {
    await ref.read(eventsControllerProvider.notifier).getAllInterests();
    ref.read(newEventProvider.notifier).updateCategory('Please select');
    ref.read(editEventControllerProvider.notifier).updateCategory(allInterests.first.activity);
  }

  @override
  void initState() {
    buildNextScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Loader();
  }
}
