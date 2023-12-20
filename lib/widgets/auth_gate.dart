import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/controllers/navigation_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/user/requests/user_details_request_model.dart';
import 'package:zipbuzz/pages/home/home.dart';
import 'package:zipbuzz/pages/welcome/welcome_page.dart';
import 'package:zipbuzz/services/contact_services.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/location_services.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/widgets/common/loader.dart';

class AuthGate extends ConsumerStatefulWidget {
  static const id = '/auth_gate';
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  final box = GetStorage();

  Future<void> getData() async {
    final id = box.read('id') as int;
    final requestModel = UserDetailsRequestModel(userId: id);
    await ref.read(dbServicesProvider).getUserData(requestModel);
    ref.read(newEventProvider.notifier).updateHostId(id);
    ref.read(newEventProvider.notifier).updateHostName(ref.read(userProvider).name);
  }

  void navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 1));
    if (box.read(BoxConstants.login) == null) {
      NavigationController.routeOff(
        route: WelcomePage.id,
      );
    } else {
      await ref.read(userLocationProvider.notifier).getCurrentLocation();
      if (box.read(BoxConstants.guestUser) != null) {
        NavigationController.routeOff(route: Home.id);
        return;
      }
      await getData();
      final location = ref.read(userLocationProvider);
      ref.read(userProvider.notifier).update(
            (state) => state.copyWith(
              zipcode: location.zipcode,
              city: location.city,
              country: location.country,
              countryDialCode: location.countryDialCode,
            ),
          );
      await ref.read(contactsServicesProvider).updateAllContacts();
      NavigationController.routeOff(
        route: Home.id,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    navigateToNextScreen();
  }

  @override
  Widget build(BuildContext context) {
    return const Loader();
  }
}
