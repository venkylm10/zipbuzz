import 'package:zipbuzz/models/user_model.dart';

class EventModel {
  final String id;
  final String title;
  final String about;
  final UserModel? host;
  final List<UserModel> coHosts;
  final String location;
  final String date;
  final String startTime;
  final String? endTime;
  final int attendees;
  final String category;
  final bool favourite;
  final String bannerPath;
  final String iconPath;
  final bool isPrivate;
  final int capacity;
  const EventModel({
    required this.id,
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
    required this.isPrivate,
    required this.capacity,
  });

  EventModel copyWith({
    String? id,
    String? title,
    String? about,
    UserModel? host,
    List<UserModel>? coHosts,
    String? location,
    String? date,
    String? startTime,
    String? endTime,
    int? attendees,
    String? category,
    bool? favourite,
    String? bannerPath,
    String? iconPath,
    bool? isPrivate,
    int? capacity,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      about: about ?? this.about,
      host: host ?? this.host,
      coHosts: coHosts ?? this.coHosts,
      location: location ?? this.location,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      attendees: attendees ?? this.attendees,
      category: category ?? this.category,
      favourite: favourite ?? this.favourite,
      bannerPath: bannerPath ?? this.bannerPath,
      iconPath: iconPath ?? this.iconPath,
      isPrivate: isPrivate ?? this.isPrivate,
      capacity: capacity ?? this.capacity,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'about': about,
      'host': host?.toMap(),
      'coHosts': coHosts.map((x) => x.toMap()).toList(),
      'location': location,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'attendees': attendees,
      'category': category,
      'favourite': favourite,
      'bannerPath': bannerPath,
      'iconPath': iconPath,
      'isPrivate': isPrivate,
      'capacity': capacity,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] as String,
      title: map['title'] as String,
      about: map['about'] as String,
      host: map['host'] != null
          ? UserModel.fromMap(map['host'] as Map<String, dynamic>)
          : null,
      coHosts: ((map['coHosts'] as List<int>).map<UserModel>(
        (x) => UserModel.fromMap(x as Map<String, dynamic>),
      )).toList(),
      location: map['location'] as String,
      date: map['date'] as String,
      startTime: map['startTime'] as String,
      endTime: map['endTime'] != null ? map['endTime'] as String : null,
      attendees: map['attendees'] as int,
      category: map['category'] as String,
      favourite: map['favourite'] as bool,
      bannerPath: map['bannerPath'] as String,
      iconPath: map['iconPath'] as String,
      isPrivate: map['isPrivate'] as bool,
      capacity: map['capacity'] as int,
    );
  }
}

const dummyAbout =
    "Get ready to turn up the color dial and paint the town in a kaleidoscope of hues at the most vibrant house party of the year! We're throwing a bash that's bursting with life and vivacity, and the only rule is to dress like a walking, talking rainbow.\nAs you step through the front door, you'll be transported into a world where the vivid and the vivacious collide! The walls are adorned with neon graffiti, and the dance floor is a glowing tapestry of pulsating lights that'll make you feel like you've walked into a real-life disco fever dream.\nGet Ready to Groove:\nWe're turning up the music, dimming the lights, and transforming our space into a dance paradise\nA community of passionate dance enthusiasts ready to bust moves all night\nFrom salsa to hip-hop, there's something for everyone to enjoy and explore.\nShow off your dance skills in our dance-off competitions, and you could win some fantastic prizes.\nLeave your worries at the door and come dance in a safe, judgment-free zone.";

final dummyEvents = [];

Map<DateTime, List<EventModel>> events = {};
