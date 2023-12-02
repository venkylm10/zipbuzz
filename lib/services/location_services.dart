import 'package:country_dial_code/country_dial_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as geo;
import 'package:zipbuzz/controllers/user_controller.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/firebase_providers.dart';

final locationServicesProvider = StateProvider((ref) => LocationServices(ref: ref));

class LocationServices {
  String zipcode = "";
  String city = "";
  String country = "";
  String countryDialCode = "";

  final Ref ref;
  LocationServices({required this.ref});

  Future<void> getInitialInfo() async {
    try {
      geo.Location location = geo.Location();
      geo.LocationData? currentLocation = await location.getLocation();

      List<Placemark> placemarks = await placemarkFromCoordinates(
          currentLocation.latitude!, currentLocation.longitude!);

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        zipcode = placemark.postalCode ?? "";
        city = placemark.locality ?? "";
        country = placemark.country ?? "";

        if (placemark.isoCountryCode != null) {
          countryDialCode =
              CountryDialCode.fromCountryCode(placemark.isoCountryCode!)
                  .dialCode;
          ref.read(userProvider.notifier).update((state) {
            return state?.copyWith(
              zipcode: zipcode,
              city: city,
              country: country,
              countryDialCode: countryDialCode,
            );
          });

          ref
              .read(dbServicesProvider)
              .updateUser(ref.read(authProvider).currentUser!.uid, {
            "zipcode": zipcode,
            "city": city,
            "country": country,
            "countryDialCode": countryDialCode,
          });
        }
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  
}
