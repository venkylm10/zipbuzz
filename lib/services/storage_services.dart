import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/services/firebase_providers.dart';

final storageServicesProvider =
    Provider((ref) => StorageSerives(storage: ref.read(storageProvider)));

class StorageSerives {
  final FirebaseStorage _storage;
  const StorageSerives({required FirebaseStorage storage}) : _storage = storage;

  Future<String?> uploadFile({
    required String path,
    required String id,
    required File file,
  }) async {
    try {
      final ref = _storage.ref().child(path).child(id);
      UploadTask uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}
