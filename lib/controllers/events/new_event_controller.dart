import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/models/events/posts/event_invite_post_model.dart';
import 'package:zipbuzz/models/events/posts/event_post_model.dart';
import 'package:zipbuzz/pages/sign-in/sign_in_page.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/services/storage_services.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/models/user/user_model.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/utils/constants/defaults.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/widgets/common/loader.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

final newEventProvider = StateNotifierProvider<NewEvent, EventModel>((ref) => NewEvent(ref: ref));

class NewEvent extends StateNotifier<EventModel> {
  final Ref ref;

  NewEvent({required this.ref})
      : super(
          EventModel(
            id: ref.read(userProvider).id,
            title: "",
            location: "",
            date: DateTime.now().toString(),
            startTime: "",
            endTime: "",
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
            capacity: 10,
            isPrivate: false,
            imageUrls: [],
            privateGuestList: false,
            eventMembers: [],
          ),
        );
  List<File> selectedImages = [];
  int maxImages = 7;
  File? bannerImage;
  List<UserModel> coHosts = [];
  List<Contact> eventInvites = [];
  List<Contact> allContacts = [];
  List<Contact> contactSearchResult = [];

  void updateHostId(int id) {
    state = state.copyWith(hostId: id);
  }

  void updateHostPic(String url) {
    state = state.copyWith(hostPic: url);
  }

  void updateHostName(String name) {
    state = state.copyWith(hostName: name);
  }

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
    state = state.copyWith(category: category, iconPath: allInterests[category]!);
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

  void updateAllContacts(List<Contact> contacts) {
    allContacts = contacts;
  }

  void updateInvites(List<Contact> contacts) {
    eventInvites = contacts;
  }

  void resetContactSearch() {
    contactSearchResult = allContacts;
  }

  void updateSelectedContact(Contact contact) {
    if (!eventInvites.contains(contact)) {
      if (state.attendees >= state.capacity) {
        state = state.copyWith(capacity: state.capacity + 1);
      }
      eventInvites.add(contact);
      state = state.copyWith(attendees: state.attendees + 1);
      return;
    }
    eventInvites.remove(contact);
    state = state.copyWith(attendees: state.attendees - 1);
  }

  void updateContactSearchResult(String query) {
    contactSearchResult = allContacts.where(
      (element) {
        var name = element.displayName.toLowerCase().contains(query);
        var number = false;
        if (element.phones.isNotEmpty) {
          number = element.phones.first.normalizedNumber.contains(query);
        }
        return name || number;
      },
    ).toList();
  }

  void addToCoHost(String uid) {
    state = state.copyWith(coHostIds: state.coHostIds..add(uid));
  }

  String getDateFromDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  String getTimeFromTimeOfDay(TimeOfDay timeOfDay) {
    final hr = timeOfDay.hourOfPeriod.toString().length == 1
        ? '0${timeOfDay.hourOfPeriod}'
        : timeOfDay.hourOfPeriod;
    final min = timeOfDay.minute.toString().length == 1 ? '0${timeOfDay.minute}' : timeOfDay.minute;
    return '$hr:$min ${timeOfDay.period == DayPeriod.am ? 'AM' : 'PM'}';
  }

  bool validateNewEvent() {
    if (bannerImage == null) {
      showSnackBar(message: "Please select a banner image");
      return false;
    }
    if (state.title.isEmpty) {
      showSnackBar(message: "Please enter event title");
      return false;
    }
    if (state.about.isEmpty) {
      showSnackBar(message: "Please enter event description");
      return false;
    }
    if (state.location.isEmpty) {
      showSnackBar(message: "Please enter event location");
      return false;
    }
    if (state.startTime.isEmpty) {
      showSnackBar(message: "Please enter event start time");
      return false;
    }
    if (state.endTime.isEmpty) {
      showSnackBar(message: "Please enter event end time");
      return false;
    }
    return true;
  }

  void showSignInForm() {
    showModalBottomSheet(
      context: navigatorKey.currentContext!,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      barrierColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      builder: (context) {
        return const SignInSheet();
      },
    );
  }

  Future<void> publishEvent() async {
    ref.read(loadingTextProvider.notifier).reset();
    if (GetStorage().read(BoxConstants.guestUser) != null) {
      showSnackBar(message: "You need to be Signed In to create an event!", duration: 2);
      await Future.delayed(const Duration(seconds: 2));
      showSignInForm();
      return;
    }
    final check = validateNewEvent();
    if (!check) return;
    try {
      var bannerUrl = "";
      if (bannerImage != null) {
        ref.read(loadingTextProvider.notifier).updateLoadingText("Uploading banner image...");
        bannerUrl = await ref
                .read(storageServicesProvider)
                .uploadEventBanner(id: ref.read(userProvider).id, file: bannerImage!) ??
            "";
      } else {
        final defaults = ref.read(defaultsProvider);
        final rand = Random().nextInt(defaults.bannerUrls.length);
        bannerUrl = defaults.bannerUrls[defaults.bannerPaths[rand]]!;
      }
      debugPrint("New Event: ${state.toMap()}");
      final date = DateTime.parse(state.date);
      final eventPostModel = EventPostModel(
        banner: bannerUrl,
        category: state.category,
        name: state.title,
        description: state.about,
        date: DateTime(date.year, date.month, date.day).toString(),
        venue: state.location,
        startTime: state.startTime,
        endTime: state.endTime,
        hostId: state.hostId,
        hostName: state.hostName,
        hostPic: state.hostPic,
        eventType: state.isPrivate,
        capacity: state.capacity,
        filledCapacity: eventInvites.length,
      );

      ref.read(loadingTextProvider.notifier).updateLoadingText("Creating Event...");
      final eventId = await ref.read(dbServicesProvider).createEvent(eventPostModel);

      var eventDateTime = DateTime.parse(state.date);
      var formattedDate = formatWithSuffix(eventDateTime);
      ref.read(loadingTextProvider.notifier).updateLoadingText("Sending invites...");

      final inviteePicUrls = await ref
          .read(storageServicesProvider)
          .uploadInviteePics(hostId: state.hostId, eventId: 1, contacts: eventInvites);

      final eventInvitePostModel = EventInvitePostModel(
        phoneNumbers: eventInvites.map((e) {
          return e.phones.first.normalizedNumber;
        }).toList(),
        images: inviteePicUrls,
        names: eventInvites.map((e) {
          return e.displayName;
        }).toList(),
        senderName: ref.read(userProvider).name,
        eventName: eventPostModel.name,
        eventDate: formattedDate,
        eventLocation: eventPostModel.venue,
        eventStart: eventPostModel.startTime,
        eventEnd: eventPostModel.endTime,
        eventId: eventId,
      );
      await ref.read(dioServicesProvider).sendEventInvite(eventInvitePostModel);
      showSnackBar(message: "Event created successfully");
      resetNewEvent();
      ref.read(loadingTextProvider.notifier).reset();
      ref.read(eventsControllerProvider).updatedFocusedDay(eventDateTime);
      ref.read(homeTabControllerProvider.notifier).updateIndex(0);

      navigatorKey.currentState!.pop();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  String formatWithSuffix(DateTime date) {
    String dayOfMonth = DateFormat('d').format(date);
    String suffix;
    if (dayOfMonth.endsWith('1') && dayOfMonth != '11') {
      suffix = 'st';
    } else if (dayOfMonth.endsWith('2') && dayOfMonth != '12') {
      suffix = 'nd';
    } else if (dayOfMonth.endsWith('3') && dayOfMonth != '13') {
      suffix = 'rd';
    } else {
      suffix = 'th';
    }
    return DateFormat('d\'$suffix\' MMMM, y').format(date);
  }

  void resetNewEvent() {
    state = EventModel(
      id: ref.read(userProvider).id,
      title: "",
      location: "",
      date: DateTime.now().toString(),
      startTime: "",
      endTime: "",
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
      capacity: 10,
      isPrivate: false,
      imageUrls: [],
      privateGuestList: false,
      eventMembers: [],
    );
    eventInvites = [];
    bannerImage = null;
  }
}
