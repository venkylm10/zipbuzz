import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/models/user/user_model.dart';
import 'package:zipbuzz/utils/constants/assets.dart';

final userProvider = StateProvider<UserModel>((ref) {
  return globalDummyUser;
});

final globalDummyUser = UserModel(
  id: 1,
  name: "Zipbuzz User",
  email: "zipbuzz.user@gmail.com",
  handle: "zipbuzz_user",
  imageUrl:
      "https://firebasestorage.googleapis.com/v0/b/zipbuzz-prod.appspot.com/o/defaults%2Fprofile_image%2Fprofile_image.jpg?alt=media&token=1fc0ee5d-f610-4dd6-b774-1d6f2fb5b801",
  isAmbassador: true,
  eventsHosted: 8,
  rating: 4.5,
  zipcode: "95120",
  mobileNumber: "+14082383322",
  linkedinId: "https://www.linkedin.com/company/linkedin/",
  instagramId: "https://www.instagram.com/instagram/",
  twitterId: "https://twitter.com/X/",
  interests: allInterests.entries.map((e) => e.key).toList().sublist(0, 4),
  about:
      "I'm here to ensure that your experience is nothing short of extraordinary. With a passion for creating unforgettable moments and a knack for connecting with people, I thrive on the energy of the event and the joy it brings to all attendees. I'm your go-to person for any questions, assistance, or just a friendly chat.\n\nMy commitment is to make you feel welcome, entertained, and truly part of the event's magic. So, let's embark on this exciting journey together, and I promise you won't leave without a smile and wonderful memories to cherish.",
  eventUids: [],
  pastEventUids: [],
  city: "San Jose",
  country: "USA",
  countryDialCode: "+1",
);
