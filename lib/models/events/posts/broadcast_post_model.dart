class BroadcastPostModel {
  String broadcastMessage;
  List<String> phoneNumbers;
  String eventName;
  int eventId;
  int hostId;

  BroadcastPostModel({
    required this.broadcastMessage,
    required this.phoneNumbers,
    required this.eventName,
    required this.eventId,
    required this.hostId,
  });

  Map<String, dynamic> toJson() {
    return {
      'broadcast_message': broadcastMessage,
      'phone_numbers': phoneNumbers,
      'event_name': eventName,
      'event_id': eventId,
      'host_id': hostId,
    };
  }
}
