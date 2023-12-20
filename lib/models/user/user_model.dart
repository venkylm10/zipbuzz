import 'package:zipbuzz/utils/constants/assets.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String handle;
  final bool isAmbassador;
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
    required this.id,
    required this.name,
    required this.email,
    required this.handle,
    required this.isAmbassador,
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
      'id': id,
      'name': name,
      'email': email,
      'handle': handle,
      'is_ambassador': isAmbassador,
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
      id: map['id'] as int,
      name: map['name'] != null ? map['name'] as String : "",
      email: map['email'] != null ? map['email'] as String : "",
      handle: map['handle'] != null ? map['handle'] as String : "",
      isAmbassador:
          map['is_ambassador'] != null ? map['is_ambassador'] as bool : false,
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
      countryDialCode: map['countryDialCode'] != null
          ? map['countryDialCode'] as String
          : "",
    );
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? handle,
    String? about,
    bool? isAmbassador,
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
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      handle: handle ?? this.handle,
      isAmbassador: isAmbassador ?? this.isAmbassador,
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
