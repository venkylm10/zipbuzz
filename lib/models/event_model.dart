class EventModel {
  final String id;
  final String title;
  final String about;
  final String hostId;
  final List<String> coHostIds;
  final List<String> guestIds;
  final bool privateGuestList;
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
  final List<String> imageUrls;
  const EventModel({
    required this.id,
    required this.title,
    required this.hostId,
    required this.coHostIds,
    required this.guestIds,
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
    required this.imageUrls,
    required this.privateGuestList,
  });

  EventModel copyWith({
    String? id,
    String? title,
    String? about,
    String? hostId,
    List<String>? coHostIds,
    List<String>? guestIds,
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
    List<String>? imageUrls,
    bool? privateGuestList,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      about: about ?? this.about,
      hostId: hostId ?? this.hostId,
      coHostIds: coHostIds ?? this.coHostIds,
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
      imageUrls: imageUrls ?? this.imageUrls,
      guestIds: guestIds ?? this.guestIds,
      privateGuestList: privateGuestList ?? this.privateGuestList,
    );
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] as String,
      title: map['title'] as String,
      about: map['about'] as String,
      hostId: map['hostId'] as String,
      coHostIds: (map['coHostIds'] as List).map((e) => e.toString()).toList(),
      guestIds: (map['guestIds'] as List).map((e) => e.toString()).toList(),
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
      imageUrls: (map['imageUrls'] as List).map((e) => e.toString()).toList(),
      privateGuestList: map['privateGuestList'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'about': about,
      'hostId': hostId,
      'coHostIds': coHostIds,
      'guestIds': guestIds,
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
      'imageUrls': imageUrls,
      'privateGuestList': privateGuestList,
    };
  }
}

const dummyAbout =
    "Get ready to turn up the color dial and paint the town in a kaleidoscope of hues at the most vibrant house party of the year! We're throwing a bash that's bursting with life and vivacity, and the only rule is to dress like a walking, talking rainbow.\nAs you step through the front door, you'll be transported into a world where the vivid and the vivacious collide! The walls are adorned with neon graffiti, and the dance floor is a glowing tapestry of pulsating lights that'll make you feel like you've walked into a real-life disco fever dream.\nGet Ready to Groove:\nWe're turning up the music, dimming the lights, and transforming our space into a dance paradise\nA community of passionate dance enthusiasts ready to bust moves all night\nFrom salsa to hip-hop, there's something for everyone to enjoy and explore.\nShow off your dance skills in our dance-off competitions, and you could win some fantastic prizes.\nLeave your worries at the door and come dance in a safe, judgment-free zone.";

final dummyEvents = [];

Map<DateTime, List<EventModel>> events = {};
