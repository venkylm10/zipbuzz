import 'package:intl/intl.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/event_member_model.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/models/events/requests/user_events_request_model.dart';
import 'package:zipbuzz/models/user/user_model.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/defaults.dart';

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

  final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  var focusedDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

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
    final list = await ref.read(dbServicesProvider).getUserEvents(userEventsRequestModel);
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

  String getformatedDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}

final guestEventsList = <EventModel>[
  EventModel(
    id: 1,
    title: "A Madcap House Party Extravaganza",
    hostId: 1,
    coHostIds: [],
    eventMembers: [
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
    ],
    location: "420 Gala St, San Jose 95125",
    date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    startTime: "8:00 AM",
    endTime: "12:00 PM",
    attendees: 15,
    category: "Hiking",
    favourite: false,
    bannerPath: Defaults().bannerUrls[Defaults().bannerPaths[0]]!,
    iconPath: allInterests["Hiking"]!,
    about:
        "Get ready to turn up the color dial and paint the town in a kaleidoscope of hues at the most vibrant house party of the year!",
    isPrivate: true,
    capacity: 20,
    imageUrls: [],
    privateGuestList: false,
    hostName: "Zipbuzz User",
    hostPic: Defaults().profilePictureUrl,
  ),
  EventModel(
    id: 1,
    title: "A Madcap House Party Extravaganza",
    hostId: 1,
    coHostIds: [],
    eventMembers: [
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
    ],
    location: "420 Gala St, San Jose 95125",
    date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    startTime: "8:00 AM",
    endTime: "12:00 PM",
    attendees: 15,
    category: "Sports",
    favourite: false,
    bannerPath: Defaults().bannerUrls[Defaults().bannerPaths[1]]!,
    iconPath: allInterests["Sports"]!,
    about:
        "Get ready to turn up the color dial and paint the town in a kaleidoscope of hues at the most vibrant house party of the year!",
    isPrivate: true,
    capacity: 20,
    imageUrls: [],
    privateGuestList: false,
    hostName: "Zipbuzz User",
    hostPic: Defaults().profilePictureUrl,
  ),
  EventModel(
    id: 1,
    title: "A Madcap House Party Extravaganza",
    hostId: 1,
    coHostIds: [],
    eventMembers: [
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
    ],
    location: "420 Gala St, San Jose 95125",
    date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    startTime: "8:00 AM",
    endTime: "12:00 PM",
    attendees: 15,
    category: "Hiking",
    favourite: false,
    bannerPath: Defaults().bannerUrls[Defaults().bannerPaths[2]]!,
    iconPath: allInterests["Hiking"]!,
    about:
        "Get ready to turn up the color dial and paint the town in a kaleidoscope of hues at the most vibrant house party of the year!",
    isPrivate: true,
    capacity: 20,
    imageUrls: [],
    privateGuestList: false,
    hostName: "Zipbuzz User",
    hostPic: Defaults().profilePictureUrl,
  ),
  EventModel(
    id: 1,
    title: "A Madcap House Party Extravaganza",
    hostId: 1,
    coHostIds: [],
    eventMembers: [
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
    ],
    location: "420 Gala St, San Jose 95125",
    date: DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1))),
    startTime: "8:00 AM",
    endTime: "12:00 PM",
    attendees: 15,
    category: "Fitness",
    favourite: false,
    bannerPath: Defaults().bannerUrls[Defaults().bannerPaths[0]]!,
    iconPath: allInterests["Fitness"]!,
    about:
        "Get ready to turn up the color dial and paint the town in a kaleidoscope of hues at the most vibrant house party of the year!",
    isPrivate: true,
    capacity: 20,
    imageUrls: [],
    privateGuestList: false,
    hostName: "Zipbuzz User",
    hostPic: Defaults().profilePictureUrl,
  ),
  EventModel(
    id: 1,
    title: "A Madcap House Party Extravaganza",
    hostId: 1,
    coHostIds: [],
    eventMembers: [
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
    ],
    location: "420 Gala St, San Jose 95125",
    date: DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1))),
    startTime: "8:00 AM",
    endTime: "12:00 PM",
    attendees: 15,
    category: "Parties",
    favourite: false,
    bannerPath: Defaults().bannerUrls[Defaults().bannerPaths[1]]!,
    iconPath: allInterests["Parties"]!,
    about:
        "Get ready to turn up the color dial and paint the town in a kaleidoscope of hues at the most vibrant house party of the year!",
    isPrivate: true,
    capacity: 20,
    imageUrls: [],
    privateGuestList: false,
    hostName: "Zipbuzz User",
    hostPic: Defaults().profilePictureUrl,
  ),
  EventModel(
    id: 1,
    title: "A Madcap House Party Extravaganza",
    hostId: 1,
    coHostIds: [],
    eventMembers: [
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
    ],
    location: "420 Gala St, San Jose 95125",
    date: DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: -1))),
    startTime: "8:00 AM",
    endTime: "12:00 PM",
    attendees: 15,
    category: "Fitness",
    favourite: false,
    bannerPath: Defaults().bannerUrls[Defaults().bannerPaths[2]]!,
    iconPath: allInterests["Fitness"]!,
    about:
        "Get ready to turn up the color dial and paint the town in a kaleidoscope of hues at the most vibrant house party of the year!",
    isPrivate: true,
    capacity: 20,
    imageUrls: [],
    privateGuestList: false,
    hostName: "Zipbuzz User",
    hostPic: Defaults().profilePictureUrl,
  ),
  EventModel(
    id: 1,
    title: "A Madcap House Party Extravaganza",
    hostId: 1,
    coHostIds: [],
    eventMembers: [
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Alex Lee"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "John"),
      EventMemberModel(image: Defaults().contactAvatarUrl, phone: "+18765432109", name: "Jack"),
    ],
    location: "420 Gala St, San Jose 95125",
    date: DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: -1))),
    startTime: "8:00 AM",
    endTime: "12:00 PM",
    attendees: 15,
    category: "Parties",
    favourite: false,
    bannerPath: Defaults().bannerUrls[Defaults().bannerPaths[3]]!,
    iconPath: allInterests["Parties"]!,
    about:
        "Get ready to turn up the color dial and paint the town in a kaleidoscope of hues at the most vibrant house party of the year!",
    isPrivate: true,
    capacity: 20,
    imageUrls: [],
    privateGuestList: false,
    hostName: "Zipbuzz User",
    hostPic: Defaults().profilePictureUrl,
  ),
];
