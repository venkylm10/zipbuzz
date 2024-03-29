import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/location/location_model.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/utils/constants/dio_contants.dart';

final userLocationProvider =
    StateNotifierProvider<LocationServices, LocationModel>((ref) => LocationServices(ref: ref));

class LocationServices extends StateNotifier<LocationModel> {
  final Ref ref;
  LocationServices({required this.ref})
      : super(LocationModel(
            city: "Santa Clara", country: "CA", countryDialCode: "+1", zipcode: "95050"));

  final box = GetStorage();

  void updateState(LocationModel updatedLocation) {
    state = updatedLocation;
  }

  Future<void> getLocationFromZipcode(String newZipcode) async {
    state = state.copyWith(zipcode: newZipcode);
    try {
      final res = await ref
          .read(dioServicesProvider)
          .dio
          .get(DioConstants.getLocation, data: {"zipcode": newZipcode});
      final loc = res.data['location_name'].split(",");
      final city = loc[0].toString().trim();
      var country = "";
      if (loc.length > 1) {
        country = loc[1].toString().trim();
      }
      ref.read(userProvider.notifier).update((state) {
        return state.copyWith(
          zipcode: newZipcode,
          city: city,
          country: country,
        );
      });
      state = state.copyWith(
        city: city,
        country: country,
      );
      box.write(BoxConstants.location, newZipcode);
    } on DioException catch (e) {
      Fluttertoast.showToast(
        msg: "Zipcode doesn't exist",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      debugPrint("Error updating location using zipcode $newZipcode: $e");
    } catch (e) {
      debugPrint("Error updating location using zipcode $newZipcode: $e");
    }
  }

  // Future<void> updateCountryDialCode() async {
  //   if (box.hasData(BoxConstants.countryDialCode)) {
  //     final countryDialCode = box.read(BoxConstants.countryDialCode) as String;
  //     state = state.copyWith(countryDialCode: countryDialCode);
  //     debugPrint("Country dial code: $countryDialCode");
  //     return;
  //   }
  //   try {
  //     final countryCode = await ref.read(dioServicesProvider).getCountryCode();
  //     if (countryCode != null) {
  //       final countryDialCode = CountryDialCode.fromCountryCode(countryCode).dialCode;
  //       state = state.copyWith(countryDialCode: countryDialCode);
  //       print("Country dial code: $countryDialCode");
  //       box.write(BoxConstants.countryDialCode, countryDialCode);
  //     }
  //   } catch (e) {
  //     if (box.hasData(BoxConstants.countryDialCode)) {
  //       final countryDialCode = box.read(BoxConstants.countryDialCode) as String;
  //       print("Country dial code: $countryDialCode");
  //       state = state.copyWith(countryDialCode: countryDialCode);
  //     }
  //     debugPrint("Failed to get country dial code");
  //   }
  // }

  // Future<void> updateCurrentLocation() async {
  //   final box = GetStorage();
  //   if (box.hasData(BoxConstants.location)) {
  //     final location = box.read(BoxConstants.location);
  //     state = LocationModel.fromMap(location);
  //     ref.read(userProvider.notifier).update(
  //       (currentUser) {
  //         return currentUser.copyWith(
  //           zipcode: state.zipcode,
  //           city: state.city,
  //           country: state.country,
  //           countryDialCode: state.countryDialCode,
  //         );
  //       },
  //     );
  //   }
  // try {
  //   final permission = await ref.read(appPermissionsProvider).getlocationPermission();
  //   if (!permission) return;
  //   debugPrint("UPDATING LOCATION");
  //   Position position = await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.high);

  //   List<Placemark> placemarks =
  //       await placemarkFromCoordinates(position.latitude, position.longitude);

  //   if (placemarks.isNotEmpty) {
  //     Placemark placemark = placemarks.first;
  //     state = state.copyWith(
  //       zipcode: placemark.postalCode ?? '',
  //       city: placemark.locality ?? '',
  //       country: placemark.country ?? '',
  //       countryDialCode: "",
  //     );

  //     if (placemark.isoCountryCode != null) {
  //       state = state.copyWith(
  //           countryDialCode: CountryDialCode.fromCountryCode(placemark.isoCountryCode!).dialCode);
  //     }
  //     debugPrint("UPDATED USER LOCATION : ${state.toMap()}");
  //     GetStorage().write('location', state.toMap());
  //     ref.read(userProvider.notifier).update(
  //       (currentUser) {
  //         return currentUser.copyWith(
  //           zipcode: state.zipcode,
  //           city: state.city,
  //           country: state.country,
  //           countryDialCode: state.countryDialCode,
  //         );
  //       },
  //     );
  //     debugPrint("UPDATED LOCATION SUCCESSFULLY");
  //   }
  // } catch (e) {
  //   showSnackBar(message: "ERROR FETCHING LOCATION");
  //   final box = GetStorage();
  //   if (box.hasData('location')) {
  //     final location = box.read('location');
  //     state = LocationModel.fromMap(location);
  //     ref.read(userProvider.notifier).update(
  //       (currentUser) {
  //         return currentUser.copyWith(
  //           zipcode: state.zipcode,
  //           city: state.city,
  //           country: state.country,
  //           countryDialCode: state.countryDialCode,
  //         );
  //       },
  //     );
  //   }
  //   debugPrint("Error getting location: $e");
  // }
  // }

  // Future<void> updateLocationFromZipcode(String newZipcode) async {
  //   try {
  //     state = state.copyWith(zipcode: newZipcode);
  //     List<Location> locations = await locationFromAddress(newZipcode);

  //     List<Placemark> placemarks =
  //         await placemarkFromCoordinates(locations.first.latitude, locations.first.longitude);

  //     final placemark = placemarks.first;
  //     state = state.copyWith(
  //         city: placemarks.firstWhere((placemark) => placemark.locality != null).locality!);
  //     state = state.copyWith(country: placemark.country ?? "");
  //     if (placemark.isoCountryCode != null) {
  //       state = state.copyWith(
  //           countryDialCode: CountryDialCode.fromCountryCode(placemark.isoCountryCode!).dialCode);
  //     }
  //     ref.read(userProvider.notifier).update((state) {
  //       return state.copyWith(
  //         zipcode: newZipcode,
  //         city: state.city,
  //         country: state.country,
  //         countryDialCode: state.countryDialCode,
  //       );
  //     });
  //     GetStorage().write(BoxConstants.location, state.toMap());
  //     debugPrint("updated location successfully");
  //   } catch (e) {
  //     showSnackBar(message: "Error fetching location");
  //     debugPrint("Error updating location using zipcode $newZipcode: $e");
  //   }
  // }
}
