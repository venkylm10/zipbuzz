import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/user_controller.dart';
import 'package:zipbuzz/models/user_model.dart';
import 'package:zipbuzz/pages/home/home.dart';
import 'package:zipbuzz/pages/personalise/personalise_page.dart';
import 'package:zipbuzz/pages/welcome/welcome_page.dart';
import 'package:zipbuzz/services/auth_services.dart';
import 'package:zipbuzz/services/firebase_providers.dart';
import 'package:zipbuzz/services/location_services.dart';
import 'package:zipbuzz/widgets/common/loader.dart';

class AuthGate extends ConsumerStatefulWidget {
  static const id = '/auth_gate';
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  UserModel? userModel;

  void getData(WidgetRef ref) async {
    userModel = await ref
        .read(authServicesProvider)
        .getUserData(ref.read(authProvider).currentUser!.uid)
        .first;
    ref.read(userProvider.notifier).update((state) => userModel);
    if (ref.read(userProvider) != null) {
      if (ref.read(userProvider)!.zipcode.isEmpty) {
        await ref.read(locationServicesProvider).getInitialInfo();
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    return StreamBuilder(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final user = snapshot.data;
          if (user != null) {
            getData(ref);
            if (userModel != null) {
              if (userModel!.mobileNumber.isEmpty ||
                  userModel!.zipcode.isEmpty) {
                return const PersonalisePage();
              } else {
                return const Home();
              }
            }
          }
          return const Loader();
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }
        return const WelcomePage();
      },
    );
  }
}
