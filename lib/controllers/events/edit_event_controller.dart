import 'dart:io';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/models/events/requests/edit_event_model.dart';
import 'package:zipbuzz/pages/event_details/event_details_page.dart';
import 'package:zipbuzz/pages/sign-in/sign_in_page.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/services/storage_services.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/models/user/user_model.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/widgets/common/loader.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

final editEventControllerProvider =
    StateNotifierProvider<EditEventController, EventModel>((ref) => EditEventController(ref: ref));

class EditEventController extends StateNotifier<EventModel> {
  final Ref ref;

  EditEventController({required this.ref})
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
            isFavorite: false,
            bannerPath: "",
            iconPath: "", // updating this just after getting allInterests from the API
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
            status: "nothing",
            userDeviceToken: "",
          ),
        );
  int eventId = 1;
  List<File> selectedImages = [];
  int maxImages = 7;
  File? bannerImage;
  List<UserModel> coHosts = [];
  List<Contact> eventInvites = [];
  List<Contact> allContacts = [];
  List<Contact> contactSearchResult = [];
  List<String> deletedImages = [];

  void removeEventImageUrl(String url) {
    final updatedUrls = state.imageUrls;
    updatedUrls.remove(url);
    deletedImages.add(url);
    state = state.copyWith(imageUrls: updatedUrls);
  }

  void updateEvent(EventModel event) {
    state = event;
  }

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

  void updateBannerImage(File? file) {
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
    state = state.copyWith(category: category, iconPath: interestIcons[category]!);
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
        var name = (element.displayName ?? "").toLowerCase().contains(query);
        var number = false;
        if (element.phones!.isNotEmpty) {
          number = (element.phones!.first.value ?? "").contains(query);
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

  bool validateEventForm() {
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

  Future<void> rePublishEvent() async {
    ref.read(loadingTextProvider.notifier).reset();
    if (GetStorage().read(BoxConstants.guestUser) != null) {
      showSnackBar(message: "You need to be Signed In!", duration: 2);
      await Future.delayed(const Duration(seconds: 2));
      showSignInForm();
      return;
    }
    final check = validateEventForm();
    if (!check) return;
    try {
      var bannerUrl = state.bannerPath;
      if (bannerImage != null) {
        ref.read(loadingTextProvider.notifier).updateLoadingText("Uploading banner image...");
        bannerUrl = await ref
                .read(storageServicesProvider)
                .uploadEventBanner(id: ref.read(userProvider).id, file: bannerImage!) ??
            state.bannerPath;
      }
      state = state.copyWith(bannerPath: bannerUrl);
      debugPrint("Updated Event: ${state.toMap()}");
      final date = DateTime.parse(state.date);
      final eventPostModel = EditEventRequestModel(
        eventId: eventId,
        banner: bannerUrl,
        category: state.category,
        name: state.title,
        description: state.about,
        date: DateTime(date.year, date.month, date.day).toString(),
        venue: state.location,
        startTime: state.startTime,
        endTime: state.endTime.isEmpty ? "null" : state.endTime,
        hostId: state.hostId,
        hostName: state.hostName,
        hostPic: state.hostPic,
        eventType: state.isPrivate,
        capacity: state.capacity,
        filledCapacity: state.attendees,
      );

      ref.read(loadingTextProvider.notifier).updateLoadingText("Editing Event...");
      await ref.read(dbServicesProvider).editEvent(eventPostModel);
      if (selectedImages.isNotEmpty) {
        // upload event images
        ref.read(loadingTextProvider.notifier).updateLoadingText("Uploading event images...");
        await ref.read(dioServicesProvider).postEventImages(eventId, selectedImages);
      }
      if (deletedImages.isNotEmpty) {
        await ref.read(dioServicesProvider).deleteEventImages(deletedImages);
        deletedImages.clear();
      }
      var eventDateTime = DateTime.parse(state.date);
      ref.read(eventsControllerProvider.notifier).updatedFocusedDay(eventDateTime);
      ref.read(homeTabControllerProvider.notifier).updateIndex(1);
      await ref.read(eventsControllerProvider.notifier).getAllEvents();
      ref.read(eventsControllerProvider.notifier).updateUpcomingEvents();
      ref.read(eventsControllerProvider.notifier).updateFocusedEvents();
      ref.read(loadingTextProvider.notifier).reset();
      showSnackBar(message: "Event edited successfully");
      navigatorKey.currentState!.pop();
      navigatorKey.currentState!.pop();
      final image = NetworkImage(eventPostModel.banner);
      final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
        image,
      );
      final dominantColor = generator.dominantColor?.color;
      final updatedEvent = await ref.read(dbServicesProvider).getEventDetails(eventId);
      Map<String, dynamic> args = {
        'event': updatedEvent,
        'isPreview': false,
        'dominantColor': dominantColor ?? const Color(0xFF4a5759),
        'randInt': 0,
      };
      await navigatorKey.currentState!.pushReplacementNamed(
        EventDetailsPage.id,
        arguments: args,
      );
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
}
