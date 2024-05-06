import 'package:flutter_riverpod/flutter_riverpod.dart';

final defaultsProvider = Provider((ref) => Defaults());

class Defaults {
  final profilePictureUrl =
      "https://firebasestorage.googleapis.com/v0/b/zipbuzz-prod.appspot.com/o/defaults%2Fprofile_image%2Fprofile_image.png?alt=media&token=a27ff466-2096-4f85-82ff-0d9d74118814";

  final contactAvatarUrl =
      "https://firebasestorage.googleapis.com/v0/b/zipbuzz-prod.appspot.com/o/defaults%2Fprofile_image%2Fdefault_contact_avatar.png?alt=media&token=0ea07905-3b2d-4e50-8b18-b02508306013";
}
