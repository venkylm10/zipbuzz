import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:zipbuzz/pages/event_details/event_details_page.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/utils/constants/deeplinking_constants.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

final deepLinkServicesProvider = Provider((ref) => DeepLinkServices(ref));

class DeepLinkServices {
  final Ref ref;
  DeepLinkServices(this.ref);
  Future<Uri> generateEventDynamicLink(String eventId) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: DeepLinkConstants.prefixUrl,
      link: Uri.parse(
          'https://www.google.com/${DeepLinkConstants.event}?${DeepLinkConstants.eventId}=$eventId'),
      androidParameters: const AndroidParameters(
        packageName: 'com.example.zipbuzz',
        minimumVersion: 1,
      ),
      // iosParameters: const IOSParameters(
      //   bundleId: 'your_ios_bundle_identifier',
      //   minimumVersion: '1',
      //   appStoreId: 'your_app_store_id',
      // ),
    );
    var uri = await FirebaseDynamicLinks.instance.buildLink(parameters);
    debugPrint("event_id: $eventId");
    debugPrint("generated link: ${uri.toString()}");
    return uri;
  }

  Future<void> retrieveDeepLink() async {
    // Listen for incoming links while the app is running
    FirebaseDynamicLinks.instance.onLink.listen((PendingDynamicLinkData? dynamicLink) {
      _handleDeepLink(dynamicLink?.link);
    });
    // Check for initial link when the app is launched
    final PendingDynamicLinkData? initialData =
        await FirebaseDynamicLinks.instance.getInitialLink();
    _handleDeepLink(initialData?.link);
  }

  void _handleDeepLink(Uri? deepLink) {
    // print("deeplink url: $deepLink");

    if (deepLink != null) {
      if (deepLink.queryParameters.containsKey('eventId')) {
        String eventId = deepLink.queryParameters['eventId']!;
        // Handle the deep link within the existing app state
        getEventDetails(eventId);
      }
    }
  }

  Future<void> getEventDetails(String eventId) async {
    try {
      showSnackBar(message: "Loading Event Details...", duration: 5);
      var event = await ref.read(dbServicesProvider).getEventDetails(int.parse(eventId));
      final dominantColor = await getDominantColor(event.bannerPath);
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => EventDetailsPage(
            event: event,
            dominantColor: dominantColor,
            isPreview: false,
            rePublish: false,
          ),
        ),
      );
    } catch (e) {
      showSnackBar(message: e.toString(), duration: 5);
    }
  }

  Future<Color> getDominantColor(String path) async {
    Color dominantColor = Colors.green;
    final image = NetworkImage(path);
    final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
      image,
    );
    dominantColor = generator.dominantColor!.color;
    return dominantColor;
  }
}
