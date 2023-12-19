import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/message_model.dart';
import 'package:zipbuzz/services/db_services.dart';

final chatServicesProvider = Provider(
  (ref) => ChatServices(
    ref: ref,
    dbServices: ref.read(dbServicesProvider),
  ),
);

class ChatServices {
  final Ref _ref;
  final DBServices _dbServices;
  const ChatServices({required Ref ref, required DBServices dbServices})
      : _ref = ref,
        _dbServices = dbServices;

  Future<void> sendMessage({required int eventId, required String message}) async {
    debugPrint("SENDING MESSAGE");
    final currentUser = _ref.read(userProvider);
    final senderId = currentUser.id;
    final messageId = DateTime.now().microsecondsSinceEpoch.toString();
    final newMessage = Message(
        id: messageId,
        senderId: senderId,
        senderName: currentUser.name,
        senderPic: currentUser.imageUrl,
        eventId: eventId,
        message: message,
        timeStamp: DateTime.now().toUtc().toString());
    await _dbServices.sendMessage(
        eventId: eventId, messageId: messageId, message: newMessage.toMap());
    debugPrint("MESSAGE SENT");
  }

  Stream<List<Message>> getMessages({required int eventId}) {
    try {
      return _dbServices.getMessages(eventId: eventId).map((event) {
        if (event.snapshot.value != null) {
          final data = event.snapshot.value as Map;
          List<Message> messages = data.entries
              .map((entry) => Message.fromMap(Map<String, dynamic>.from(entry.value)))
              .toList();

          // Sending in reverse order so that the latest message is at the bottom
          messages.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
          return messages;
        } else {
          return [];
        }
      });
    } catch (e) {
      debugPrint("Error getting messages: $e");
      rethrow;
    }
  }
}
