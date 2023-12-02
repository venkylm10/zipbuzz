import 'package:flutter/material.dart';
import 'package:zipbuzz/pages/event_details/event_details_page.dart';
import 'package:zipbuzz/pages/home/home.dart';
import 'package:zipbuzz/pages/personalise/personalise_page.dart';
import 'package:zipbuzz/pages/profile/edit_profile_page.dart';
import 'package:zipbuzz/pages/settings/faqs_page.dart';
import 'package:zipbuzz/pages/sign-in/sign_in_page.dart';
import 'package:zipbuzz/pages/welcome/welcome_page.dart';
import 'package:zipbuzz/widgets/auth_gate.dart';

final routes = {
  AuthGate.id: (context) => const AuthGate(),
  WelcomePage.id: (context) => const WelcomePage(),
  SignInSheet.id: (context) => const SignInSheet(),
  PersonalisePage.id: (context) => const PersonalisePage(),
  Home.id: (context) =>  const Home(),
  EventDetailsPage.id: (context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final event = args['event'];
    final isPreview = args['isPreview'] ?? false;
    return EventDetailsPage(event: event, isPreview: isPreview);
  },
  EditProfilePage.id: (context) => const EditProfilePage(),
  FAQsPage.id: (context) => const FAQsPage(),
};
