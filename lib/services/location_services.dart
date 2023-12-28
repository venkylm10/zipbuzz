import 'package:country_dial_code/country_dial_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/location/location_model.dart';
import 'package:zipbuzz/services/permission_handler.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

final userLocationProvider =
    StateNotifierProvider<LocationServices, LocationModel>((ref) => LocationServices(ref: ref));

class LocationServices extends StateNotifier<LocationModel> {
  final Ref ref;
  LocationServices({required this.ref})
      : super(LocationModel(city: "", country: "", countryDialCode: "", zipcode: "95120"));

  Future<void> getCurrentLocation() async {
    try {
      final permission = await ref.read(appPermissionsProvider).getlocationPermission();
      if (!permission) return;
      debugPrint("UPDATING LOCATION");
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

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
              countryDialCode: CountryDialCode.fromCountryCode(placemark.isoCountryCode!).dialCode);
        }
        debugPrint("UPDATED USER LOCATION : ${state.toMap()}");
        GetStorage().write('location', state.toMap());
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
        debugPrint("UPDATED LOCATION SUCCESSFULLY");
      }
    } catch (e) {
      showSnackBar(message: "ERROR FETCHING LOCATION");
      final box = GetStorage();
      if (box.hasData('location')) {
        final location = box.read('location');
        state = LocationModel.fromMap(location);
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

  Future<void> updateLocationFromZipcode(String newZipcode) async {
    try {
      state = state.copyWith(zipcode: newZipcode);
      List<Location> locations = await locationFromAddress(newZipcode);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(locations.first.latitude, locations.first.longitude);

      final placemark = placemarks.first;
      state = state.copyWith(
          city: placemarks.firstWhere((placemark) => placemark.locality != null).locality!);
      state = state.copyWith(country: placemark.country ?? "");
      if (placemark.isoCountryCode != null) {
        state = state.copyWith(
            countryDialCode: CountryDialCode.fromCountryCode(placemark.isoCountryCode!).dialCode);
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
