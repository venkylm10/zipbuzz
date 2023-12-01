import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/user_controller.dart';
import 'package:zipbuzz/pages/home/home.dart';
import 'package:zipbuzz/pages/personalise/personalise_page.dart';
import 'package:zipbuzz/pages/welcome/welcome_page.dart';
import 'package:zipbuzz/services/firebase_providers.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<User?>(
      stream: ref.read(authProvider).authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (ref.read(userProvider) == null) {
            return const PersonalisePage();
          } else {
            return const Home();
          }
        }
        return const WelcomePage();
      },
    );
  }
}
