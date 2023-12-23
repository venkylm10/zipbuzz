class EventInvitePostModel {
  final List<String> phoneNumbers;
  final List<String> images;
  final List<String> names;
  final String senderName;
  final String eventName;
  final String eventDate;
  final String eventLocation;
  final String eventStart;
  final String eventEnd;
  final int eventId;

  EventInvitePostModel({
    required this.phoneNumbers,
    required this.images,
    required this.names,
    required this.senderName,
    required this.eventName,
    required this.eventDate,
    required this.eventLocation,
    required this.eventStart,
    required this.eventEnd,
    required this.eventId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'phone_numbers': phoneNumbers,
      'images': images,
      'names': names,
      'sender_name': senderName,
      'event_name': eventName,
      'event_date': eventDate,
      'event_location': eventLocation,
      'event_start': eventStart,
      'event_end': eventEnd,
      'event_id': eventId,
    };
  }
}
