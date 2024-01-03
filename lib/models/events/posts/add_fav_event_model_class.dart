class AddEventToFavoriteModelClass {
  int eventId;
  int userId;

  AddEventToFavoriteModelClass({
    required this.eventId,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'event_id': eventId,
      'user_id': userId,
    };
  }
}
