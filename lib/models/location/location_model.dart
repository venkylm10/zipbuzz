class LocationModel {
  LocationModel({
    required this.city,
    required this.country,
    required this.countryDialCode,
    required this.zipcode,
  });
  final String city;
  final String country;
  final String countryDialCode;
  final String zipcode;


  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'city': city,
      'country': country,
      'countryDialCode': countryDialCode,
      'zipcode': zipcode,
    };
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      city: map['city'] as String,
      country: map['country'] as String,
      countryDialCode: map['countryDialCode'] as String,
      zipcode: map['zipcode'] as String,
    );
  }


  LocationModel copyWith({
    String? city,
    String? country,
    String? countryDialCode,
    String? zipcode,
  }) {
    return LocationModel(
      city: city ?? this.city,
      country: country ?? this.country,
      countryDialCode: countryDialCode ?? this.countryDialCode,
      zipcode: zipcode ?? this.zipcode,
    );
  }
}
