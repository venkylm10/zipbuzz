import 'package:flutter/material.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/models/event_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final eventsControllerProvider = Provider((ref) => EventsController(ref: ref));
final newEventProvider = StateProvider(
  (ref) => ref.watch(eventsControllerProvider).newEvent,
);

class EventsController {
  final Ref ref;
  EventsController({required this.ref});

  List<EventModel> upcomingEvents = [];
  List<EventModel> pastEvents = [];
  List<EventModel> focusedEvents = [];
  String selectedCategory = '';
  double calenderHeight = 150;
  EventModel newEvent = EventModel(
    title: "",
    location: "",
    dateTime: DateTime.now(),
    startTime: TimeOfDay.now(),
    attendees: 0,
    interest: "Hiking",
    favourite: false,
    bannerPath: Assets.images.nature,
    iconPath: allInterests['Hiking']!,
    maxAttendees: 50,
  );

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
    upcomingEvents.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  void updatePastEvents() {
    pastEvents.clear();
    events.forEach((key, value) {
      if (key.isBefore(today)) {
        pastEvents.addAll(value);
      }
    });
    pastEvents.sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  void selectCategory({String? category = ''}) {
    selectedCategory = category ?? '';
  }
}
