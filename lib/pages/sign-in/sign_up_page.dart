import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/personalise/personalise_controller.dart';
import 'package:zipbuzz/pages/personalise/personalise_page.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/widgets/common/loader.dart';

class SignUpPage extends ConsumerStatefulWidget {
  static const id = '/welcome/sign_up';
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpPage> {
  void getInitData() async {
    await ref.read(personaliseControllerProvider).initialise();
    navigatorKey.currentState!.pushNamedAndRemoveUntil(PersonalisePage.id, (route) => false);
  }

  @override
  void initState() {
    getInitData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Loader();
  }
}
