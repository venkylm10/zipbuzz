import 'package:flutter/foundation.dart';
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
    StateNotifierProvider<LocationServices, LocationModel>(
        (ref) => LocationServices(ref: ref));

class LocationServices extends StateNotifier<LocationModel> {
  final Ref ref;
  LocationServices({required this.ref})
      : super(LocationModel(
            city: "-",
            country: "-",
            countryDialCode: "+1",
            zipcode: "95050",
            neighborhood: "-"));

  final box = GetStorage();

  void updateState(LocationModel updatedLocation) {
    state = updatedLocation;
  }

  Future<void> getLocationFromZipcode(String newZipcode) async {
    state = state.copyWith(zipcode: newZipcode);
    try {
      final res = kIsWeb
          ? await ref
              .read(dioServicesProvider)
              .dio
              .post(DioConstants.getLocationWeb, data: {"zipcode": newZipcode})
          : await ref
              .read(dioServicesProvider)
              .dio
              .get(DioConstants.getLocation, data: {"zipcode": newZipcode});
      debugPrint("LOCATION DATA: ${res.data}");
      final loc = (res.data['location_name'] as String).split(",");
      var country = "";
      var neightborhood = "";
      neightborhood = loc[0].trim();
      final city = loc[1].trim();
      country = loc.length > 2 ? loc[2].trim() : "";
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
        neighborhood: neightborhood,
      );
      box.write(BoxConstants.location, newZipcode);
    }  catch (e) {
      Fluttertoast.showToast(
        msg: "Zipcode not found!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      state = state.copyWith(zipcode: newZipcode);
      ref.read(userProvider.notifier).update(
            (state) => state.copyWith(zipcode: state.zipcode),
          );
      debugPrint("Error updating location using zipcode $newZipcode: $e");
    }
  }
}
