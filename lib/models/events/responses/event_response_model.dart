import 'package:zipbuzz/models/events/event_model.dart';

class EventResponseModel {
  final int id;
  final String banner;
  final String category;
  final String name;
  final String description;
  final String date;
  final String venue;
  final String startTime;
  final String endTime;
  final String hostPic;
  final int hostId;
  final bool eventType;
  final String hostName;
  final int capacity;
  final int filledCapacity;
  final bool isFavorite;
  final String inviteUrl;
  List<ImageModel> images;
  final String status;
  final String userDeviceToken;
  final List<HyperLinks> hyperlinks;
  final bool isPrivate;
  final bool guestList;
  final int notificationId;
  final int members;
  final String groupName;
  final List<TicketType> ticketTypes;
  final String paypalLink;
  final String venmoLink;

  EventResponseModel({
    required this.id,
    required this.banner,
    required this.category,
    required this.name,
    required this.description,
    required this.date,
    required this.venue,
    required this.startTime,
    required this.endTime,
    required this.hostPic,
    required this.hostId,
    required this.eventType,
    required this.hostName,
    required this.capacity,
    required this.filledCapacity,
    this.isFavorite = false,
    this.images = const [],
    this.inviteUrl = "",
    required this.status,
    required this.userDeviceToken,
    required this.hyperlinks,
    required this.isPrivate,
    required this.guestList,
    required this.notificationId,
    required this.members,
    required this.groupName,
    required this.ticketTypes,
    required this.paypalLink,
    required this.venmoLink,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'banner': banner,
      'category': category,
      'name': name,
      'description': description,
      'date': date,
      'venue': venue,
      'start_time': startTime,
      'end_time': endTime,
      'host_pic': hostPic,
      'host_id': hostId,
      'event_type': eventType,
      'host_name': hostName,
      'capacity': capacity,
      'filled_capacity': filledCapacity,
      'is_favorite': isFavorite,
      'images': images.map((image) => image.toMap()).toList(),
      "invite_url": inviteUrl,
      "status": status,
      "user_device_token": userDeviceToken,
      "hyperlinks": hyperlinks.map((hyperlink) => hyperlink.toMap()).toList(),
      'is_private': isPrivate,
      'guest_list': guestList,
      'notification_id': notificationId,
      'members': members,
      'group_name': groupName,
      'ticket_types': ticketTypes.map((ticketType) => ticketType.toMap()).toList(),
      'paypal_link': paypalLink,
      'venmo_link': venmoLink,
    };
  }

  factory EventResponseModel.fromMap(Map<String, dynamic> map) {
    return EventResponseModel(
      id: (map['id'] ?? map['event_id']) as int,
      banner: map['banner'] as String,
      category: map['category'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      date: map['date'] as String,
      venue: map['venue'] as String,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      hostPic: map['host_pic'] as String,
      hostId: map['host_id'] as int,
      eventType: map['event_type'] as bool,
      hostName: map['host_name'] as String,
      capacity: map['capacity'] as int,
      filledCapacity: map['filled_capacity'] as int,
      isFavorite: map['is_favorite'] != null ? map['is_favorite'] as bool : false,
      images: (map['images'] as List).map((e) => ImageModel.fromMap(e)).toList(),
      inviteUrl: map['invite_url'] ?? "",
      status: map['status'],
      userDeviceToken: map['user_device_token'] ?? "",
      hyperlinks: (map['hyperlinks'] as List).map((e) => HyperLinks.fromMap(e)).toList(),
      isPrivate: map['is_private'] as bool,
      guestList: map['guest_list'] as bool,
      notificationId: map['notification_id'] as int,
      members: map['members'] as int,
      groupName: map['group_name'] as String? ?? 'zipbuzz-null',
      ticketTypes: ((map['ticket_types'] ?? []) as List).map((e) => TicketType.fromMap(e)).toList(),
      paypalLink: map['paypal_link'] ?? 'zipbuzz-null',
      venmoLink: map['venmo_link'] ?? 'zipbuzz-null',
    );
  }
}

class ImageModel {
  String imageUrl;
  ImageModel({required this.imageUrl});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'image_url': imageUrl,
    };
  }

  factory ImageModel.fromMap(Map<String, dynamic> map) {
    return ImageModel(
      imageUrl: map['image_url'] as String,
    );
  }
}
