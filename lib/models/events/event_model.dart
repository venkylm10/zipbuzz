import 'package:zipbuzz/models/events/event_invite_members.dart';
import 'package:zipbuzz/models/events/responses/event_response_model.dart';
import 'package:zipbuzz/models/events/responses/favorite_event_model.dart';
import 'package:zipbuzz/utils/constants/assets.dart';

class EventModel {
  final int id;
  final String title;
  final String about;
  final int hostId;
  final String hostName;
  final String hostPic;
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
  List<EventInviteMember> eventMembers;
  final String inviteUrl;
  String status;
  String userDeviceToken;
  final List<HyperLinks> hyperlinks;
  final int notificationId;
  int members;
  EventModel({
    required this.id,
    required this.title,
    required this.hostId,
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
    required this.status,
    required this.userDeviceToken,
    required this.hyperlinks,
    this.notificationId = -1,
    required this.members,
  });

  EventModel copyWith({
    int? id,
    String? title,
    String? about,
    int? hostId,
    String? hostName,
    String? hostPic,
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
    String? status,
    String? userDeviceToken,
    List<HyperLinks>? hyperlinks,
    int? members,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      about: about ?? this.about,
      hostId: hostId ?? this.hostId,
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
      status: status ?? this.status,
      userDeviceToken: userDeviceToken ?? this.userDeviceToken,
      hyperlinks: hyperlinks ?? this.hyperlinks,
      members: members ?? this.members,
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
      inviteUrl: map['invite_url'] ?? "",
      status: map['status'] ?? "nothing",
      imageUrls: (map['imageUrls'] as List).map((e) => e.toString()).toList(),
      privateGuestList: map['privateGuestList'] as bool,
      eventMembers: (map['eventMembers'] as List)
          .map((e) => EventInviteMember.fromMap(e as Map<String, dynamic>))
          .toList(),
      userDeviceToken: map['user_device_token'] ?? "",
      hyperlinks: (map['hyperlinks'] as List)
          .map((e) => HyperLinks.fromMap(e as Map<String, dynamic>))
          .toList(),
      notificationId: map['notificationId'] ?? -1,
      members: map['members'] ?? 0,
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
      "invite_url": inviteUrl,
      "status": status,
    };
  }

  factory EventModel.fromFavEventModel(FavoriteEventModel fav) {
    return EventModel(
      id: fav.eventId,
      title: fav.name,
      hostId: fav.hostId,
      location: fav.venue,
      date: fav.date,
      startTime: fav.startTime,
      endTime: fav.endTime,
      attendees: fav.filledCapacity,
      category: fav.category,
      isFavorite: true,
      bannerPath: fav.image,
      iconPath: interestIcons[fav.category]!,
      about: fav.description,
      isPrivate: fav.eventType,
      capacity: fav.capacity,
      imageUrls: [],
      privateGuestList: true,
      hostName: fav.hostName,
      hostPic: fav.hostPic,
      eventMembers: [],
      inviteUrl: fav.inviteUrl,
      status: fav.status,
      userDeviceToken: fav.userDeviceToken,
      hyperlinks: fav.hyperlinks,
      notificationId: fav.notificationId,
      members: fav.members,
    );
  }

  factory EventModel.fromEventResModel(EventResponseModel res) {
    return EventModel(
      id: res.id,
      title: res.name,
      hostId: res.hostId,
      location: res.venue,
      date: res.date,
      startTime: res.startTime,
      endTime: res.endTime,
      attendees: res.filledCapacity,
      category: res.category,
      isFavorite: res.isFavorite,
      bannerPath: res.banner,
      iconPath: interestIcons[res.category]!,
      about: res.description,
      isPrivate: res.isPrivate,
      privateGuestList: !res.guestList,
      capacity: res.capacity,
      imageUrls: res.images.map((e) => e.imageUrl).toList(),
      hostName: res.hostName,
      hostPic: res.hostPic,
      eventMembers: [],
      inviteUrl: res.inviteUrl,
      status: res.status,
      userDeviceToken: res.userDeviceToken,
      hyperlinks: res.hyperlinks,
      notificationId: res.notificationId,
      members: res.members,
    );
  }
}

class HyperLinks {
  final int id;
  final String urlName;
  final String url;
  HyperLinks({required this.id, required this.urlName, required this.url});

  factory HyperLinks.fromMap(Map<String, dynamic> map) {
    return HyperLinks(
      id: map['id'] as int,
      urlName: map['url_name'] as String,
      url: map['url'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url_name': urlName,
      'url': url,
    };
  }
}
