import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/utils/constants/assets.dart';

final defaultsProvider = Provider((ref) => Defaults());

class Defaults {
  final profilePictureUrl =
      "https://firebasestorage.googleapis.com/v0/b/zipbuzz-prod.appspot.com/o/defaults%2Fprofile_image%2Fprofile_image.jpg?alt=media&token=1fc0ee5d-f610-4dd6-b774-1d6f2fb5b801";

  final contactAvatarUrl =
      "https://firebasestorage.googleapis.com/v0/b/zipbuzz-prod.appspot.com/o/defaults%2Fprofile_image%2Fdefault_contact_avatar.png?alt=media&token=0ea07905-3b2d-4e50-8b18-b02508306013";

  final bannerPaths = [
    Assets.images.art_museum,
    Assets.images.band_music,
    Assets.images.evermore,
    Assets.images.shake_y,
    Assets.images.nature,
  ];

  final bannerUrls = {
    Assets.images.art_museum:
        "https://firebasestorage.googleapis.com/v0/b/zipbuzz-prod.appspot.com/o/defaults%2Fevent_banners%2Fart_museum.png?alt=media&token=0dfc6060-806d-4332-b74c-1217d06a7a10",
    Assets.images.band_music:
        "https://firebasestorage.googleapis.com/v0/b/zipbuzz-prod.appspot.com/o/defaults%2Fevent_banners%2Fband_music.png?alt=media&token=50a81b5d-f0d3-49b2-80c7-cf287a63dfa9",
    Assets.images.evermore:
        "https://firebasestorage.googleapis.com/v0/b/zipbuzz-prod.appspot.com/o/defaults%2Fevent_banners%2Fdazzling_of_evermore.png?alt=media&token=e54c436c-0893-4800-afc3-cb8ebfcc32cf",
    Assets.images.shake_y:
        "https://firebasestorage.googleapis.com/v0/b/zipbuzz-prod.appspot.com/o/defaults%2Fevent_banners%2Fshake_y.png?alt=media&token=f100329b-740f-403d-960e-5a11b33a827b",
    Assets.images.nature:
        "https://firebasestorage.googleapis.com/v0/b/zipbuzz-prod.appspot.com/o/defaults%2Fevent_banners%2Fwild_with_nature.png?alt=media&token=8cfa2ff2-d49c-46e7-8887-c526b4ae95aa",
  };
}
