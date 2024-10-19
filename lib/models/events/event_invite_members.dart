import 'package:zipbuzz/utils/extensions.dart';

class EventInviteMember {
  String image;
  String phone;
  String name;
  String status;
  DateTime? memberTime;

  EventInviteMember({
    required this.image,
    required this.phone,
    required this.name,
    required this.status,
    this.memberTime,
  });

  factory EventInviteMember.fromMap(Map<String, dynamic> map) {
    return EventInviteMember(
      image: map['image'] as String,
      phone: map['phone'] as String,
      name: map['name'].toString().formattedName,
      status: map['status'] as String,
      memberTime: DateTime.parse(map['member_time']).toLocal(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'phone': phone,
      'name': name,
      'status': status,
      'member_time': memberTime?.toUtc().toIso8601String(),
    };
  }
}
