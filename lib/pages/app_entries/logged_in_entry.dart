import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/user/requests/user_details_request_model.dart';
import 'package:zipbuzz/pages/home/home.dart';
import 'package:zipbuzz/services/contact_services.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/location_services.dart';
import 'package:zipbuzz/widgets/common/loader.dart';

class LoggedInEntry extends ConsumerWidget {
  static const id = '/loggedIn';
  const LoggedInEntry({super.key});

  Future<void> getUserData(WidgetRef ref) async {
    await Future.delayed(const Duration(milliseconds: 500));
    ref.read(loadingTextProvider.notifier).updateLoadingText("Getting your location...");
    await ref.read(userLocationProvider.notifier).getCurrentLocation();
    ref.read(loadingTextProvider.notifier).updateLoadingText("Getting your Data...");
    final id = GetStorage().read('id') as int;
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
    await ref.read(contactsServicesProvider).updateAllContacts();
    ref.read(loadingTextProvider.notifier).reset();
    return;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: getUserData(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return const Home();
        }
        return const Loader();
      },
    );
  }
}
