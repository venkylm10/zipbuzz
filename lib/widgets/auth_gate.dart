import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/user_controller.dart';
import 'package:zipbuzz/models/user_model.dart';
import 'package:zipbuzz/pages/home/home.dart';
import 'package:zipbuzz/pages/personalise/personalise_page.dart';
import 'package:zipbuzz/pages/welcome/welcome_page.dart';
import 'package:zipbuzz/services/firebase_providers.dart';
import 'package:zipbuzz/services/local_storage.dart';

class AuthGate extends ConsumerStatefulWidget {
  static const id = '/auth_gate';
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  UserModel? currentUser;
  void initialiseUser() async {
    currentUser = await ref.read(localDBProvider).getUser();
    ref.read(userProvider.notifier).update((state) => currentUser);
    setState(() {});
  }

  @override
  void initState() {
    initialiseUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: ref.read(authProvider).authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (ref.watch(userProvider) == null) {
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
