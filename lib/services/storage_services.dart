import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/services/firebase_providers.dart';

final storageServicesProvider =
    Provider((ref) => StorageSerives(storage: ref.read(storageProvider)));

class StorageConstants {
  static const String userData = 'userData';
  static const String eventBannersFolder = 'eventBanners';
  static const String eventBanner = 'eventBanner';
  static const String profilePic = 'profilePic';
}

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

  Future<String?> uploadProfilePic(
      {required String uid, required File file}) async {
    final filename = "profilePic_${file.path.split('/').last}";
    try {
      await deleteProfilePic(uid: uid);
    } catch (e) {
      debugPrint(e.toString());
    }

    try {
      final ref = _storage
          .ref()
          .child(StorageConstants.userData)
          .child(uid)
          .child(StorageConstants.profilePic)
          .child(filename);
      UploadTask uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<void> deleteProfilePic({required String uid}) async {
    try {
      final ref = _storage
          .ref()
          .child(StorageConstants.userData)
          .child(uid)
          .child(StorageConstants.profilePic);
      ListResult result = await ref.listAll();
      for (final fileRef in result.items) {
        await fileRef.delete();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteFolderContents(Reference folderRef) async {
    ListResult result = await folderRef.listAll();
    for (var item in result.items) {
      await deleteFolderContents(item);
      await item.delete();
    }
  }

  /// caution: this will delete all the data of the user from storage
  Future<void> deleteUserData({required String uid}) async {
    try {
      final ref = _storage.ref().child(StorageConstants.userData).child(uid);
      await deleteFolderContents(ref);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<String?> uploadEventBanner({
    required String uid,
    required String eventId,
    required File file,
  }) async {
    final filename = "eventBanner_${eventId}_${file.path.split('/').last}";
    try {
      final ref = _storage
          .ref()
          .child(StorageConstants.userData)
          .child(uid)
          .child(StorageConstants.eventBannersFolder)
          .child(eventId)
          .child(StorageConstants.eventBanner)
          .child(filename);
      UploadTask uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<List<String>> uploadEventImages(
      {required String uid,
      required String eventId,
      required List<File> images}) async {
    List<String> downloadUrls = [];
    for (final file in images) {
      final filename = "eventBanner_${eventId}_${file.path.split('/').last}";
      try {
        final ref = _storage
            .ref()
            .child(StorageConstants.userData)
            .child(uid)
            .child(StorageConstants.eventBannersFolder)
            .child(eventId)
            .child(StorageConstants.eventBanner)
            .child(filename);
        UploadTask uploadTask = ref.putFile(file);
        final snapshot = await uploadTask;
        final url = await snapshot.ref.getDownloadURL();
        downloadUrls.add(url);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    return downloadUrls;
  }
}
