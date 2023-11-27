import 'package:zipbuzz/constants/assets.dart';

class UserModel {
  final String name;
  final String handle;
  final String position;
  final int eventsHosted;
  final double rating;
  final String imagePath;
  final String mobileNumber;
  final String zipcode;
  final String? linkedinId;
  final String? instagramId;
  final String? twitterId;
  final List<String> interests;
  final String about;

  const UserModel({
    required this.name,
    required this.handle,
    required this.position,
    required this.eventsHosted,
    required this.rating,
    required this.zipcode,
    this.linkedinId,
    this.instagramId,
    this.twitterId,
    required this.interests,
    required this.about,
    required this.imagePath,
    required this.mobileNumber,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'handle': handle,
      'position': position,
      'eventsHosted': eventsHosted,
      'rating': rating,
      'imagePath': imagePath,
      'mobileNumber': mobileNumber,
      'zipcode': zipcode,
      'linkedinId': linkedinId,
      'instagramId': instagramId,
      'twitterId': twitterId,
      'interests': interests,
      'about': about,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] != null ? map['name'] as String : "username",
      handle: map['handle'] != null ? map['handle'] as String : "",
      position: map['position'] != null ? map['position'] as String : "",
      eventsHosted:
          map['eventsHosted'] != null ? map['eventsHosted'] as int : 0,
      rating: map['rating'] != null ? map['rating'] as double : 0,
      imagePath: map['imagePath'] != null
          ? map['imagePath'] as String
          : Assets.images.profile,
      mobileNumber: map['mobileNumber'] != null
          ? map['mobileNumber'] as String
          : "9999999999",
      zipcode: map['zipcode'] != null ? map['zipcode'] as String : "444444",
      linkedinId: map['linkedinId'] != null ? map['linkedinId'] as String : "",
      instagramId:
          map['instagramId'] != null ? map['instagramId'] as String : null,
      twitterId: map['twitterId'] != null ? map['twitterId'] as String : null,
      interests: map['interests'] != null
          ? List<String>.from((map['interests'] as List<String>))
          : [],
      about: map['about'] != null ? map['about'] as String : "New to ZipBuzz",
    );
  }

  UserModel copyWith({
    String? name,
    String? handle,
    String? position,
    int? eventsHosted,
    double? rating,
    String? imagePath,
    String? mobileNumber,
    String? zipcode,
    String? linkedinId,
    String? instagramId,
    String? twitterId,
    List<String>? interests,
    String? about,
  }) {
    return UserModel(
      name: name ?? this.name,
      handle: handle ?? this.handle,
      position: position ?? this.position,
      eventsHosted: eventsHosted ?? this.eventsHosted,
      rating: rating ?? this.rating,
      imagePath: imagePath ?? this.imagePath,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      zipcode: zipcode ?? this.zipcode,
      linkedinId: linkedinId ?? this.linkedinId,
      instagramId: instagramId ?? this.instagramId,
      twitterId: twitterId ?? this.twitterId,
      interests: interests ?? this.interests,
      about: about ?? this.about,
    );
  }

  UserModel getClone() {
    final map = toMap();
    return UserModel.fromMap(map);
  }
}

final globalDummyUser = UserModel(
  name: "Alex Lee",
  handle: "bealexlee",
  imagePath: Assets.images.profile,
  position: "Brand Ambassadar",
  eventsHosted: 8,
  rating: 4.5,
  zipcode: "444444",
  mobileNumber: "(408) 238-3322",
  linkedinId: "alex-lee-2530611a",
  instagramId: "The_alex_lee",
  twitterId: "bealexlee",
  interests: ['Hiking', 'Sports', 'Dance', 'Wine Tasting'],
  about:
      "I'm here to ensure that your experience is nothing short of extraordinary. With a passion for creating unforgettable moments and a knack for connecting with people, I thrive on the energy of the event and the joy it brings to all attendees. I'm your go-to person for any questions, assistance, or just a friendly chat.\n\nMy commitment is to make you feel welcome, entertained, and truly part of the event's magic. So, let's embark on this exciting journey together, and I promise you won't leave without a smile and wonderful memories to cherish.",
);
