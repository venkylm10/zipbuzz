import 'package:zipbuzz/models/user_model.dart';

class EventModel {
  final String title;
  final String about;
  final UserModel? host;
  final List<UserModel> coHosts;
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
     this.host,
    required this.coHosts,
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
    UserModel? host,
    List<UserModel>? coHosts,
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
      host: host ?? this.host,
      coHosts: coHosts ?? this.coHosts,
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

final dummyEvents = [];

Map<DateTime, List<EventModel>> events = {};
