import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zipbuzz/models/events/posts/event_post_model.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/storage_services.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/user/user_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/models/user_model/user_model.dart';
import 'package:zipbuzz/utils/constants/defaults.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

final newEventProvider =
    StateNotifierProvider<NewEvent, EventModel>((ref) => NewEvent(ref: ref));

class NewEvent extends StateNotifier<EventModel> {
  final Ref ref;

  NewEvent({required this.ref})
      : super(
          EventModel(
            id: ref.read(userProvider).id,
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
            hostId: ref.read(userProvider).id,
            hostName: ref.read(userProvider).name,
            hostPic: ref.read(userProvider).imageUrl,
            coHostIds: [],
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

  void updateDate(DateTime date) {
    final formatedDate = getDateFromDateTime(date);
    state = state.copyWith(date: formatedDate);
  }

  void updateTime(TimeOfDay time, {bool? isEnd = false}) {
    final formatedTime = getTimeFromTimeOfDay(time);
    if (isEnd!) {
      state = state.copyWith(endTime: formatedTime);
    } else {
      state = state.copyWith(startTime: formatedTime);
    }
  }

  void addToCoHost(String uid) {
    state = state.copyWith(coHostIds: state.coHostIds..add(uid));
  }

  Future<void> updateCoHosts() async {
    final coHostIds = state.coHostIds;
    coHosts = await ref.read(eventsControllerProvider).getCoHosts(coHostIds);
  }

  String getDateFromDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  String getTimeFromTimeOfDay(TimeOfDay timeOfDay) {
    return '${timeOfDay.hourOfPeriod}:${timeOfDay.minute} ${timeOfDay.period == DayPeriod.am ? 'AM' : 'PM'}';
  }

  Future<void> publishEvent() async {
    try {
      var bannerUrl = "";
      if (bannerImage != null) {
        bannerUrl = await ref.read(storageServicesProvider).uploadEventBanner(
                id: ref.read(userProvider).id, file: bannerImage!) ??
            "";
      } else {
        final defaults = ref.read(defaultsProvider);
        final rand = Random().nextInt(defaults.bannerUrls.length);
        bannerUrl = defaults.bannerUrls[defaults.bannerPaths[rand]]!;
      }
      print(state.toJson());
      final eventPostModel = EventPostModel(
        banner: bannerUrl,
        category: state.category,
        name: state.title,
        description: state.about,
        date: state.date,
        venue: state.location,
        startTime: state.startTime,
        endTime: state.endTime ?? "null",
        hostId: state.hostId,
        hostName: state.hostName,
        hostPic: state.hostPic,
        eventType: state.isPrivate,
        capacity: state.capacity,
        filledCapacity: state.attendees,
      );
      await ref.read(dbServicesProvider).createEvent(eventPostModel);
      showSnackBar(message: "Event created successfully");
      state = EventModel(
        id: ref.read(userProvider).id,
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
        hostId: ref.read(userProvider).id,
        hostName: ref.read(userProvider).name,
        hostPic: ref.read(userProvider).imageUrl,
        coHostIds: [],
        guestIds: [],
        capacity: 10,
        isPrivate: false,
        imageUrls: [],
        privateGuestList: false,
      );
      bannerImage = null;
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
