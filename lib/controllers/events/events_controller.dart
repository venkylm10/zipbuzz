import 'package:intl/intl.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/models/events/requests/user_events_request_model.dart';
import 'package:zipbuzz/models/user_model/user_model.dart';
import 'package:zipbuzz/services/db_services.dart';

final eventsControllerProvider = Provider(
  (ref) => EventsController(ref: ref, user: ref.watch(userProvider)),
);

class EventsController {
  final UserModel? user;
  final Ref ref;
  EventsController({required this.ref, required this.user});
  List<EventModel> allEvents = [];
  List<EventModel> upcomingEvents = [];
  List<EventModel> pastEvents = [];
  List<EventModel> focusedEvents = [];
  Map<DateTime, List<EventModel>> eventsMap = {};
  String selectedCategory = '';
  double calenderHeight = 150;

  final today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  var focusedDay =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  void setCalendarHeight(double height) {
    calenderHeight = height;
  }

  void updatedFocusedDay(DateTime date) {
    final formattedDate = DateTime(date.year, date.month, date.day);
    focusedDay = formattedDate;
  }

  void updateFocusedEvents() {
    focusedEvents = eventsMap[focusedDay] ?? [];
  }

  void updateUpcomingEvents() {
    upcomingEvents.clear();
    eventsMap.forEach((key, value) {
      if (key.isAfter(today) || key.isAtSameMomentAs(today)) {
        upcomingEvents.addAll(value);
      }
    });
    upcomingEvents.sort((a, b) => a.date.compareTo(b.date));
  }

  void updatePastEvents() {
    pastEvents.clear();
    eventsMap.forEach((key, value) {
      if (key.isBefore(today)) {
        pastEvents.addAll(value);
      }
    });
    pastEvents.sort((a, b) => b.date.compareTo(a.date));
  }

  void selectCategory({String? category = ''}) {
    selectedCategory = category ?? '';
  }

  Future<UserModel?> getHostData(String uid) async {
    // final dbEvent = await ref.read(dbServicesProvider).getUserData(uid).first;
    // if (dbEvent.snapshot.exists) {
    //   final jsonString = jsonEncode(dbEvent.snapshot.value);
    //   final userMap = jsonDecode(jsonString);
    //   final host = UserModel.fromMap(userMap);
    //   return host;
    // }
    return null;
  }

  Future<List<UserModel>> getCoHosts(List<String> coHostIds) async {
    List<UserModel> coHosts = [];
    // for (final uid in coHostIds) {
    //   final dbEvent = await ref.read(dbServicesProvider).getUserData(uid).first;
    //   if (dbEvent.snapshot.exists) {
    //     final jsonString = jsonEncode(dbEvent.snapshot.value);
    //     final userMap = jsonDecode(jsonString);
    //     coHosts.add(UserModel.fromMap(userMap));
    //   }
    // }
    return coHosts;
  }

  Future<void> getUserEvents() async {
    final userEventsRequestModel =
        UserEventsRequestModel(userId: ref.read(userProvider).id.toString());
    final list = await ref
        .read(dbServicesProvider)
        .getUserEvents(userEventsRequestModel);
    allEvents = list;
    updateEventsMap();
  }

  void updateEventsMap() {
    eventsMap.clear();
    for (final event in allEvents) {
      final date = getDateTimeFromEventData(event.date);
      if (eventsMap.containsKey(date)) {
        eventsMap[date]!.add(event);
      } else {
        eventsMap[date] = [event];
      }
    }
  }

  DateTime getDateTimeFromEventData(String date) {
    return DateFormat('yyyy-MM-dd').parse(date);
  }
}
