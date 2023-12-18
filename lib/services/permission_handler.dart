import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

final appPermissionsProvider = Provider((ref) => AppPermissions());

class AppPermissions {
  final location = Location();
  Future<bool> getlocationPermission() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      await location.requestService();
    }
    var status = await Permission.location.request();
    if (status.isPermanentlyDenied) {
      showSnackBar(message: "Please enable location permission");
      openAppSettings();
    }
    if (status.isDenied) {
      status = await Permission.location.request();
      if (status.isDenied) {
        return false;
      }
    }
    return true;
  }

  Future<bool> getContactsPermission() async {
    final res = await FlutterContacts.requestPermission();
    return res;
  }
}
