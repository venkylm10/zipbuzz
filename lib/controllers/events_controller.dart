import 'dart:convert';

import 'package:zipbuzz/controllers/user_controller.dart';
import 'package:zipbuzz/models/event_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/models/user_model.dart';
import 'package:zipbuzz/services/db_services.dart';

final eventsControllerProvider = Provider(
  (ref) => EventsController(ref: ref, user: ref.watch(userProvider)),
);

class EventsController {
  final UserModel? user;
  final Ref ref;
  EventsController({required this.ref, required this.user});

  List<EventModel> upcomingEvents = [];
  List<EventModel> pastEvents = [];
  List<EventModel> focusedEvents = [];
  String selectedCategory = '';
  double calenderHeight = 150;

  final today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  var focusedDay =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  void setCalendarHeight(double height) {
    calenderHeight = height;
  }

  void updatedFocusedDay(DateTime dateTime) {
    focusedDay = dateTime;
  }

  void updateFocusedEvents() {
    focusedEvents = events[focusedDay] ?? [];
  }

  void updateUpcomingEvents() {
    upcomingEvents.clear();
    events.forEach((key, value) {
      if (key.isAfter(today) || key.isAtSameMomentAs(today)) {
        upcomingEvents.addAll(value);
      }
    });
    upcomingEvents.sort((a, b) => a.date.compareTo(b.date));
  }

  void updatePastEvents() {
    pastEvents.clear();
    events.forEach((key, value) {
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
    final dbEvent = await ref.read(dbServicesProvider).getUserData(uid).first;
    if (dbEvent.snapshot.exists) {
      final jsonString = jsonEncode(dbEvent.snapshot.value);
      final userMap = jsonDecode(jsonString);
      final host = UserModel.fromMap(userMap);
      return host;
    }
    return null;
  }

  Future<List<UserModel>> getCoHosts(List<String> coHostIds) async {
    List<UserModel> coHosts = [];
    for (final uid in coHostIds) {
      final dbEvent = await ref.read(dbServicesProvider).getUserData(uid).first;
      if (dbEvent.snapshot.exists) {
        final jsonString = jsonEncode(dbEvent.snapshot.value);
        final userMap = jsonDecode(jsonString);
        coHosts.add(UserModel.fromMap(userMap));
      }
    }
    return coHosts;
  }
}
