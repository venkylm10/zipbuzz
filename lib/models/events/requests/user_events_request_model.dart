class UserEventsRequestModel {
  final int userId;
  final String month;
  final List<String> category;
  final String zipcode;
  const UserEventsRequestModel({
    required this.userId,
    required this.month,
    required this.category,
    required this.zipcode,
  });

  Map<String, dynamic> toMap() {
    final data = {
      'user_id': userId,
      'month': month,
      'category': category,
      'zipcode': zipcode,
    };
    return data;
  }
}
