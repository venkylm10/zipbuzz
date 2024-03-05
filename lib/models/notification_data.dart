class NotificationData {
  int id;
  String senderName;
  String senderProfilePicture;
  String notificationType;
  String notificationTime;
  int eventId;
  String eventName;
  String deviceToken;
  NotificationData({
    required this.id,
    required this.senderName,
    required this.senderProfilePicture,
    required this.notificationType,
    required this.notificationTime,
    required this.eventId,
    required this.eventName,
    required this.deviceToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender_name': senderName,
      'sender_profile_picture': senderProfilePicture,
      'notification_type': notificationType,
      'notification_time': notificationTime,
      'event_id': eventId,
      'event_name': eventName,
      'device_token': deviceToken,
    };
  }

  factory NotificationData.fromMap(Map<String, dynamic> map) {
    return NotificationData(
      id: map['id'],
      senderName: map['sender_name'],
      senderProfilePicture: map['sender_profile_picture'],
      notificationType: map['notification_type'],
      notificationTime: map['notification_time'],
      eventId: map['event_id'],
      eventName: map['event_name'],
      deviceToken: map['device_token'],
    );
  }
}
