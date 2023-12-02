import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/models/message_model.dart';
import 'package:zipbuzz/services/firebase_providers.dart';
import 'package:zipbuzz/services/db_services.dart';

final chatServicesProvider = Provider(
  (ref) => ChatServices(
    auth: ref.read(authProvider),
    dbServices: ref.read(dbServicesProvider),
  ),
);

class ChatServices {
  final FirebaseAuth _auth;
  final DBServices _dbServices;
  const ChatServices(
      {required FirebaseAuth auth, required DBServices dbServices})
      : _auth = auth,
        _dbServices = dbServices;

  Future<void> sendMessage(
      {required String receiverId, required String message}) async {
    final senderId = _auth.currentUser!.uid;
    final users = [senderId, receiverId];

    // unique chat room for two users
    users.sort();
    final chatRoomId = users.join('_');

    final messageId = DateTime.now().microsecondsSinceEpoch.toString();

    final newMessage = Message(
      id: messageId,
      senderId: senderId,
      receiverId: receiverId,
      message: message,
      timeStamp: DateTime.now().toUtc().toString(),
    );

    await _dbServices.sendMessage(
        chatRoomId: chatRoomId,
        messageId: messageId,
        message: newMessage.toMap());
  }

  Stream<DatabaseEvent> getMessages({required String receiverId}) {
    final currentUserId = _auth.currentUser!.uid;
    final users = [currentUserId, receiverId];
    users.sort();
    final chatRoomId = users.join('_');

    return _dbServices.getMessages(chatRoomId: chatRoomId);
  }
}
