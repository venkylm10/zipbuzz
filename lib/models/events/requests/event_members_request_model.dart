class EventMembersRequestModel {
  final int eventId;

  const EventMembersRequestModel({
    required this.eventId,
  });

  Map<String, dynamic> toMap() {
    return {
      'event_id': eventId,
    };
  }

  static EventMembersRequestModel fromMap(Map<String, dynamic> map) {
    return EventMembersRequestModel(
      eventId: map['event_id'] as int,
    );
  }
}
