import 'package:country_dial_code/country_dial_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get_storage/get_storage.dart';
import 'package:location/location.dart' as geo;
import 'package:zipbuzz/controllers/user/user_controller.dart';
import 'package:zipbuzz/models/location/location_model.dart';
import 'package:zipbuzz/services/permission_handler.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

final userLocationProvider =
    StateNotifierProvider<LocationServices, LocationModel>(
        (ref) => LocationServices(ref: ref));

class LocationServices extends StateNotifier<LocationModel> {
  final Ref ref;
  LocationServices({required this.ref})
      : super(LocationModel(
            city: "", country: "", countryDialCode: "", zipcode: "444444"));

  Future<void> getCurrentLocation() async {
    try {
      final permission =
          await ref.read(appPermissionsProvider).getlocationPermission();
      if (!permission) return;
      debugPrint("updating location");
      geo.Location location = geo.Location();
      geo.LocationData? currentLocation = await location.getLocation();

      List<Placemark> placemarks = await placemarkFromCoordinates(
          currentLocation.latitude!, currentLocation.longitude!);

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        state = state.copyWith(
          zipcode: placemark.postalCode ?? '',
          city: placemark.locality ?? '',
          country: placemark.country ?? '',
          countryDialCode: "",
        );

        if (placemark.isoCountryCode != null) {
          state = state.copyWith(
              countryDialCode:
                  CountryDialCode.fromCountryCode(placemark.isoCountryCode!)
                      .dialCode);
        }
        debugPrint("updated user location : ${state.toJson()}");
        GetStorage().write('location', state.toJson());
        ref.read(userProvider.notifier).update(
          (currentUser) {
            return currentUser.copyWith(
              zipcode: state.zipcode,
              city: state.city,
              country: state.country,
              countryDialCode: state.countryDialCode,
            );
          },
        );
        debugPrint("Updated location successfully");
      }
    } catch (e) {
      showSnackBar(message: "Error fetching location");
      final box = GetStorage();
      if (box.hasData('location')) {
        final location = box.read('location');
        state = LocationModel.fromJson(location);
        ref.read(userProvider.notifier).update(
          (currentUser) {
            return currentUser.copyWith(
              zipcode: state.zipcode,
              city: state.city,
              country: state.country,
              countryDialCode: state.countryDialCode,
            );
          },
        );
      }
      debugPrint("Error getting location: $e");
    }
  }

  Future<void> updatestateFromZipcode(String newZipcode) async {
    try {
      final state = ref.read(userLocationProvider);
      state.zipcode = newZipcode;
      List<Location> locations = await locationFromAddress(newZipcode);

      List<Placemark> placemarks = await placemarkFromCoordinates(
          locations.first.latitude, locations.first.longitude);

      final placemark = placemarks.first;
      state.city = placemarks
          .firstWhere((placemark) => placemark.locality != null)
          .locality!;
      state.country = placemark.country ?? "";
      if (placemark.isoCountryCode != null) {
        state.countryDialCode =
            CountryDialCode.fromCountryCode(placemark.isoCountryCode!).dialCode;
      }
      ref.read(userProvider.notifier).update((state) {
        return state.copyWith(
          zipcode: newZipcode,
          city: state.city,
          country: state.country,
          countryDialCode: state.countryDialCode,
        );
      });
      debugPrint("updated location successfully");
    } catch (e) {
      showSnackBar(message: "Error fetching location");
      debugPrint("Error updating location using zipcode $newZipcode: $e");
    }
  }
}
