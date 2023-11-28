import 'package:flutter/material.dart';
import 'package:zipbuzz/pages/event_details/event_details_page.dart';
import 'package:zipbuzz/pages/home/home.dart';
import 'package:zipbuzz/pages/personalise/personalise_page.dart';
import 'package:zipbuzz/pages/profile/edit_profile_page.dart';
import 'package:zipbuzz/pages/settings/faqs_page.dart';
import 'package:zipbuzz/pages/welcome/welcome_page.dart';

final routes = {
  WelcomePage.id: (context) => const WelcomePage(),
  PersonalisePage.id: (context) => const PersonalisePage(),
  Home.id: (context) => const Home(),
  EventDetailsPage.id: (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final event = args['event'];
    return EventDetailsPage(event: event);
  },
  EditProfilePage.id: (context) => const EditProfilePage(),
  FAQsPage.id: (context) => const FAQsPage(),
};
