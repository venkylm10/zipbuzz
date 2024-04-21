class UserEventsRequestModel {
  final int userId;
  final String month;
  final List<String> category;
  const UserEventsRequestModel({required this.userId, required this.month, required this.category});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user_id': userId,
      'month': month,
      'category': category,
    };
  }
}
