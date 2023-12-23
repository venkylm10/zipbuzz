import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/personalise/personalise_controller.dart';
import 'package:zipbuzz/pages/personalise/personalise_page.dart';
import 'package:zipbuzz/widgets/common/loader.dart';

class SignUpEntry extends ConsumerWidget {
  static const id = '/signUpEntry';
  const SignUpEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(personaliseControllerProvider).initialise(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return const PersonalisePage();
        }
        return const Loader();
      },
    );
  }
}
