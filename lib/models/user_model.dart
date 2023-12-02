import 'package:zipbuzz/constants/assets.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String handle;
  final String position;
  final int eventsHosted;
  final double rating;
  final String imageUrl;
  final String mobileNumber;
  final String zipcode;
  final String? linkedinId;
  final String? instagramId;
  final String? twitterId;
  final List<String> interests;
  final String about;
  final List<String>? eventUids;
  final List<String>? pastEventUids;
  final String city;
  final String country;
  final String countryDialCode;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.handle,
    required this.position,
    required this.eventsHosted,
    required this.rating,
    required this.zipcode,
    required this.interests,
    required this.about,
    required this.imageUrl,
    required this.mobileNumber,
    required this.city,
    required this.country,
    required this.countryDialCode,
    this.linkedinId,
    this.instagramId,
    this.twitterId,
    this.eventUids,
    this.pastEventUids,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'email': email,
      'handle': handle,
      'position': position,
      'eventsHosted': eventsHosted,
      'rating': rating,
      'imageUrl': imageUrl,
      'mobileNumber': mobileNumber,
      'zipcode': zipcode,
      'linkedinId': linkedinId,
      'instagramId': instagramId,
      'twitterId': twitterId,
      'interests': interests,
      'about': about,
      'eventUids': eventUids,
      'pastEventUids': pastEventUids,
      'city': city,
      'country': country,
      'countryDialCode': countryDialCode,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'] != null ? map['name'] as String : "",
      email: map['email'] != null ? map['email'] as String : "",
      handle: map['handle'] != null ? map['handle'] as String : "",
      position: map['position'] != null ? map['position'] as String : "",
      eventsHosted:
          map['eventsHosted'] != null ? map['eventsHosted'] as int : 0,
      rating: map['rating'] != null
          ? (map['rating'].runtimeType == int
              ? map['rating'].toDouble()
              : map['rating'])
          : 0.0,
      imageUrl: map['imageUrl'] != null
          ? map['imageUrl'] as String
          : Assets.images.profile,
      mobileNumber:
          map['mobileNumber'] != null ? map['mobileNumber'] as String : "",
      zipcode: map['zipcode'] != null ? map['zipcode'] as String : "",
      linkedinId: map['linkedinId'] != null ? map['linkedinId'] as String : "",
      instagramId:
          map['instagramId'] != null ? map['instagramId'] as String : null,
      twitterId: map['twitterId'] != null ? map['twitterId'] as String : null,
      interests: map['interests'] != null
          ? (map['interests'] as List).map((e) => e.toString()).toList()
          : [],
      about: map['about'] != null ? map['about'] as String : "New to ZipBuzz",
      eventUids: map['eventUids'] != null
          ? (map['eventUids'] as List).map((e) => e.toString()).toList()
          : <String>[],
      pastEventUids: map['pastEventUids'] != null
          ? (map['pastEventUids'] as List).map((e) => e.toString()).toList()
          : <String>[],
      city: map['city'] != null ? map['city'] as String : "",
      country: map['country'] != null ? map['country'] as String : "",
      countryDialCode:
          map['countryDialCode'] != null ? map['countryDialCode'] as String : "",
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? handle,
    String? about,
    String? position,
    int? eventsHosted,
    double? rating,
    String? imageUrl,
    String? mobileNumber,
    String? zipcode,
    String? linkedinId,
    String? instagramId,
    String? twitterId,
    List<String>? interests,
    List<String>? eventUids,
    List<String>? pastEventUids,
    String? city,
    String? country,
    String? countryDialCode,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      handle: handle ?? this.handle,
      position: position ?? this.position,
      eventsHosted: eventsHosted ?? this.eventsHosted,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      zipcode: zipcode ?? this.zipcode,
      linkedinId: linkedinId ?? this.linkedinId,
      instagramId: instagramId ?? this.instagramId,
      twitterId: twitterId ?? this.twitterId,
      interests: interests ?? this.interests,
      about: about ?? this.about,
      eventUids: eventUids ?? this.eventUids,
      pastEventUids: pastEventUids ?? this.pastEventUids,
      city: city ?? this.city,
      country: country ?? this.country,
      countryDialCode: countryDialCode ?? this.countryDialCode,
    );
  }

  UserModel getClone() {
    final map = toMap();
    return UserModel.fromMap(map);
  }
}

final globalDummyUser = UserModel(
  uid: 'dummyUser',
  name: "Alex Lee",
  email: "example@gmail.com",
  handle: "bealexlee",
  imageUrl: Assets.images.profile,
  position: "Brand Ambassadar",
  eventsHosted: 8,
  rating: 4.5,
  zipcode: "",
  mobileNumber: "",
  linkedinId: "alex-lee-2530611a",
  instagramId: "The_alex_lee",
  twitterId: "bealexlee",
  interests: allInterests.entries.map((e) => e.key).toList().sublist(0, 4),
  about:
      "I'm here to ensure that your experience is nothing short of extraordinary. With a passion for creating unforgettable moments and a knack for connecting with people, I thrive on the energy of the event and the joy it brings to all attendees. I'm your go-to person for any questions, assistance, or just a friendly chat.\n\nMy commitment is to make you feel welcome, entertained, and truly part of the event's magic. So, let's embark on this exciting journey together, and I promise you won't leave without a smile and wonderful memories to cherish.",
  eventUids: [],
  pastEventUids: [],
  city: "",
  country: "",
  countryDialCode: "",
);
