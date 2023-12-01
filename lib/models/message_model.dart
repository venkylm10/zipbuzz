class Message {
  final String senderId;
  final String receiverId;
  final String message;

  /// DateTime utc timestamp, convert it to local in UI
  final String timeStamp;

  const Message({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timeStamp,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timeStamp': timeStamp,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] as String,
      message: map['message'] as String,
      timeStamp: map['timeStamp'] as String,
    );
  }
}
