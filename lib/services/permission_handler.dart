import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final appPermissionsProvider = Provider((ref) => AppPermissions());

class AppPermissions {
  Future<bool> getContactsPermission() async {
    final res = await Permission.contacts.request();
    return res.isGranted;
  }
}
