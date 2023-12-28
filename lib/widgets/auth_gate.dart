import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/user/requests/user_details_request_model.dart';
import 'package:zipbuzz/pages/home/home.dart';
import 'package:zipbuzz/pages/welcome/welcome_page.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/location_services.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/widgets/common/loader.dart';

class AuthGate extends ConsumerStatefulWidget {
  static const id = '/auth_gate';
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  final box = GetStorage();

  Future<void> getLoggedInUserData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (box.hasData(BoxConstants.location)) {
      await ref
          .read(userLocationProvider.notifier)
          .getLocationFromZipcode(box.read(BoxConstants.location));
    } else {
      await ref.read(userLocationProvider.notifier).getLocationFromZipcode("000000");
    }
    ref.read(loadingTextProvider.notifier).updateLoadingText("Getting your Data...");
    final id = GetStorage().read(BoxConstants.id) as int;
    final requestModel = UserDetailsRequestModel(userId: id);
    await ref.read(dbServicesProvider).getUserData(requestModel);
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
    ref.read(homeTabControllerProvider.notifier).isSearching = true;
    navigatorKey.currentState!.pushNamedAndRemoveUntil(Home.id, (route) => false);
  }

  Future<void> setUpGuestData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    ref.read(userProvider.notifier).update((state) => globalDummyUser);
    if (box.hasData(BoxConstants.location)) {
      await ref
          .read(userLocationProvider.notifier)
          .getLocationFromZipcode(box.read(BoxConstants.location));
    } else {
      await ref.read(userLocationProvider.notifier).getLocationFromZipcode("000000");
    }
    ref.read(loadingTextProvider.notifier).reset();
    ref.read(homeTabControllerProvider.notifier).isSearching = true;
    GetStorage().write(BoxConstants.id, 1);
    navigatorKey.currentState!.pushNamedAndRemoveUntil(Home.id, (route) => false);
  }

  void buildNextScreen() async {
    bool? login = box.read(BoxConstants.login) as bool?;
    bool? guest = box.read(BoxConstants.guestUser) as bool?;
    if (guest != null) {
      await setUpGuestData();
      return;
    } else if (login != null) {
      await getLoggedInUserData();
      return;
    }
    await Future.delayed(const Duration(milliseconds: 500));
    navigatorKey.currentState!.pushNamedAndRemoveUntil(WelcomePage.id, (route) => false);
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
