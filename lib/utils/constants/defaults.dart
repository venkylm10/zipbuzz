import 'package:flutter_riverpod/flutter_riverpod.dart';

final defaultsProvider = Provider((ref) => Defaults());

class Defaults {
  final profilePictureUrl =
      "https://firebasestorage.googleapis.com/v0/b/zipbuzz-prod.appspot.com/o/defaults%2Fprofile_image%2Fprofile_image.jpg?alt=media&token=1fc0ee5d-f610-4dd6-b774-1d6f2fb5b801";

  final contactAvatarUrl =
      "https://firebasestorage.googleapis.com/v0/b/zipbuzz-prod.appspot.com/o/defaults%2Fprofile_image%2Fdefault_contact_avatar.png?alt=media&token=0ea07905-3b2d-4e50-8b18-b02508306013";

}
