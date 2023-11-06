import 'package:zipbuzz/constants/assets.dart';

class EventModel {
  final String title;
  final String? description;
  final String host;
  final String location;
  final DateTime dateTime;
  final int noOfPeople;
  final String category;
  final bool favourite;
  final String bannerPath;
  final String iconPath;
  EventModel({
    required this.title,
    required this.host,
    required this.location,
    required this.dateTime,
    required this.noOfPeople,
    required this.category,
    required this.favourite,
    required this.bannerPath,
    required this.iconPath,
    this.description,
  });
}

final dummyEvents = [
  EventModel(
    title: "International Band Music Festival",
    host: "John Smith",
    location: "420 Gala St, San Jose 95125",
    dateTime: DateTime.utc(2023, 11, 20, 20, 0, 0),
    noOfPeople: 8,
    favourite: false,
    bannerPath: Assets.eventImage.band_music,
    iconPath: Assets.icons.music,
    category: 'Music',
  ),
  EventModel(
    title: "I'm Going to Shake Y",
    host: "John Smith",
    location: "420 Gala St, San Jose 95125",
    dateTime: DateTime.utc(2023, 12, 22, 20, 0, 0),
    noOfPeople: 8,
    favourite: true,
    bannerPath: Assets.eventImage.shake_y,
    iconPath: Assets.icons.music,
    category: 'Music',
  ),
  EventModel(
    title: "Wild with the Nature",
    host: "John Smith",
    location: "420 Gala St, San Jose 95125",
    dateTime: DateTime.utc(2023, 12, 20, 20, 0, 0),
    noOfPeople: 8,
    favourite: true,
    bannerPath: Assets.eventImage.nature,
    iconPath: Assets.icons.movieClubs,
    category: 'Muvie Clubs',
  ),
  EventModel(
    title: "Dazzling Of Evermore",
    host: "John Smith",
    location: "420 Gala St, San Jose 95125",
    dateTime: DateTime.utc(2023, 12, 24, 20, 0, 0),
    noOfPeople: 8,
    favourite: false,
    bannerPath: Assets.eventImage.evermore,
    iconPath: Assets.icons.parties,
    category: 'Parties',
  ),
  EventModel(
    title: "Art Museum: Life of Abstract",
    description:
        "An art museum or art gallery is a building or space for the display of art, usually from the museum's own collection.",
    host: "John Smith",
    location: "420 Gala St, San Jose 95125",
    dateTime: DateTime.utc(2023, 12, 23, 20, 0, 0),
    noOfPeople: 8,
    favourite: false,
    bannerPath: Assets.eventImage.art_museum,
    iconPath: Assets.icons.book,
    category: 'Book',
  ),
];

Map<DateTime, List<EventModel>> events = {
  DateTime.utc(2023, 11, 1, 0, 0, 0): [
    EventModel(
      title: "International Band Music Festival",
      host: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 1, 20, 0, 0),
      noOfPeople: 8,
      favourite: false,
      bannerPath: Assets.eventImage.band_music,
      iconPath: Assets.icons.music,
      category: 'Music',
    ),
    EventModel(
      title: "I'm Going to Shake Y",
      host: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 1, 20, 0, 0),
      noOfPeople: 8,
      favourite: true,
      bannerPath: Assets.eventImage.shake_y,
      iconPath: Assets.icons.music,
      category: 'Music',
    ),
    EventModel(
      title: "Wild with the Nature",
      host: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 1, 20, 0, 0),
      noOfPeople: 8,
      favourite: true,
      bannerPath: Assets.eventImage.nature,
      iconPath: Assets.icons.movieClubs,
      category: 'Movie Clubs',
    ),
    EventModel(
      title: "Dazzling Of Evermore",
      host: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 1, 20, 0, 0),
      noOfPeople: 8,
      favourite: false,
      bannerPath: Assets.eventImage.evermore,
      iconPath: Assets.icons.parties,
      category: 'Parties',
    ),
    EventModel(
      title: "Art Museum: Life of Abstract",
      description:
          "An art museum or art gallery is a building or space for the display of art, usually from the museum's own collection.",
      host: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 1, 20, 0, 0),
      noOfPeople: 8,
      favourite: false,
      bannerPath: Assets.eventImage.art_museum,
      iconPath: Assets.icons.book,
      category: 'Book',
    ),
  ],
  DateTime.utc(2023, 11, 5, 0, 0, 0): [
    EventModel(
      title: "International Band Music Festival",
      host: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 5, 20, 0, 0),
      noOfPeople: 8,
      favourite: false,
      bannerPath: Assets.eventImage.band_music,
      iconPath: Assets.icons.music,
      category: 'Music',
    ),
    EventModel(
      title: "I'm Going to Shake Y",
      host: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 5, 20, 0, 0),
      noOfPeople: 8,
      favourite: true,
      bannerPath: Assets.eventImage.shake_y,
      iconPath: Assets.icons.music,
      category: 'Music',
    ),
    EventModel(
      title: "Wild with the Nature",
      host: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 5, 20, 0, 0),
      noOfPeople: 8,
      favourite: true,
      bannerPath: Assets.eventImage.nature,
      iconPath: Assets.icons.movieClubs,
      category: 'Movie Clubs',
    ),
  ],
  DateTime.utc(2023, 11, 11, 0, 0, 0): [
    EventModel(
      title: "Wild with the Nature",
      host: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 11, 20, 0, 0),
      noOfPeople: 8,
      favourite: true,
      bannerPath: Assets.eventImage.nature,
      iconPath: Assets.icons.movieClubs,
      category: 'Movie Clubs',
    ),
    EventModel(
      title: "Art Museum: Life of Abstract",
      description:
          "An art museum or art gallery is a building or space for the display of art, usually from the museum's own collection.",
      host: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 11, 20, 0, 0),
      noOfPeople: 8,
      favourite: false,
      bannerPath: Assets.eventImage.art_museum,
      iconPath: Assets.icons.book,
      category: 'Book',
    ),
  ],
  DateTime.utc(2023, 11, 7, 0, 0, 0): [
    EventModel(
      title: "I'm Going to Shake Y",
      host: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 7, 20, 0, 0),
      noOfPeople: 8,
      favourite: true,
      bannerPath: Assets.eventImage.shake_y,
      iconPath: Assets.icons.music,
      category: 'Music',
    ),
    EventModel(
      title: "Wild with the Nature",
      host: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 7, 20, 0, 0),
      noOfPeople: 8,
      favourite: true,
      bannerPath: Assets.eventImage.nature,
      iconPath: Assets.icons.movieClubs,
      category: 'Movie Clubs',
    ),
    EventModel(
      title: "Dazzling Of Evermore",
      host: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 7, 20, 0, 0),
      noOfPeople: 8,
      favourite: false,
      bannerPath: Assets.eventImage.evermore,
      iconPath: Assets.icons.parties,
      category: 'Parties',
    ),
    EventModel(
      title: "Art Museum: Life of Abstract",
      description:
          "An art museum or art gallery is a building or space for the display of art, usually from the museum's own collection.",
      host: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 7, 20, 0, 0),
      noOfPeople: 8,
      favourite: false,
      bannerPath: Assets.eventImage.art_museum,
      iconPath: Assets.icons.book,
      category: 'Book',
    ),
  ],
  DateTime.utc(2023, 11, 20, 0, 0, 0): [
    EventModel(
      title: "International Band Music Festival",
      host: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 20, 20, 0, 0),
      noOfPeople: 8,
      favourite: false,
      bannerPath: Assets.eventImage.band_music,
      iconPath: Assets.icons.music,
      category: 'Music',
    ),
  ],
  DateTime.utc(2023, 12, 22, 0, 0, 0): [
    EventModel(
      title: "I'm Going to Shake Y",
      host: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 12, 22, 20, 0, 0),
      noOfPeople: 8,
      favourite: true,
      bannerPath: Assets.eventImage.shake_y,
      iconPath: Assets.icons.music,
      category: 'Music',
    ),
    EventModel(
      title: "Wild with the Nature",
      host: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 12, 20, 20, 0, 0),
      noOfPeople: 8,
      favourite: true,
      bannerPath: Assets.eventImage.nature,
      iconPath: Assets.icons.movieClubs,
      category: 'Movie Clubs',
    ),
  ],
  DateTime.utc(2023, 12, 23, 0, 0, 0): [
    EventModel(
      title: "Art Museum: Life of Abstract",
      description:
          "An art museum or art gallery is a building or space for the display of art, usually from the museum's own collection.",
      host: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 12, 23, 20, 0, 0),
      noOfPeople: 8,
      favourite: false,
      bannerPath: Assets.eventImage.art_museum,
      iconPath: Assets.icons.book,
      category: 'Book',
    ),
  ],
  DateTime.utc(2023, 12, 24, 0, 0, 0): [
    EventModel(
      title: "Dazzling Of Evermore",
      host: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 12, 24, 20, 0, 0),
      noOfPeople: 8,
      favourite: false,
      bannerPath: Assets.eventImage.evermore,
      iconPath: Assets.icons.parties,
      category: 'Parties',
    ),
  ]
};
