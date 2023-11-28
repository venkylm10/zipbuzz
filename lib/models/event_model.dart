import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/models/user_model.dart';

class EventModel {
  final String title;
  final String about;
  final List<UserModel> hosts;
  final String location;
  final String date;
  final String startTime;
  final String? endTime;
  final int attendees;
  final int maxAttendees;
  final String category;
  final bool favourite;
  final String bannerPath;
  final String iconPath;
  final bool? isPrivate;
  final int capacity;
  const EventModel({
    required this.title,
    this.hosts = const <UserModel>[],
    required this.location,
    required this.date,
    required this.startTime,
    this.endTime,
    required this.attendees,
    required this.category,
    required this.favourite,
    required this.bannerPath,
    required this.iconPath,
    required this.about,
    required this.maxAttendees,
    this.isPrivate = false,
    required this.capacity,
  });

  EventModel copyWith({
    String? title,
    String? about,
    List<UserModel>? hosts,
    String? location,
    String? date,
    String? startTime,
    String? endTime,
    int? attendees,
    int? maxAttendees,
    String? category,
    bool? favourite,
    String? bannerPath,
    String? iconPath,
    bool? isPrivate,
    int? capacity,
  }) {
    return EventModel(
      title: title ?? this.title,
      about: about ?? this.about,
      hosts: hosts ?? this.hosts,
      location: location ?? this.location,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      attendees: attendees ?? this.attendees,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      category: category ?? this.category,
      favourite: favourite ?? this.favourite,
      bannerPath: bannerPath ?? this.bannerPath,
      iconPath: iconPath ?? this.iconPath,
      isPrivate: isPrivate ?? this.isPrivate,
      capacity: capacity ?? this.capacity,
    );
  }
}

final dummyAbout =
    "Get ready to turn up the color dial and paint the town in a kaleidoscope of hues at the most vibrant house party of the year! We're throwing a bash that's bursting with life and vivacity, and the only rule is to dress like a walking, talking rainbow.\nAs you step through the front door, you'll be transported into a world where the vivid and the vivacious collide! The walls are adorned with neon graffiti, and the dance floor is a glowing tapestry of pulsating lights that'll make you feel like you've walked into a real-life disco fever dream.\nGet Ready to Groove:\nWe're turning up the music, dimming the lights, and transforming our space into a dance paradise\nA community of passionate dance enthusiasts ready to bust moves all night\nFrom salsa to hip-hop, there's something for everyone to enjoy and explore.\nShow off your dance skills in our dance-off competitions, and you could win some fantastic prizes.\nLeave your worries at the door and come dance in a safe, judgment-free zone.";

final dummyEvents = [
  EventModel(
    title: "International Band Music Festival",
    about: dummyAbout,
    hosts: [globalDummyUser.copyWith(name: "John Smith")],
    location: "420 Gala St, San Jose 95125",
    date: DateTime.utc(2023, 11, 20, 20, 0, 0).toString(),
    startTime: DateTime.utc(2023, 11, 20, 20, 0, 0).toString(),
    attendees: 8,
    maxAttendees: 50,
    favourite: false,
    bannerPath: Assets.images.band_music,
    iconPath: Assets.icons.music,
    category: 'Music',
    capacity: 10,
  ),
  EventModel(
    title: "I'm Going to Shake Y",
    about: dummyAbout,
    hosts: [globalDummyUser.copyWith(name: "John Smith")],
    location: "420 Gala St, San Jose 95125",
    date: DateTime.utc(2023, 12, 22, 20, 0, 0).toString(),
    startTime: DateTime.utc(2023, 11, 20, 20, 0, 0).toString(),
    attendees: 8,
    maxAttendees: 50,
    favourite: true,
    bannerPath: Assets.images.shake_y,
    iconPath: Assets.icons.music,
    category: 'Music',
    capacity: 10,
  ),
  EventModel(
    title: "Wild with the Nature",
    about: dummyAbout,
    hosts: [globalDummyUser.copyWith(name: "John Smith")],
    location: "420 Gala St, San Jose 95125",
    date: DateTime.utc(2023, 12, 20, 20, 0, 0).toString(),
    startTime: DateTime.utc(2023, 11, 20, 20, 0, 0).toString(),
    attendees: 8,
    maxAttendees: 50,
    favourite: true,
    bannerPath: Assets.images.nature,
    iconPath: Assets.icons.movieClubs,
    category: 'Muvie Clubs',
    capacity: 10,
  ),
  EventModel(
    title: "Dazzling Of Evermore",
    about: dummyAbout,
    hosts: [globalDummyUser.copyWith(name: "John Smith")],
    location: "420 Gala St, San Jose 95125",
    date: DateTime.utc(2023, 12, 24, 20, 0, 0).toString(),
    startTime: DateTime.utc(2023, 11, 20, 20, 0, 0).toString(),
    attendees: 8,
    maxAttendees: 50,
    favourite: false,
    bannerPath: Assets.images.evermore,
    iconPath: Assets.icons.parties,
    category: 'Parties',
    capacity: 10,
  ),
  EventModel(
    title: "Art Museum: Life of Abstract",
    about:
        "An art museum or art gallery is a building or space for the display of art, usually from the museum's own collection.",
    hosts: [globalDummyUser.copyWith(name: "John Smith")],
    location: "420 Gala St, San Jose 95125",
    date: DateTime.utc(2023, 12, 23, 20, 0, 0).toString(),
    startTime: DateTime.utc(2023, 11, 20, 20, 0, 0).toString(),
    attendees: 8,
    maxAttendees: 50,
    favourite: false,
    bannerPath: Assets.images.art_museum,
    iconPath: Assets.icons.book,
    category: 'Book',
    capacity: 10,
  ),
];

Map<DateTime, List<EventModel>> events = {
  DateTime.utc(2023, 11, 20, 0, 0, 0): [
    EventModel(
      title: "International Band Music Festival",
      about: dummyAbout,
      hosts: [globalDummyUser.copyWith(name: "John Smith")],
      location: "420 Gala St, San Jose 95125",
      date: DateTime.utc(2023, 11, 20, 0, 0, 0).toString(),
      startTime: DateTime.utc(2023, 11, 20, 20, 0, 0).toString(),
      attendees: 8,
      maxAttendees: 50,
      favourite: false,
      bannerPath: Assets.images.band_music,
      iconPath: Assets.icons.music,
      category: 'Music',
    capacity: 10,
    ),
    EventModel(
      title: "I'm Going to Shake Y",
      about: dummyAbout,
      hosts: [globalDummyUser.copyWith(name: "John Smith")],
      location: "420 Gala St, San Jose 95125",
      date: DateTime.utc(2023, 11, 20, 0, 0, 0).toString(),
      startTime: DateTime.utc(2023, 11, 20, 20, 0, 0).toString(),
      attendees: 8,
      maxAttendees: 50,
      favourite: true,
      bannerPath: Assets.images.shake_y,
      iconPath: Assets.icons.music,
      category: 'Music',
    capacity: 10,
    ),
    EventModel(
      title: "Wild with the Nature",
      about: dummyAbout,
      hosts: [globalDummyUser.copyWith(name: "John Smith")],
      location: "420 Gala St, San Jose 95125",
      date: DateTime.utc(2023, 11, 20, 0, 0, 0).toString(),
      startTime: DateTime.utc(2023, 11, 20, 20, 0, 0).toString(),
      attendees: 8,
      maxAttendees: 50,
      favourite: true,
      bannerPath: Assets.images.nature,
      iconPath: Assets.icons.movieClubs,
      category: 'Movie Clubs',
    capacity: 10,
    ),
    EventModel(
      title: "Dazzling Of Evermore",
      about: dummyAbout,
      hosts: [globalDummyUser.copyWith(name: "John Smith")],
      location: "420 Gala St, San Jose 95125",
      date: DateTime.utc(2023, 11, 20, 0, 0, 0).toString(),
      startTime: DateTime.utc(2023, 11, 20, 20, 0, 0).toString(),
      attendees: 8,
      maxAttendees: 50,
      favourite: false,
      bannerPath: Assets.images.evermore,
      iconPath: Assets.icons.parties,
      category: 'Parties',
    capacity: 10,
    ),
    EventModel(
      title: "Art Museum: Life of Abstract",
      about:
          "An art museum or art gallery is a building or space for the display of art, usually from the museum's own collection.",
      hosts: [globalDummyUser.copyWith(name: "John Smith")],
      location: "420 Gala St, San Jose 95125",
      date: DateTime.utc(2023, 11, 20, 0, 0, 0).toString(),
      startTime: DateTime.utc(2023, 11, 20, 20, 0, 0).toString(),
      attendees: 8,
      maxAttendees: 50,
      favourite: false,
      bannerPath: Assets.images.art_museum,
      iconPath: Assets.icons.book,
      category: 'Book',
    capacity: 10,
    ),
  ],
};
