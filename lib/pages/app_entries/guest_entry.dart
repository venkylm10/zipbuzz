import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/pages/home/home.dart';
import 'package:zipbuzz/services/contact_services.dart';
import 'package:zipbuzz/services/location_services.dart';
import 'package:zipbuzz/widgets/common/loader.dart';

class GuestEntry extends ConsumerWidget {
  static const id = '/guest';
  const GuestEntry({super.key});

  Future<void> getInitialInfo(WidgetRef ref) async {
    await Future.delayed(const Duration(milliseconds: 500));
    ref.read(userProvider.notifier).update((state) => globalDummyUser);
    ref.read(loadingTextProvider.notifier).updateLoadingText("Getting your location...");
    await ref.read(userLocationProvider.notifier).getCurrentLocation();
    ref.read(loadingTextProvider.notifier).updateLoadingText("Fetching contacts...");
    await ref.read(contactsServicesProvider).updateAllContacts();
    ref.read(newEventProvider.notifier).resetNewEvent();
    ref.read(loadingTextProvider.notifier).reset();
    ref.read(homeTabControllerProvider.notifier).isSearching = true;
    GetStorage().write('id', 1);
    return;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: getInitialInfo(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return const Home();
        }
        return const Loader();
      },
    );
  }
}
