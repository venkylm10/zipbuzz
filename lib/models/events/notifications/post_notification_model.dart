class PostNotificationModel {
  final int userId;
  final int senderId;
  final int eventId;
  final int groupId;
  final String notificationType;

  const PostNotificationModel({
    required this.userId,
    required this.senderId,
    this.eventId = 0,
    this.groupId = 0,
    required this.notificationType,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'sender_id': senderId,
      'event_id': eventId,
      'group_id': groupId,
      'notification_type': notificationType,
    };
  }
}
