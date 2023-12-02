import 'package:flutter/material.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/models/event_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/models/user_model.dart';

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
    date: DateTime.now().toString(),
    startTime: TimeOfDay.now().toString(),
    attendees: 0,
    category: "Hiking",
    favourite: false,
    bannerPath: Assets.images.nature,
    iconPath: allInterests['Hiking']!,
    maxAttendees: 50,
    about: "",
    host: null,
    coHosts: <UserModel>[],
    capacity: 10,
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

  // new event methods
  void updateName(String title) {
    ref
        .read(newEventProvider.notifier)
        .update((state) => state.copyWith(title: title));
  }

  void updateDescription(String description) {
    ref
        .read(newEventProvider.notifier)
        .update((state) => state.copyWith(about: description));
  }

  void updateLocation(String location) {
    ref
        .read(newEventProvider.notifier)
        .update((state) => state.copyWith(location: location));
  }

  void updateCategory(String category) {
    ref
        .read(newEventProvider.notifier)
        .update((state) => state.copyWith(category: category));
  }

  void onChangeCapacity(String value) {
    if (value.isEmpty) {
      ref
          .read(newEventProvider.notifier)
          .update((state) => state.copyWith(capacity: 0));

      return;
    }
    if (value.length > 1 && value[0] == '0') {
      value = value.substring(1);
    }
    final num = int.parse(value);

    if (num < 0) {
      ref
          .read(newEventProvider.notifier)
          .update((state) => state.copyWith(capacity: 0));
    } else {
      ref
          .read(newEventProvider.notifier)
          .update((state) => state.copyWith(capacity: num));
    }
  }

  void updateEventType(bool value) {
    ref
        .read(newEventProvider.notifier)
        .update((state) => state.copyWith(isPrivate: value));
  }

  void increaseCapacity() {
    ref
        .read(newEventProvider.notifier)
        .update((state) => state.copyWith(capacity: state.capacity + 1));
  }

  void decreaseCapacity() {
    if (ref.read(newEventProvider).capacity != 0) {
      ref
          .read(newEventProvider.notifier)
          .update((state) => state.copyWith(capacity: state.capacity - 1));
      return;
    }
  }

  void updateDate(String date) {
    ref
        .read(newEventProvider.notifier)
        .update((state) => state.copyWith(date: date));
  }

  void updateTime(String time, {bool? isEnd = false}) {
    if (isEnd!) {
      ref
          .read(newEventProvider.notifier)
          .update((state) => state.copyWith(endTime: time));
    } else {
      ref
          .read(newEventProvider.notifier)
          .update((state) => state.copyWith(startTime: time));
    }
  }
}
