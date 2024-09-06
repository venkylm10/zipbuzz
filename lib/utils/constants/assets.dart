// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:zipbuzz/models/interests/responses/interest_model.dart';

class Assets {
  static const icons = AppIcons();
  static const images = Images();
  static const welcomeImage = WelcomeImage();
  static const lottieFiles = LottieFiles();
  static const gifFiles = GifFiles();
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
  final stars = 'assets/icons/stars.svg';
  final checkbox_checked = 'assets/icons/checkbox_checked.svg';
  final checkbox_unchecked = 'assets/icons/checkbox_unchecked.svg';
  final people_outline = 'assets/icons/people_outline.svg';
  final group_chat = 'assets/icons/group_chat.svg';
  final arrow_repeat = 'assets/icons/arrow_repeat.svg';
  final star_fill = 'assets/icons/star_fill.svg';
  final lock = 'assets/icons/lock.svg';
  final email = 'assets/icons/email.svg';
  final personName = "assets/icons/person-name.svg";
  final copy = 'assets/icons/copy.svg';
  final clone = 'assets/icons/clone.svg';
  final linkClip = 'assets/icons/link_clip.svg';
  final addToCalendar = 'assets/icons/add_to_calendar.png';
  final microsoftLogo = 'assets/icons/microsoft.png';
  final home_calender_not_visible = 'assets/icons/home_calender_not_visible.svg';
  final home_calender_visible = 'assets/icons/home_calender_visible.svg';
  final group_tab = 'assets/icons/group_tab.png';
  final reminderIcon = 'assets/icons/reminder_icon.png';
  final broadcastIcon = 'assets/icons/broadcast_icon.png';
}

class WelcomeImage {
  const WelcomeImage();
  final welcome1 = 'assets/images/welcome/welcome1.png';
  final welcome2 = 'assets/images/welcome/welcome2.jpg';
  final welcome3 = 'assets/images/welcome/welcome3.jpeg';
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
  final default_contact_avatar = 'assets/images/events/default_contact_avatar.png';
  final no_events_image = 'assets/images/events/no_event_image.png';

  // profile
  final profile = 'assets/images/profile.png';

  // ipad_border
  final ipad_border = 'assets/images/ipad_border.png';
  final border_ratio = 1484 / 2000;
}

class LottieFiles {
  const LottieFiles();
  final event_created = 'assets/lottie_files/event_created.json';
}

class GifFiles {
  const GifFiles();
  final event_created = 'assets/gif_files/event_created.gif';
}

var allInterests = <InterestModel>[];

var unsortedInterests = <InterestModel>[];

var interestIcons = <String, String>{};

var interestBanners = <String, String>{};

var interestColors = <String, Color>{};
