class EventInvitePostModel {
  final List<String> phoneNumbers;
  final String senderName;
  final String eventName;
  final String eventDate;
  final String eventLocation;
  final String eventStart;
  final String eventEnd;

  EventInvitePostModel({
    required this.phoneNumbers,
    required this.senderName,
    required this.eventName,
    required this.eventDate,
    required this.eventLocation,
    required this.eventStart,
    required this.eventEnd,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'phone_numbers': phoneNumbers,
      'sender_name': senderName,
      'event_name': eventName,
      'event_date': eventDate,
      'event_location': eventLocation,
      'event_start': eventStart,
      'event_end': eventEnd,
    };
  }

  factory EventInvitePostModel.fromMap(Map<String, dynamic> map) {
    return EventInvitePostModel(
      phoneNumbers: (map['phone_numbers'] as List).map((e) => e.toString()).toList(),
      senderName: map['sender_name'] as String,
      eventName: map['event_name'] as String,
      eventDate: map['event_date'] as String,
      eventLocation: map['event_location'] as String,
      eventStart: map['event_start'] as String,
      eventEnd: map['event_end'] as String,
    );
  }
}
