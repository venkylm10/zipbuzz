class SendInviteNotificationModel {
  String senderName;
  List<String> phoneNumbers;
  String eventName;
  int eventId;
  int hostId;

  SendInviteNotificationModel({
    required this.senderName,
    required this.phoneNumbers,
    required this.eventName,
    required this.eventId,
    required this.hostId,
  });

  factory SendInviteNotificationModel.fromMap(Map<String, dynamic> map) {
    return SendInviteNotificationModel(
      senderName: map['sender_name'],
      phoneNumbers: List<String>.from(map['phone_numbers']),
      eventName: map['event_name'],
      eventId: map['event_id'],
      hostId: map['host_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sender_name': senderName,
      'phone_numbers': phoneNumbers,
      'event_name': eventName,
      'event_id': eventId,
      'host_id': hostId,
    };
  }
}
