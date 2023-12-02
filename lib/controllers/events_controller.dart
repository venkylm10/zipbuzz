import 'dart:io';

import 'package:flutter/material.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/controllers/user_controller.dart';
import 'package:zipbuzz/models/event_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/models/user_model.dart';

final eventsControllerProvider = Provider(
  (ref) => EventsController(ref: ref, user: ref.watch(userProvider)),
);
final newEventProvider =
    StateNotifierProvider<NewEvent, EventModel>((ref) => NewEvent());

class NewEvent extends StateNotifier<EventModel> {
  NewEvent()
      : super(EventModel(
          id: "",
          title: "",
          location: "",
          date: DateTime.now().toString(),
          startTime: DateTime.now().toUtc().toString(),
          endTime: DateTime.now().toUtc().toString(),
          attendees: 0,
          category: "Hiking",
          favourite: false,
          bannerPath: Assets.images.nature,
          iconPath: allInterests['Hiking']!,
          about: "",
          host: null,
          coHosts: <UserModel>[],
          capacity: 10,
          isPrivate: false,
        ));

  List<File> selectedImages = [];

  File? bannerImage;

  void updateBannerImage(File file) {
    bannerImage = file;
  }

  void updateName(String title) {
    state = state.copyWith(title: title);
  }

  void updateDescription(String description) {
    state = state.copyWith(about: description);
  }

  void updateLocation(String location) {
    state = state.copyWith(location: location);
  }

  void updateCategory(String category) {
    state = state.copyWith(category: category);
  }

  void onChangeCapacity(String value) {
    if (value.isEmpty) {
      state = state.copyWith(capacity: 0);

      return;
    }
    if (value.length > 1 && value[0] == '0') {
      value = value.substring(1);
    }
    final num = int.parse(value);

    if (num < 0) {
      state = state.copyWith(capacity: 0);
    } else {
      state = state.copyWith(capacity: num);
    }
  }

  void updateEventType(bool value) {
    state = state.copyWith(isPrivate: value);
  }

  void increaseCapacity() {
    state = state.copyWith(capacity: state.capacity + 1);
  }

  void decreaseCapacity() {
    if (state.capacity != 0) {
      state = state.copyWith(capacity: state.capacity - 1);
      return;
    }
  }

  void updateDate(String date) {
    state = state.copyWith(date: date);
  }

  void updateTime(String time, {bool? isEnd = false}) {
    if (isEnd!) {
      state = state.copyWith(endTime: time);
    } else {
      state = state.copyWith(startTime: time);
    }
  }
}

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

  // new event methods
}
