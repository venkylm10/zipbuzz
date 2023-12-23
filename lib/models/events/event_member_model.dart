class EventMemberModel {
  final String image;
  final String phone;
  final String name;

  EventMemberModel({
    required this.image,
    required this.phone,
    required this.name,
  });

  factory EventMemberModel.fromMap(Map<String, dynamic> map) {
    return EventMemberModel(
      image: map['image'] as String,
      phone: map['phone'] as String,
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'phone': phone,
      'name': name,
    };
  }
}
