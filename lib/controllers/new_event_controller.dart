import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/controllers/events_controller.dart';
import 'package:zipbuzz/controllers/user_controller.dart';
import 'package:zipbuzz/models/event_model.dart';
import 'package:zipbuzz/models/user_model.dart';

final newEventProvider =
    StateNotifierProvider<NewEvent, EventModel>((ref) => NewEvent(ref: ref));

class NewEvent extends StateNotifier<EventModel> {
  final Ref ref;

  NewEvent({required this.ref})
      : super(
          EventModel(
            id: "",
            title: "",
            location: "",
            date: DateTime.now().toString(),
            startTime: DateTime.now().toUtc().toString(),
            endTime: DateTime.now().toUtc().toString(),
            attendees: 0,
            category: "Hiking",
            favourite: false,
            bannerPath: "",
            iconPath: allInterests['Hiking']!,
            about: "",
            hostId: ref.read(userProvider)!.uid,
            coHostIds: ["CxZ5Ioll70XxdKMUhJQdRiFaUR82"],
            guestIds: [],
            capacity: 10,
            isPrivate: false,
            imageUrls: [],
            privateGuestList: false,
          ),
        );

  List<File> selectedImages = [];
  int maxImages = 7;
  File? bannerImage;
  List<UserModel> coHosts = [];

  void toggleGuestListPrivacy() {
    state = state.copyWith(privateGuestList: !state.privateGuestList);
  }

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

  void addToCoHost(String uid) {
    state = state.copyWith(coHostIds: state.coHostIds..add(uid));
  }

  Future<void> updateCoHosts() async {
    final coHostIds = state.coHostIds;
    coHosts = await ref.read(eventsControllerProvider).getCoHosts(coHostIds);
  }

  void publishEvent() {}
}
