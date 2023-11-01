import 'package:zipbuzz/constants/assets.dart';

class EventModel {
  final String title;
  final String? description;
  final String collabName;
  final String location;
  final DateTime dateTime;
  final int noOfPeople;
  final bool favourite;
  final String bannerPath;
  final String iconPath;
  EventModel({
    required this.title,
    required this.collabName,
    required this.location,
    required this.dateTime,
    required this.noOfPeople,
    required this.favourite,
    required this.bannerPath,
    required this.iconPath,
    this.description,
  });
}

final dummyEvents = [
  EventModel(
    title: "International Band Music Festival",
    collabName: "John Smith",
    location: "420 Gala St, San Jose 95125",
    dateTime: DateTime.utc(2023, 11, 20, 20, 0, 0),
    noOfPeople: 8,
    favourite: false,
    bannerPath: Assets.eventImage.band_music,
    iconPath: Assets.icons.music,
  ),
  EventModel(
    title: "I'm Going to Shake Y",
    collabName: "John Smith",
    location: "420 Gala St, San Jose 95125",
    dateTime: DateTime.utc(2023, 12, 22, 20, 0, 0),
    noOfPeople: 8,
    favourite: true,
    bannerPath: Assets.eventImage.shake_y,
    iconPath: Assets.icons.music,
  ),
  EventModel(
    title: "Wild with the Nature",
    collabName: "John Smith",
    location: "420 Gala St, San Jose 95125",
    dateTime: DateTime.utc(2023, 12, 20, 20, 0, 0),
    noOfPeople: 8,
    favourite: true,
    bannerPath: Assets.eventImage.nature,
    iconPath: Assets.icons.movieClubs,
  ),
  EventModel(
    title: "Dazzling Of Evermore",
    collabName: "John Smith",
    location: "420 Gala St, San Jose 95125",
    dateTime: DateTime.utc(2023, 12, 24, 20, 0, 0),
    noOfPeople: 8,
    favourite: false,
    bannerPath: Assets.eventImage.evermore,
    iconPath: Assets.icons.parties,
  ),
  EventModel(
    title: "Art Museum: Life of Abstract",
    description:
        "An art museum or art gallery is a building or space for the display of art, usually from the museum's own collection.",
    collabName: "John Smith",
    location: "420 Gala St, San Jose 95125",
    dateTime: DateTime.utc(2023, 12, 23, 20, 0, 0),
    noOfPeople: 8,
    favourite: false,
    bannerPath: Assets.eventImage.art_museum,
    iconPath: Assets.icons.book,
  ),
];

Map<DateTime, List<EventModel>> events = {
  DateTime.utc(2023, 11, 1, 0, 0, 0): [
    EventModel(
      title: "International Band Music Festival",
      collabName: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 1, 20, 0, 0),
      noOfPeople: 8,
      favourite: false,
      bannerPath: Assets.eventImage.band_music,
      iconPath: Assets.icons.music,
    ),
    EventModel(
      title: "I'm Going to Shake Y",
      collabName: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 1, 20, 0, 0),
      noOfPeople: 8,
      favourite: true,
      bannerPath: Assets.eventImage.shake_y,
      iconPath: Assets.icons.music,
    ),
    EventModel(
      title: "Wild with the Nature",
      collabName: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 1, 20, 0, 0),
      noOfPeople: 8,
      favourite: true,
      bannerPath: Assets.eventImage.nature,
      iconPath: Assets.icons.movieClubs,
    ),
    EventModel(
      title: "Dazzling Of Evermore",
      collabName: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 1, 20, 0, 0),
      noOfPeople: 8,
      favourite: false,
      bannerPath: Assets.eventImage.evermore,
      iconPath: Assets.icons.parties,
    ),
    EventModel(
      title: "Art Museum: Life of Abstract",
      description:
          "An art museum or art gallery is a building or space for the display of art, usually from the museum's own collection.",
      collabName: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 1, 20, 0, 0),
      noOfPeople: 8,
      favourite: false,
      bannerPath: Assets.eventImage.art_museum,
      iconPath: Assets.icons.book,
    ),
  ],
  DateTime.utc(2023, 11, 5, 0, 0, 0): [
    EventModel(
      title: "International Band Music Festival",
      collabName: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 5, 20, 0, 0),
      noOfPeople: 8,
      favourite: false,
      bannerPath: Assets.eventImage.band_music,
      iconPath: Assets.icons.music,
    ),
    EventModel(
      title: "I'm Going to Shake Y",
      collabName: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 5, 20, 0, 0),
      noOfPeople: 8,
      favourite: true,
      bannerPath: Assets.eventImage.shake_y,
      iconPath: Assets.icons.music,
    ),
    EventModel(
      title: "Wild with the Nature",
      collabName: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 5, 20, 0, 0),
      noOfPeople: 8,
      favourite: true,
      bannerPath: Assets.eventImage.nature,
      iconPath: Assets.icons.movieClubs,
    ),
  ],
  DateTime.utc(2023, 11, 11, 0, 0, 0): [
    EventModel(
      title: "Wild with the Nature",
      collabName: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 11, 20, 0, 0),
      noOfPeople: 8,
      favourite: true,
      bannerPath: Assets.eventImage.nature,
      iconPath: Assets.icons.movieClubs,
    ),
    EventModel(
      title: "Art Museum: Life of Abstract",
      description:
          "An art museum or art gallery is a building or space for the display of art, usually from the museum's own collection.",
      collabName: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 11, 20, 0, 0),
      noOfPeople: 8,
      favourite: false,
      bannerPath: Assets.eventImage.art_museum,
      iconPath: Assets.icons.book,
    ),
  ],
  DateTime.utc(2023, 11, 7, 0, 0, 0): [
    EventModel(
      title: "I'm Going to Shake Y",
      collabName: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 7, 20, 0, 0),
      noOfPeople: 8,
      favourite: true,
      bannerPath: Assets.eventImage.shake_y,
      iconPath: Assets.icons.music,
    ),
    EventModel(
      title: "Wild with the Nature",
      collabName: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 7, 20, 0, 0),
      noOfPeople: 8,
      favourite: true,
      bannerPath: Assets.eventImage.nature,
      iconPath: Assets.icons.movieClubs,
    ),
    EventModel(
      title: "Dazzling Of Evermore",
      collabName: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 7, 20, 0, 0),
      noOfPeople: 8,
      favourite: false,
      bannerPath: Assets.eventImage.evermore,
      iconPath: Assets.icons.parties,
    ),
    EventModel(
      title: "Art Museum: Life of Abstract",
      description:
          "An art museum or art gallery is a building or space for the display of art, usually from the museum's own collection.",
      collabName: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 7, 20, 0, 0),
      noOfPeople: 8,
      favourite: false,
      bannerPath: Assets.eventImage.art_museum,
      iconPath: Assets.icons.book,
    ),
  ],
  DateTime.utc(2023, 11, 20, 0, 0, 0): [
    EventModel(
      title: "International Band Music Festival",
      collabName: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 11, 20, 20, 0, 0),
      noOfPeople: 8,
      favourite: false,
      bannerPath: Assets.eventImage.band_music,
      iconPath: Assets.icons.music,
    ),
  ],
  DateTime.utc(2023, 12, 22, 0, 0, 0): [
    EventModel(
      title: "I'm Going to Shake Y",
      collabName: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 12, 22, 20, 0, 0),
      noOfPeople: 8,
      favourite: true,
      bannerPath: Assets.eventImage.shake_y,
      iconPath: Assets.icons.music,
    ),
    EventModel(
      title: "Wild with the Nature",
      collabName: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 12, 20, 20, 0, 0),
      noOfPeople: 8,
      favourite: true,
      bannerPath: Assets.eventImage.nature,
      iconPath: Assets.icons.movieClubs,
    ),
  ],
  DateTime.utc(2023, 12, 23, 0, 0, 0): [
    EventModel(
      title: "Art Museum: Life of Abstract",
      description:
          "An art museum or art gallery is a building or space for the display of art, usually from the museum's own collection.",
      collabName: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 12, 23, 20, 0, 0),
      noOfPeople: 8,
      favourite: false,
      bannerPath: Assets.eventImage.art_museum,
      iconPath: Assets.icons.book,
    ),
  ],
  DateTime.utc(2023, 12, 24, 0, 0, 0): [
    EventModel(
      title: "Dazzling Of Evermore",
      collabName: "John Smith",
      location: "420 Gala St, San Jose 95125",
      dateTime: DateTime.utc(2023, 12, 24, 20, 0, 0),
      noOfPeople: 8,
      favourite: false,
      bannerPath: Assets.eventImage.evermore,
      iconPath: Assets.icons.parties,
    ),
  ]
};
