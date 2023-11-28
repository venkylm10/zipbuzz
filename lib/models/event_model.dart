import 'package:flutter/material.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/models/user_model.dart';

class EventModel {
  final String title;
  final String? about;
  final List<UserModel> hosts;
  final String location;
  final DateTime dateTime;
  final TimeOfDay startTime;
  final TimeOfDay? endTime;
  final int attendees;
  final int maxAttendees;
  final String interest;
  final bool favourite;
  final String bannerPath;
  final String iconPath;
  final bool? isPrivate;
  const EventModel({
    required this.title,
    this.hosts = const <UserModel>[],
    required this.location,
    required this.dateTime,
    required this.startTime,
    this.endTime,
    required this.attendees,
    required this.interest,
    required this.favourite,
    required this.bannerPath,
    required this.iconPath,
    this.about,
    required this.maxAttendees,
    this.isPrivate = false,
  });
}

final dummyAbout =
    "Get ready to turn up the color dial and paint the town in a kaleidoscope of hues at the most vibrant house party of the year! We're throwing a bash that's bursting with life and vivacity, and the only rule is to dress like a walking, talking rainbow.\nAs you step through the front door, you'll be transported into a world where the vivid and the vivacious collide! The walls are adorned with neon graffiti, and the dance floor is a glowing tapestry of pulsating lights that'll make you feel like you've walked into a real-life disco fever dream.\nGet Ready to Groove:\nWe're turning up the music, dimming the lights, and transforming our space into a dance paradise\nA community of passionate dance enthusiasts ready to bust moves all night\nFrom salsa to hip-hop, there's something for everyone to enjoy and explore.\nShow off your dance skills in our dance-off competitions, and you could win some fantastic prizes.\nLeave your worries at the door and come dance in a safe, judgment-free zone.";

final dummyEvents = [
  EventModel(
    title: "International Band Music Festival",
    about: dummyAbout,
    hosts: [globalDummyUser.copyWith(name: "John Smith")],
    location: "420 Gala St, San Jose 95125",
    dateTime: DateTime.utc(2023, 11, 20, 20, 0, 0),
    startTime: TimeOfDay.fromDateTime(DateTime.utc(2023, 11, 20, 20, 0, 0)),
    attendees: 8,
    maxAttendees: 50,
    favourite: false,
    bannerPath: Assets.images.band_music,
    iconPath: Assets.icons.music,
    interest: 'Music',
  ),
  EventModel(
    title: "I'm Going to Shake Y",
    about: dummyAbout,
    hosts: [globalDummyUser.copyWith(name: "John Smith")],
    location: "420 Gala St, San Jose 95125",
    dateTime: DateTime.utc(2023, 12, 22, 20, 0, 0),
    startTime: TimeOfDay.fromDateTime(DateTime.utc(2023, 11, 20, 20, 0, 0)),
    attendees: 8,
    maxAttendees: 50,
    favourite: true,
    bannerPath: Assets.images.shake_y,
    iconPath: Assets.icons.music,
    interest: 'Music',
  ),
  EventModel(
    title: "Wild with the Nature",
    about: dummyAbout,
    hosts: [globalDummyUser.copyWith(name: "John Smith")],
    location: "420 Gala St, San Jose 95125",
    dateTime: DateTime.utc(2023, 12, 20, 20, 0, 0),
    startTime: TimeOfDay.fromDateTime(DateTime.utc(2023, 11, 20, 20, 0, 0)),
    attendees: 8,
    maxAttendees: 50,
    favourite: true,
    bannerPath: Assets.images.nature,
    iconPath: Assets.icons.movieClubs,
    interest: 'Muvie Clubs',
  ),
  EventModel(
    title: "Dazzling Of Evermore",
    hosts: [globalDummyUser.copyWith(name: "John Smith")],
    location: "420 Gala St, San Jose 95125",
    dateTime: DateTime.utc(2023, 12, 24, 20, 0, 0),
    startTime: TimeOfDay.fromDateTime(DateTime.utc(2023, 11, 20, 20, 0, 0)),
    attendees: 8,
    maxAttendees: 50,
    favourite: false,
    bannerPath: Assets.images.evermore,
    iconPath: Assets.icons.parties,
    interest: 'Parties',
  ),
  EventModel(
    title: "Art Museum: Life of Abstract",
    about:
        "An art museum or art gallery is a building or space for the display of art, usually from the museum's own collection.",
    hosts: [globalDummyUser.copyWith(name: "John Smith")],
    location: "420 Gala St, San Jose 95125",
    dateTime: DateTime.utc(2023, 12, 23, 20, 0, 0),
    startTime: TimeOfDay.fromDateTime(DateTime.utc(2023, 11, 20, 20, 0, 0)),
    attendees: 8,
    maxAttendees: 50,
    favourite: false,
    bannerPath: Assets.images.art_museum,
    iconPath: Assets.icons.book,
    interest: 'Book',
  ),
];

Map<DateTime, List<EventModel>> events = {
  DateTime.utc(2023, 11, 20, 0, 0, 0): [
    EventModel(
      title: "International Band Music Festival",
      about: dummyAbout,
      hosts: [globalDummyUser.copyWith(name: "John Smith")],
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 20, 0, 0, 0),
      startTime: TimeOfDay.fromDateTime(DateTime.utc(2023, 11, 20, 20, 0, 0)),
      attendees: 8,
      maxAttendees: 50,
      favourite: false,
      bannerPath: Assets.images.band_music,
      iconPath: Assets.icons.music,
      interest: 'Music',
    ),
    EventModel(
      title: "I'm Going to Shake Y",
      about: dummyAbout,
      hosts: [globalDummyUser.copyWith(name: "John Smith")],
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 20, 0, 0, 0),
      startTime: TimeOfDay.fromDateTime(DateTime.utc(2023, 11, 20, 20, 0, 0)),
      attendees: 8,
      maxAttendees: 50,
      favourite: true,
      bannerPath: Assets.images.shake_y,
      iconPath: Assets.icons.music,
      interest: 'Music',
    ),
    EventModel(
      title: "Wild with the Nature",
      about: dummyAbout,
      hosts: [globalDummyUser.copyWith(name: "John Smith")],
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 20, 0, 0, 0),
      startTime: TimeOfDay.fromDateTime(DateTime.utc(2023, 11, 20, 20, 0, 0)),
      attendees: 8,
      maxAttendees: 50,
      favourite: true,
      bannerPath: Assets.images.nature,
      iconPath: Assets.icons.movieClubs,
      interest: 'Movie Clubs',
    ),
    EventModel(
      title: "Dazzling Of Evermore",
      about: dummyAbout,
      hosts: [globalDummyUser.copyWith(name: "John Smith")],
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 20, 0, 0, 0),
      startTime: TimeOfDay.fromDateTime(DateTime.utc(2023, 11, 20, 20, 0, 0)),
      attendees: 8,
      maxAttendees: 50,
      favourite: false,
      bannerPath: Assets.images.evermore,
      iconPath: Assets.icons.parties,
      interest: 'Parties',
    ),
    EventModel(
      title: "Art Museum: Life of Abstract",
      about:
          "An art museum or art gallery is a building or space for the display of art, usually from the museum's own collection.",
      hosts: [globalDummyUser.copyWith(name: "John Smith")],
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 20, 0, 0, 0),
      startTime: TimeOfDay.fromDateTime(DateTime.utc(2023, 11, 20, 20, 0, 0)),
      attendees: 8,
      maxAttendees: 50,
      favourite: false,
      bannerPath: Assets.images.art_museum,
      iconPath: Assets.icons.book,
      interest: 'Book',
    ),
  ],
};
