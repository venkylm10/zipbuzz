import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/models/events/join_request_model.dart';
import 'package:zipbuzz/models/events/posts/add_fav_event_model_class.dart';
import 'package:zipbuzz/models/events/requests/user_events_request_model.dart';
import 'package:zipbuzz/models/user/user_model.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/utils/constants/assets.dart';

final eventsControllerProvider = StateNotifierProvider<EventsControllProvider, EventsController>(
  (ref) => EventsControllProvider(ref: ref, user: ref.watch(userProvider)),
);

class EventsControllProvider extends StateNotifier<EventsController> {
  final UserModel? user;
  final Ref ref;
  EventsControllProvider({required this.ref, required this.user})
      : super(EventsController(ref: ref, user: user));

  void setCalendarHeight(double height) {
    state = state.copyWith(calenderHeight: height);
  }

  void updatedFocusedDay(DateTime date) {
    final formattedDate = DateTime(date.year, date.month, date.day);
    state = state.copyWith(focusedDay: formattedDate);
  }

  void updateFocusedEvents() {
    state = state.copyWith(focusedEvents: state.eventsMap[state.focusedDay] ?? []);
  }

  void updateUpcomingEvents() {
    state = state.copyWith(upcomingEvents: []);
    var events = <EventModel>[];
    state.eventsMap.forEach((key, value) {
      if (key.isAfter(state.today) || key.isAtSameMomentAs(state.today)) {
        events.addAll(value);
      }
    });

    events.sort((a, b) => a.date.compareTo(b.date));
    state = state.copyWith(upcomingEvents: events);
  }

  void updatePastEvents() {
    var events = <EventModel>[];
    state.eventsMap.forEach((key, value) {
      if (key.isBefore(state.today)) {
        events.addAll(value);
      }
    });
    events.sort((a, b) => b.date.compareTo(a.date));
    state = state.copyWith(pastEvents: events);
  }

  void selectCategory({String? category = ''}) {
    state = state.copyWith(selectedCategory: category ?? '');
  }

  Future<void> getAllEvents() async {
    final userEventsRequestModel =
        UserEventsRequestModel(userId: ref.read(userProvider).id);
    final list = await ref.read(dbServicesProvider).getAllEvents(userEventsRequestModel);
    state = state.copyWith(allEvents: list);
    adjustEventData();
  }

  void updateEventsMap() {
    state = state.copyWith(eventsMap: {});
    Map<DateTime, List<EventModel>> map = {};
    for (final event in state.allEvents) {
      final date = getDateTimeFromEventData(event.date);
      if (map.containsKey(date)) {
        map[date]!.add(event);
      } else {
        map[date] = [event];
      }
    }
    state = state.copyWith(eventsMap: map);
  }

  DateTime getDateTimeFromEventData(String date) {
    return DateFormat('yyyy-MM-dd').parse(date);
  }

  String getformatedDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> updateFavoriteEvents() async {
    if (!state.showingFavorites) {
      state = state.copyWith(showingFavorites: true);
      final userEventsRequestModel =
          UserEventsRequestModel(userId: ref.read(userProvider).id);
      final list = await ref.read(dbServicesProvider).getUserFavoriteEvents(userEventsRequestModel);
      state = state.copyWith(allEvents: list);
      adjustEventData();
      return;
    }
    state = state.copyWith(showingFavorites: false);
    getAllEvents();
  }

  Future<void> addEventToFavorites(int eventId) async {
    final model = AddEventToFavoriteModelClass(eventId: eventId, userId: ref.read(userProvider).id);
    await ref.read(dioServicesProvider).addEventToFavorite(model);
  }

  Future<void> removeEventFromFavorites(int eventId) async {
    final model = AddEventToFavoriteModelClass(eventId: eventId, userId: ref.read(userProvider).id);
    await ref.read(dioServicesProvider).removeEventFromFavorite(model);
    if (state.showingFavorites) {
      var events = state.allEvents;
      events.removeWhere((element) => element.id == eventId);
      state = state.copyWith(allEvents: events);
      adjustEventData();
    }
  }

  void adjustEventData() {
    updateEventsMap();
    updateFocusedEvents();
    updateUpcomingEvents();
    updatePastEvents();
  }

  void refresh() {
    state = state.copyWith();
  }

  Future<void> getAllInterests() async {
    final list = await ref.read(dioServicesProvider).getAllInterests();
    Map<String, String> map = {};
    for (var item in list) {
      map.addEntries([MapEntry(item.activity, item.iconUrl)]);
    }

    Map<String, Color> colors = {};
    for (var item in list) {
      colors.addEntries([MapEntry(item.activity, hexStringToColor(item.color))]);
    }

    Map<String, String> banners = {};
    for (var item in list) {
      banners.addEntries([MapEntry(item.activity, item.bannerUrl)]);
    }
    allInterests = list;
    interestIcons = map;
    interestColors = colors;
    interestBanners = banners;
    return;
  }

  Color hexStringToColor(String hexColor) {
    if (hexColor.startsWith('0x') || hexColor.startsWith('0X')) {
      hexColor = hexColor.substring(2);
    }
    int hexValue = int.parse(hexColor, radix: 16);
    return Color(hexValue);
  }

  Future<bool> requestToJoinEvent(int eventId) async {
    final user = ref.read(userProvider);
    final model = JoinEventRequestModel(
      eventId: eventId,
      name: user.name,
      phoneNumber: user.mobileNumber,
      image: user.imageUrl,
    );
    return ref.read(dioServicesProvider).requestToJoinEvent(model);
  }

    List<String> extractLinks(String text) {
    RegExp urlPattern = RegExp(r'https?://\S+');
    Iterable<RegExpMatch> matches = urlPattern.allMatches(text);
    List<String> links = [];
    for (var match in matches) {
      if (match.group(0) != null) {
        links.add(match.group(0)!);
      }
    }
    print("links: $links");
    return links;
  }
}

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
  bool showingFavorites = false;

  final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  var focusedDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  EventsController copyWith({
    UserModel? user,
    Ref? ref,
    List<EventModel>? allEvents,
    List<EventModel>? upcomingEvents,
    List<EventModel>? pastEvents,
    List<EventModel>? focusedEvents,
    Map<DateTime, List<EventModel>>? eventsMap,
    String? selectedCategory,
    double? calenderHeight,
    bool? showingFavorites,
    DateTime? focusedDay,
  }) {
    var res = EventsController(
      user: user ?? this.user,
      ref: ref ?? this.ref,
    );

    res.allEvents = allEvents ?? this.allEvents;
    res.upcomingEvents = upcomingEvents ?? this.upcomingEvents;
    res.pastEvents = pastEvents ?? this.pastEvents;
    res.focusedEvents = focusedEvents ?? this.focusedEvents;
    res.eventsMap = eventsMap ?? this.eventsMap;
    res.selectedCategory = selectedCategory ?? this.selectedCategory;
    res.calenderHeight = calenderHeight ?? this.calenderHeight;
    res.showingFavorites = showingFavorites ?? this.showingFavorites;
    res.focusedDay = focusedDay ?? this.focusedDay;
    return res;
  }
}

// final guestEventsList = <EventModel>[
//   EventModel(
//     id: 1,
//     title: "A Madcap House Party Extravaganza",
//     hostId: 2,
//     coHostIds: [],
//     eventMembers: [
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//     ],
//     location: "420 Gala St, San Jose 95125",
//     date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
//     startTime: "8:00 AM",
//     endTime: "12:00 PM",
//     attendees: 15,
//     category: "Hiking",
//     isFavorite: false,
//     bannerPath: Defaults().bannerUrls[Defaults().bannerPaths[0]]!,
//     iconPath: allInterests["Hiking"]!,
//     about:
//         "Get ready to turn up the color dial and paint the town in a kaleidoscope of hues at the most vibrant house party of the year!",
//     isPrivate: true,
//     capacity: 20,
//     imageUrls: [],
//     privateGuestList: false,
//     hostName: "Zipbuzz User",
//     hostPic: Defaults().profilePictureUrl,
//   ),
//   EventModel(
//     id: 1,
//     title: "A Madcap House Party Extravaganza",
//     hostId: 1,
//     coHostIds: [],
//     eventMembers: [
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//     ],
//     location: "420 Gala St, San Jose 95125",
//     date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
//     startTime: "8:00 AM",
//     endTime: "12:00 PM",
//     attendees: 15,
//     category: "Sports",
//     isFavorite: false,
//     bannerPath: Defaults().bannerUrls[Defaults().bannerPaths[1]]!,
//     iconPath: allInterests["Sports"]!,
//     about:
//         "Get ready to turn up the color dial and paint the town in a kaleidoscope of hues at the most vibrant house party of the year!",
//     isPrivate: true,
//     capacity: 20,
//     imageUrls: [],
//     privateGuestList: false,
//     hostName: "Zipbuzz User",
//     hostPic: Defaults().profilePictureUrl,
//   ),
//   EventModel(
//     id: 1,
//     title: "A Madcap House Party Extravaganza",
//     hostId: 1,
//     coHostIds: [],
//     eventMembers: [
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//     ],
//     location: "420 Gala St, San Jose 95125",
//     date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
//     startTime: "8:00 AM",
//     endTime: "12:00 PM",
//     attendees: 15,
//     category: "Hiking",
//     isFavorite: false,
//     bannerPath: Defaults().bannerUrls[Defaults().bannerPaths[2]]!,
//     iconPath: allInterests["Hiking"]!,
//     about:
//         "Get ready to turn up the color dial and paint the town in a kaleidoscope of hues at the most vibrant house party of the year!",
//     isPrivate: true,
//     capacity: 20,
//     imageUrls: [],
//     privateGuestList: false,
//     hostName: "Zipbuzz User",
//     hostPic: Defaults().profilePictureUrl,
//   ),
//   EventModel(
//     id: 1,
//     title: "A Madcap House Party Extravaganza",
//     hostId: 2,
//     coHostIds: [],
//     eventMembers: [
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//     ],
//     location: "420 Gala St, San Jose 95125",
//     date: DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1))),
//     startTime: "8:00 AM",
//     endTime: "12:00 PM",
//     attendees: 15,
//     category: "Fitness",
//     isFavorite: false,
//     bannerPath: Defaults().bannerUrls[Defaults().bannerPaths[0]]!,
//     iconPath: allInterests["Fitness"]!,
//     about:
//         "Get ready to turn up the color dial and paint the town in a kaleidoscope of hues at the most vibrant house party of the year!",
//     isPrivate: true,
//     capacity: 20,
//     imageUrls: [],
//     privateGuestList: false,
//     hostName: "Zipbuzz User",
//     hostPic: Defaults().profilePictureUrl,
//   ),
//   EventModel(
//     id: 1,
//     title: "A Madcap House Party Extravaganza",
//     hostId: 1,
//     coHostIds: [],
//     eventMembers: [
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//     ],
//     location: "420 Gala St, San Jose 95125",
//     date: DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1))),
//     startTime: "8:00 AM",
//     endTime: "12:00 PM",
//     attendees: 15,
//     category: "Parties",
//     isFavorite: false,
//     bannerPath: Defaults().bannerUrls[Defaults().bannerPaths[1]]!,
//     iconPath: allInterests["Parties"]!,
//     about:
//         "Get ready to turn up the color dial and paint the town in a kaleidoscope of hues at the most vibrant house party of the year!",
//     isPrivate: true,
//     capacity: 20,
//     imageUrls: [],
//     privateGuestList: false,
//     hostName: "Zipbuzz User",
//     hostPic: Defaults().profilePictureUrl,
//   ),
//   EventModel(
//     id: 1,
//     title: "A Madcap House Party Extravaganza",
//     hostId: 1,
//     coHostIds: [],
//     eventMembers: [
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//     ],
//     location: "420 Gala St, San Jose 95125",
//     date: DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: -1))),
//     startTime: "8:00 AM",
//     endTime: "12:00 PM",
//     attendees: 15,
//     category: "Fitness",
//     isFavorite: false,
//     bannerPath: Defaults().bannerUrls[Defaults().bannerPaths[2]]!,
//     iconPath: allInterests["Fitness"]!,
//     about:
//         "Get ready to turn up the color dial and paint the town in a kaleidoscope of hues at the most vibrant house party of the year!",
//     isPrivate: true,
//     capacity: 20,
//     imageUrls: [],
//     privateGuestList: false,
//     hostName: "Zipbuzz User",
//     hostPic: Defaults().profilePictureUrl,
//   ),
//   EventModel(
//     id: 1,
//     title: "A Madcap House Party Extravaganza",
//     hostId: 1,
//     coHostIds: [],
//     eventMembers: [
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//       EventInviteMember(
//           image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
//       EventInviteMember(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
//     ],
//     location: "420 Gala St, San Jose 95125",
//     date: DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: -1))),
//     startTime: "8:00 AM",
//     endTime: "12:00 PM",
//     attendees: 15,
//     category: "Parties",
//     isFavorite: false,
//     bannerPath: Defaults().bannerUrls[Defaults().bannerPaths[3]]!,
//     iconPath: allInterests["Parties"]!,
//     about:
//         "Get ready to turn up the color dial and paint the town in a kaleidoscope of hues at the most vibrant house party of the year!",
//     isPrivate: true,
//     capacity: 20,
//     imageUrls: [],
//     privateGuestList: false,
//     hostName: "Zipbuzz User",
//     hostPic: Defaults().profilePictureUrl,
//   ),
// ];
