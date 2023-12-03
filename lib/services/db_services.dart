import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/constants/database_constants.dart';
import 'package:zipbuzz/models/user_model.dart';
import 'package:zipbuzz/services/firebase_providers.dart';

final dbServicesProvider = Provider((ref) => DBServices(
      database: ref.read(databaseProvider),
      ref: ref,
    ));

class DBServices {
  final FirebaseDatabase _database;
  final Ref _ref;
  const DBServices({required FirebaseDatabase database, required Ref ref})
      : _database = database,
        _ref = ref;

  Future<void> sendMessage(
      {required String chatRoomId,
      required String messageId,
      required Map<String, dynamic> message}) async {
    await _database
        .ref(DatabaseConstants.chatRoomCollection)
        .child(chatRoomId)
        .child(messageId)
        .set(message);
  }

  Stream<DatabaseEvent> getMessages({required String chatRoomId}) {
    return _database
        .ref(DatabaseConstants.chatRoomCollection)
        .child(chatRoomId)
        .onValue;
  }

  Future<void> createEvent(
      {required String eventId,
      required String zipcode,
      required Map<String, dynamic> event}) async {
    await _database
        .ref(DatabaseConstants.eventsCollection)
        .child(zipcode)
        .child(eventId)
        .set(event);
  }

  Stream<DatabaseEvent> getEvents({required String zipcode}) {
    return _database
        .ref(DatabaseConstants.eventsCollection)
        .child(zipcode)
        .onValue;
  }

  Future<void> createUser({required UserModel user}) async {
    debugPrint("CREATING NEW USER");
    await _database
        .ref(DatabaseConstants.usersCollection)
        .child(user.uid)
        .set(user.toMap());
  }

  Future<void> updateUser(String uid, Map<String, dynamic> map) async {
    await _database
        .ref(DatabaseConstants.usersCollection)
        .child(uid)
        .update(map);
  }

  Stream<DatabaseEvent> getUserData(String uid) {
    return _database
        .ref(DatabaseConstants.usersCollection)
        .child(uid)
        .onValue;
  }
}
