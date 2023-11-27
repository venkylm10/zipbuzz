import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/models/user_model.dart';

class EventModel {
  final String title;
  final String? description;
  final List<UserModel> hosts;
  final String location;
  final DateTime dateTime;
  final int attendees;
  final int maxAttendees;
  final String category;
  final bool favourite;
  final String bannerPath;
  final String iconPath;
  const EventModel({
    required this.title,
    this.hosts = const <UserModel>[],
    required this.location,
    required this.dateTime,
    required this.attendees,
    required this.category,
    required this.favourite,
    required this.bannerPath,
    required this.iconPath,
    this.description,
    required this.maxAttendees,
  });
}

final dummyEvents = [
  EventModel(
    title: "International Band Music Festival",
    hosts: [globalDummyUser.copyWith(name: "John Smith")],
    location: "420 Gala St, San Jose 95125",
    dateTime: DateTime.utc(2023, 11, 20, 20, 0, 0),
    attendees: 8,
    maxAttendees: 50,
    favourite: false,
    bannerPath: Assets.images.band_music,
    iconPath: Assets.icons.music,
    category: 'Music',
  ),
  EventModel(
    title: "I'm Going to Shake Y",
    hosts: [globalDummyUser.copyWith(name: "John Smith")],
    location: "420 Gala St, San Jose 95125",
    dateTime: DateTime.utc(2023, 12, 22, 20, 0, 0),
    attendees: 8,
    maxAttendees: 50,
    favourite: true,
    bannerPath: Assets.images.shake_y,
    iconPath: Assets.icons.music,
    category: 'Music',
  ),
  EventModel(
    title: "Wild with the Nature",
    hosts: [globalDummyUser.copyWith(name: "John Smith")],
    location: "420 Gala St, San Jose 95125",
    dateTime: DateTime.utc(2023, 12, 20, 20, 0, 0),
    attendees: 8,
    maxAttendees: 50,
    favourite: true,
    bannerPath: Assets.images.nature,
    iconPath: Assets.icons.movieClubs,
    category: 'Muvie Clubs',
  ),
  EventModel(
    title: "Dazzling Of Evermore",
    hosts: [globalDummyUser.copyWith(name: "John Smith")],
    location: "420 Gala St, San Jose 95125",
    dateTime: DateTime.utc(2023, 12, 24, 20, 0, 0),
    attendees: 8,
    maxAttendees: 50,
    favourite: false,
    bannerPath: Assets.images.evermore,
    iconPath: Assets.icons.parties,
    category: 'Parties',
  ),
  EventModel(
    title: "Art Museum: Life of Abstract",
    description:
        "An art museum or art gallery is a building or space for the display of art, usually from the museum's own collection.",
    hosts: [globalDummyUser.copyWith(name: "John Smith")],
    location: "420 Gala St, San Jose 95125",
    dateTime: DateTime.utc(2023, 12, 23, 20, 0, 0),
    attendees: 8,
    maxAttendees: 50,
    favourite: false,
    bannerPath: Assets.images.art_museum,
    iconPath: Assets.icons.book,
    category: 'Book',
  ),
];

Map<DateTime, List<EventModel>> events = {
  DateTime.utc(2023, 11, 20, 0, 0, 0): [
    EventModel(
      title: "International Band Music Festival",
      hosts: [globalDummyUser.copyWith(name: "John Smith")],
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 1, 20, 0, 0),
      attendees: 8,
      maxAttendees: 50,
      favourite: false,
      bannerPath: Assets.images.band_music,
      iconPath: Assets.icons.music,
      category: 'Music',
    ),
    EventModel(
      title: "I'm Going to Shake Y",
      hosts: [globalDummyUser.copyWith(name: "John Smith")],
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 1, 20, 0, 0),
      attendees: 8,
      maxAttendees: 50,
      favourite: true,
      bannerPath: Assets.images.shake_y,
      iconPath: Assets.icons.music,
      category: 'Music',
    ),
    EventModel(
      title: "Wild with the Nature",
      hosts: [globalDummyUser.copyWith(name: "John Smith")],
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 1, 20, 0, 0),
      attendees: 8,
      maxAttendees: 50,
      favourite: true,
      bannerPath: Assets.images.nature,
      iconPath: Assets.icons.movieClubs,
      category: 'Movie Clubs',
    ),
    EventModel(
      title: "Dazzling Of Evermore",
      hosts: [globalDummyUser.copyWith(name: "John Smith")],
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 1, 20, 0, 0),
      attendees: 8,
      maxAttendees: 50,
      favourite: false,
      bannerPath: Assets.images.evermore,
      iconPath: Assets.icons.parties,
      category: 'Parties',
    ),
    EventModel(
      title: "Art Museum: Life of Abstract",
      description:
          "An art museum or art gallery is a building or space for the display of art, usually from the museum's own collection.",
      hosts: [globalDummyUser.copyWith(name: "John Smith")],
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 1, 20, 0, 0),
      attendees: 8,
      maxAttendees: 50,
      favourite: false,
      bannerPath: Assets.images.art_museum,
      iconPath: Assets.icons.book,
      category: 'Book',
    ),
  ],
};
