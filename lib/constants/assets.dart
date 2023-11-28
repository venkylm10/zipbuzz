// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:zipbuzz/constants/colors.dart';

class Assets {
  static const icons = AppIcons();
  static const images = Images();
  static const welcomeImage = WelcomeImage();
}

class AppIcons {
  const AppIcons();
  final hiking = 'assets/icons/hiking.png';
  final sports = 'assets/icons/sports.png';
  final music = 'assets/icons/music.png';
  final movieClubs = 'assets/icons/movie_clubs.png';
  final dance = 'assets/icons/dance.png';
  final fitness = 'assets/icons/fitness.png';
  final parties = 'assets/icons/parties.png';
  final book = 'assets/icons/book.png';
  final boating = 'assets/icons/boating.png';
  final wineTasting = 'assets/icons/wine_tasting.png';
  final gaming = 'assets/icons/gaming.png';
  final kidPlaydates = 'assets/icons/kid_playdates.png';
  final petActivites = 'assets/icons/pet_activities.png';
  final geo = 'assets/icons/geo.svg';
  final search = 'assets/icons/search.svg';
  final notification = 'assets/icons/notification.svg';
  final searchBarIcon = 'assets/icons/search_bar_icon.svg';
  final home = 'assets/icons/home.svg';
  final events = 'assets/icons/calendar.svg';
  final calendar = 'assets/icons/calendar.svg';
  final calendar_fill = 'assets/icons/calendar_fill.svg';
  final map = 'assets/icons/map.svg';
  final person = 'assets/icons/person.svg';
  final person_fill = 'assets/icons/person_fill.svg';
  final people = 'assets/icons/people.svg';
  final geo_mini = 'assets/icons/geo_mini.svg';
  final geo2 = 'assets/icons/geo2.svg';
  final clock = 'assets/icons/clock.svg';
  final clock_fill = 'assets/icons/clock_fill.svg';
  final google_logo = 'assets/icons/google.svg';
  final apple_logo = 'assets/icons/apple.svg';
  final telephone = 'assets/icons/telephone.svg';
  final telephone_filled = 'assets/icons/telephone_filled.svg';
  final edit = 'assets/icons/edit.svg';
  final check = 'assets/icons/check.svg';
  final hosts = 'assets/icons/hosts.svg';
  final rating = 'assets/icons/rating.svg';
  final at = 'assets/icons/at.svg';
  final follow_link = 'assets/icons/follow_link.svg';
  final faqs = 'assets/icons/faqs.svg';
  final notifications_settings = 'assets/icons/notifications_settings.svg';
  final tnc = 'assets/icons/tnc.svg';
  final privacy_policy = 'assets/icons/privacy_policy.svg';
  final linkedin = 'assets/icons/linkedin.png';
  final instagram = 'assets/icons/instagram.png';
  final twitter = 'assets/icons/twitter.png';
  final delete = 'assets/icons/delete.svg';
  final remove = 'assets/icons/x.svg';
  final save = 'assets/icons/save.svg';
  final gallery = 'assets/icons/gallery.svg';
  final save_event = 'assets/icons/save_event.svg';
  final qr = 'assets/icons/qr.svg';
  final add_circle = 'assets/icons/plus_circle.svg';
  final add_fill = 'assets/icons/add_fill.svg';
  final delete_fill = 'assets/icons/delete_fill.svg';
  final send_fill = 'assets/icons/send_fill.svg';
  final heart_fill = 'assets/icons/heart_fill.svg';
  final gallery_add = 'assets/icons/gallery_add.svg';
  final link = 'assets/icons/link.svg';
}

class WelcomeImage {
  const WelcomeImage();
  final welcome1 = 'assets/images/welcome/welcome1.png';
  final welcome2 = 'assets/images/welcome/welcome2.png';
  final welcome3 = 'assets/images/welcome/welcome3.png';
}

class Images {
  const Images();
  // event images
  final band_music = 'assets/images/events/band_music.png';
  final shake_y = 'assets/images/events/shake_y.png';
  final nature = 'assets/images/events/wild_with_nature.png';
  final evermore = 'assets/images/events/dazzling_of_evermore.png';
  final art_museum = 'assets/images/events/art_museum.png';
  final no_events = 'assets/images/events/no_events.png';

  // profile
  final profile = 'assets/images/profile.png';
}

final allInterests = {
  'Hiking': Assets.icons.hiking,
  'Sports': Assets.icons.sports,
  'Music': Assets.icons.music,
  'Movie Clubs': Assets.icons.movieClubs,
  'Dance': Assets.icons.dance,
  'Fitness': Assets.icons.fitness,
  'Parties': Assets.icons.parties,
  'Book': Assets.icons.book,
  'Boating': Assets.icons.boating,
  'Wine Tasting': Assets.icons.wineTasting,
  'Gaming': Assets.icons.gaming,
  'Kid Playdates': Assets.icons.kidPlaydates,
  'Pet Activities': Assets.icons.petActivites,
};

final Map<String, Color> interestColors = {
  Assets.icons.hiking: Colors.brown,
  Assets.icons.sports: Colors.green,
  Assets.icons.music: const Color.fromARGB(255, 228, 208, 34),
  Assets.icons.movieClubs: Colors.deepPurple,
  Assets.icons.dance: Colors.red,
  Assets.icons.fitness: Colors.blueGrey,
  Assets.icons.parties: Colors.pink,
  Assets.icons.book: Colors.lightGreen,
  Assets.icons.boating: Colors.lime,
  Assets.icons.wineTasting: AppColors.primaryColor,
  Assets.icons.gaming: Colors.red,
  Assets.icons.kidPlaydates: Colors.pink,
  Assets.icons.petActivites: Colors.orange,
};

Color getInterestColor(String iconPath) {
  return interestColors[iconPath]!;
}
