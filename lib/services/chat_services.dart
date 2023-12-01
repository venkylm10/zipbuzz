import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/constants/firestore_constants.dart';
import 'package:zipbuzz/models/message_model.dart';
import 'package:zipbuzz/services/firebase_providers.dart';

final chatServicesProvider = Provider(
  (ref) => ChatServices(
    auth: ref.read(authProvider),
    firestore: ref.read(
      firestoreProvider,
    ),
  ),
);

class ChatServices {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  const ChatServices(
      {required FirebaseAuth auth, required FirebaseFirestore firestore})
      : _auth = auth,
        _firestore = firestore;

  Future<void> sendMessage(
      {required String receiverId, required String message}) async {
    final senderId = _auth.currentUser!.uid;
    final users = [senderId, receiverId];

    // unique chat room for two users
    users.sort();
    final chatRoomId = users.join('_');

    final newMessage = Message(
      senderId: senderId,
      receiverId: receiverId,
      message: message,
      timeStamp: DateTime.now().toUtc().toString(),
    );

    await _firestore
        .collection(FirestoreConstants.chatRoomCollection)
        .doc(chatRoomId)
        .collection(FirestoreConstants.messageCollection)
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages({required String receiverId}) {
    final currentUserId = _auth.currentUser!.uid;
    final users = [currentUserId, receiverId];
    users.sort();
    final chatRoomId = users.join('_');

    return _firestore
        .collection(FirestoreConstants.chatRoomCollection)
        .doc(chatRoomId)
        .collection(FirestoreConstants.messageCollection)
        .orderBy('timeStamp', descending: false)
        .snapshots();
  }

}
