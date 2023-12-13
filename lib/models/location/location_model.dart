class LocationModel {
  LocationModel({
    required this.city,
    required this.country,
    required this.countryDialCode,
    required this.zipcode,
  });
  late final String city;
  late final String country;
  late final String countryDialCode;
  late final String zipcode;

  LocationModel.fromJson(Map<String, dynamic> json) {
    country = json['country'];
    countryDialCode = json['countryDialCode'];
    zipcode = json['zipcode'];
    city = json['city'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['country'] = country;
    data['countryDialCode'] = countryDialCode;
    data['zipcode'] = zipcode;
    data['city'] = city;
    return data;
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
