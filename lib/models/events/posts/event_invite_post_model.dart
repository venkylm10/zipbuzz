class EventInvitePostModel {
  final List<String> phoneNumbers;
  final List<String> images;
  final List<String> names;
  final String senderName;
  final String eventName;
  final String eventDescription;
  final String eventDate;
  final String eventLocation;
  final String eventStart;
  final String eventEnd;
  final int eventId;
  final String banner;
  final InviteData notificationData;

  EventInvitePostModel({
    required this.phoneNumbers,
    required this.images,
    required this.names,
    required this.senderName,
    required this.eventName,
    required this.eventDescription,
    required this.eventDate,
    required this.eventLocation,
    required this.eventStart,
    required this.eventEnd,
    required this.eventId,
    required this.banner,
    required this.notificationData,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'phone_numbers': phoneNumbers,
      'images': images,
      'names': names,
      'sender_name': senderName,
      'event_name': eventName,
      'event_description': eventDescription,
      'event_date': eventDate,
      'event_location': eventLocation,
      'event_start': eventStart,
      'event_end': eventEnd,
      'event_id': eventId,
      'banner': banner,
      'notification_data': notificationData.toMap(),
    };
  }
}

class InviteData {
  final String notificationType = "invited";
  final int eventId;
  final int senderId;
  InviteData({
    required this.eventId,
    required this.senderId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'notification_type': notificationType,
      'event_id': eventId,
      'sender_id': senderId,
    };
  }

  factory InviteData.fromMap(Map<String, dynamic> map) {
    return InviteData(
      eventId: map['event_id'] as int,
      senderId: map['sender_id'] as int,
    );
  }
}
