class Message {
  final String id;
  final int senderId;
  final String senderPic;
  final String senderName;
  final int eventId;
  final String message;

  /// DateTime utc timestamp, convert it to local in UI
  final String timeStamp;

  const Message({
    required this.id,
    required this.senderId,
    required this.senderPic,
    required this.senderName,
    required this.eventId,
    required this.message,
    required this.timeStamp,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'senderId': senderId,
      'senderPic': senderPic,
      'senderName': senderName,
      'eventId': eventId,
      'message': message,
      'timeStamp': timeStamp,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      senderId: map['senderId'] as int,
      senderPic: map['senderPic'] as String,
      senderName: map['senderName'] as String,
      eventId: map['eventId'] as int,
      message: map['message'] as String,
      timeStamp: map['timeStamp'] as String,
    );
  }
}
