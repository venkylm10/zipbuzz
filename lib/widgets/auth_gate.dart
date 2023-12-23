import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/pages/app_entries/guest_entry.dart';
import 'package:zipbuzz/pages/app_entries/logged_in_entry.dart';
import 'package:zipbuzz/pages/welcome/welcome_page.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';

class AuthGate extends StatelessWidget {
  static const id = '/auth_gate';
  AuthGate({super.key});

  final box = GetStorage();

  Widget buildEntry() {
    if (box.read(BoxConstants.login) == null) {
      return const WelcomePage();
    }
    if (box.read(BoxConstants.guestUser) != null) {
      return const GuestEntry();
    }
    return const LoggedInEntry();
  }

  @override
  Widget build(BuildContext context) {
    return buildEntry();
  }
}
