import 'package:zipbuzz/models/events/event_invite_members.dart';

class EventModel {
  final int id;
  final String title;
  final String about;
  final int hostId;
  final String hostName;
  final String hostPic;
  final List<String> coHostIds;
  final bool privateGuestList;
  final String location;
  final String date;
  final String startTime;
  final String endTime;
  final int attendees;
  final String category;
  bool isFavorite;
  final String bannerPath;
  final String iconPath;
  final bool isPrivate;
  final int capacity;
  final List<String> imageUrls;
  final List<EventInviteMember> eventMembers;
  final String inviteUrl;
  EventModel({
    required this.id,
    required this.title,
    required this.hostId,
    required this.coHostIds,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.attendees,
    required this.category,
    this.isFavorite = true,
    required this.bannerPath,
    required this.iconPath,
    required this.about,
    required this.isPrivate,
    required this.capacity,
    required this.imageUrls,
    required this.privateGuestList,
    required this.hostName,
    required this.hostPic,
    required this.eventMembers,
    this.inviteUrl = "",
  });

  EventModel copyWith({
    int? id,
    String? title,
    String? about,
    int? hostId,
    String? hostName,
    String? hostPic,
    List<String>? coHostIds,
    List<EventInviteMember>? eventMembers,
    String? location,
    String? date,
    String? startTime,
    String? endTime,
    int? attendees,
    String? category,
    bool? isFavorite,
    String? bannerPath,
    String? iconPath,
    bool? isPrivate,
    int? capacity,
    List<String>? imageUrls,
    bool? privateGuestList,
    String? inviteUrl,
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
      isFavorite: isFavorite ?? this.isFavorite,
      bannerPath: bannerPath ?? this.bannerPath,
      iconPath: iconPath ?? this.iconPath,
      isPrivate: isPrivate ?? this.isPrivate,
      capacity: capacity ?? this.capacity,
      imageUrls: imageUrls ?? this.imageUrls,
      privateGuestList: privateGuestList ?? this.privateGuestList,
      hostName: hostName ?? this.hostName,
      hostPic: hostPic ?? this.hostPic,
      eventMembers: eventMembers ?? this.eventMembers,
      inviteUrl: inviteUrl ?? this.inviteUrl,
    );
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] as int,
      title: map['title'] as String,
      about: map['about'] as String,
      hostId: map['host_id'] as int,
      hostName: map['host_name'] as String,
      hostPic: map['host_pic'] as String,
      coHostIds: (map['coHostIds'] as List).map((e) => e.toString()).toList(),
      location: map['location'] as String,
      date: map['date'] as String,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      attendees: map['capacity'] as int,
      category: map['category'] as String,
      isFavorite: map['is_favourite'] as bool,
      bannerPath: map['banner'] as String,
      iconPath: map['iconPath'] as String,
      isPrivate: map['event_type'] as bool,
      capacity: map['filled_capacity'] as int,
      imageUrls: (map['imageUrls'] as List).map((e) => e.toString()).toList(),
      privateGuestList: map['privateGuestList'] as bool,
      eventMembers: (map['eventMembers'] as List)
          .map((e) => EventInviteMember.fromMap(e as Map<String, dynamic>))
          .toList(),
      inviteUrl: map['invite_url'] ?? ""
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'about': about,
      'host_id': hostId,
      'host_name': hostName,
      'host_pic': hostPic,
      'coHostIds': coHostIds,
      'location': location,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'capacity': attendees,
      'category': category,
      'is_favourite': isFavorite,
      'banner': bannerPath,
      'iconPath': iconPath,
      'event_type': isPrivate,
      'filled_capacity': capacity,
      'imageUrls': imageUrls,
      'privateGuestList': privateGuestList,
      'eventMembers': eventMembers.map((e) => e.toMap()).toList(),
      "invite_url" : inviteUrl,
    };
  }
}

const dummyAbout =
    "Get ready to turn up the color dial and paint the town in a kaleidoscope of hues at the most vibrant house party of the year! We're throwing a bash that's bursting with life and vivacity, and the only rule is to dress like a walking, talking rainbow.\nAs you step through the front door, you'll be transported into a world where the vivid and the vivacious collide! The walls are adorned with neon graffiti, and the dance floor is a glowing tapestry of pulsating lights that'll make you feel like you've walked into a real-life disco fever dream.\nGet Ready to Groove:\nWe're turning up the music, dimming the lights, and transforming our space into a dance paradise\nA community of passionate dance enthusiasts ready to bust moves all night\nFrom salsa to hip-hop, there's something for everyone to enjoy and explore.\nShow off your dance skills in our dance-off competitions, and you could win some fantastic prizes.\nLeave your worries at the door and come dance in a safe, judgment-free zone.";
