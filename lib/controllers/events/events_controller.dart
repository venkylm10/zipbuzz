import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
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

final eventsControllerProvider = StateNotifierProvider<EventsControllerProvider, EventsController>(
  (ref) => EventsControllerProvider(ref: ref, user: ref.watch(userProvider)),
);

class EventsControllerProvider extends StateNotifier<EventsController> {
  final UserModel? user;
  final Ref ref;
  EventsControllerProvider({required this.ref, required this.user})
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

  void selectCategory({String? category = ''}) {
    state = state.copyWith(selectedCategory: category ?? '');
  }

  Future<void> fetchEvents() async {
    final day = currentDay;
    var month = day.month.toString();
    month = month.length == 1 ? '0$month' : month;
    final year = day.year.toString();
    final userEventsRequestModel = UserEventsRequestModel(
        userId: ref.read(userProvider).id,
        month: "$year-$month",
        category: ref.read(userProvider).interests);
    final list = await ref.read(dbServicesProvider).getAllEvents(userEventsRequestModel);
    state = state.copyWith(currentMonthEvents: list);
    adjustEventData();
  }

  void updateEventsMap() {
    Map<DateTime, List<EventModel>> map = {};
    for (final event in state.currentMonthEvents) {
      final date = getDateTimeFromEventData(event.date);
      if (map.containsKey(date)) {
        map[date]!.add(event);
      } else {
        map[date] = [event];
      }
    }
    state = state.copyWith(eventsMap: map);
  }

  void updateUpcomingEvents() {
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

  void adjustEventData() {
    updateEventsMap();
    updateFocusedEvents();
    updateUpcomingEvents();
    updatePastEvents();
  }

  Future<void> fetchUserEvents() async {
    state = state.copyWith(loading: true);
    final list = await ref.read(dbServicesProvider).getUserEvents();
    state = state.copyWith(userEvents: list);
    adjustUserEvents();
    state = state.copyWith(loading: false);
  }

  void updateUserEventsMap() {
    Map<DateTime, List<EventModel>> map = {};
    for (final event in state.userEvents) {
      final date = getDateTimeFromEventData(event.date);
      if (map.containsKey(date)) {
        map[date]!.add(event);
      } else {
        map[date] = [event];
      }
    }
    state = state.copyWith(userEventsMap: map);
  }

  void updateUpcomingUserEvents() {
    var events = <EventModel>[];
    state.userEventsMap.forEach((key, value) {
      if (key.isAfter(state.today) || key.isAtSameMomentAs(state.today)) {
        events.addAll(value);
      }
    });
    events.sort((a, b) => a.date.compareTo(b.date));
    state = state.copyWith(userUpcomingEvents: events);
  }

  void updatePastUserEvents() {
    var events = <EventModel>[];
    state.userEventsMap.forEach((key, value) {
      if (key.isBefore(state.today)) {
        events.addAll(value);
      }
    });
    events.sort((a, b) => b.date.compareTo(a.date));
    state = state.copyWith(userPastEvents: events);
  }

  void adjustUserEvents() {
    updateUserEventsMap();
    updateUpcomingUserEvents();
    updatePastUserEvents();
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
      final day = currentDay;
      var month = day.month.toString();
      month = month.length == 1 ? '0$month' : month;
      final year = day.year.toString();
      final userEventsRequestModel = UserEventsRequestModel(
        userId: ref.read(userProvider).id,
        month: "$year-$month",
        category: ref.read(userProvider).interests,
      );
      final list = await ref.read(dbServicesProvider).getUserFavoriteEvents(userEventsRequestModel);
      state = state.copyWith(currentMonthEvents: list);
      adjustEventData();
      return;
    }
    state = state.copyWith(showingFavorites: false);
    fetchEvents();
  }

  Future<void> addEventToFavorites(int eventId) async {
    final model = AddEventToFavoriteModelClass(eventId: eventId, userId: ref.read(userProvider).id);
    await ref.read(dioServicesProvider).addEventToFavorite(model);
  }

  Future<void> removeEventFromFavorites(int eventId) async {
    final model = AddEventToFavoriteModelClass(eventId: eventId, userId: ref.read(userProvider).id);
    await ref.read(dioServicesProvider).removeEventFromFavorite(model);
    if (state.showingFavorites) {
      var events = state.currentMonthEvents;
      events.removeWhere((element) => element.id == eventId);
      state = state.copyWith(currentMonthEvents: events);
      adjustEventData();
    }
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
      // print(item.color);
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

  static Color hexStringToColor(String hexColor) {
    if (hexColor.startsWith('0x') || hexColor.startsWith('0X')) {
      hexColor = hexColor.substring(2);
    }
    if (hexColor.length == 6) {
      hexColor = "ff$hexColor";
    }
    int hexValue = int.tryParse(hexColor, radix: 16) ?? int.parse("ffffff", radix: 16);
    return Color(hexValue);
  }

  Future<bool> requestToJoinEvent(int eventId) async {
    final user = ref.read(userProvider);
    final model = JoinEventRequestModel(
        eventId: eventId,
        name: user.name,
        phoneNumber: user.mobileNumber,
        image: user.imageUrl,
        userId: user.id);
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
    return links;
  }

  void updateLoadingState(bool loading) {
    state = state.copyWith(loading: loading);
  }

  DateTime currentDay = DateTime.now();

  void updateCurrentDay(DateTime day) async {
    currentDay = day;
  }

  void shareEvent(EventModel event) {
    final eventUrl = event.inviteUrl;
    final article = "aeiou".contains(event.category[0].toLowerCase()) ? "an" : "a";

    final formattedDate = _formatDateTime(DateTime.parse(event.date));
    // const playStore =
    //     'Play Store : https://play.google.com/store/apps/details?id=com.abacus.zipbuzz';

    // const appStore = 'App Store : https://apps.apple.com/in/app/buzz-me/id6477519288';

    final shareText =
        "${event.hostName} has invited you for $article ${event.category} event via Buzz.Me:\n${event.title}\nInvitation: ${event.about}\nDate: $formattedDate at ${event.startTime}\nLocation: ${event.location}\n\nMore details at : $eventUrl\n\nDownload Buzz.Me at https://zipbuzz.me/";
    Share.share(shareText);
  }

  String _formatDateTime(DateTime dateTime) {
    String month = DateFormat('MMM').format(dateTime);
    String day = DateFormat('dd').format(dateTime);
    String year = DateFormat('yyyy').format(dateTime);
    String dayOfWeek = DateFormat('EEEE').format(dateTime);
    return '$month-$day-$year ($dayOfWeek)';
  }
}

class EventsController {
  final UserModel? user;
  final Ref ref;
  EventsController({required this.ref, required this.user});
  List<EventModel> currentMonthEvents = [];
  List<EventModel> userEvents = [];
  List<EventModel> upcomingEvents = [];
  List<EventModel> pastEvents = [];
  List<EventModel> userUpcomingEvents = [];
  List<EventModel> userPastEvents = [];
  List<EventModel> focusedEvents = [];
  Map<DateTime, List<EventModel>> eventsMap = {};
  Map<DateTime, List<EventModel>> userEventsMap = {};
  String selectedCategory = '';
  double calenderHeight = 150;
  bool showingFavorites = false;
  bool loading = false;
  TextEditingController activitySearchController = TextEditingController();

  final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  var focusedDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  EventsController copyWith({
    UserModel? user,
    Ref? ref,
    List<EventModel>? currentMonthEvents,
    List<EventModel>? userEvents,
    List<EventModel>? upcomingEvents,
    List<EventModel>? pastEvents,
    List<EventModel>? userUpcomingEvents,
    List<EventModel>? userPastEvents,
    List<EventModel>? focusedEvents,
    Map<DateTime, List<EventModel>>? eventsMap,
    Map<DateTime, List<EventModel>>? userEventsMap,
    String? selectedCategory,
    double? calenderHeight,
    bool? showingFavorites,
    DateTime? focusedDay,
    bool? loading,
  }) {
    var res = EventsController(
      user: user ?? this.user,
      ref: ref ?? this.ref,
    );
    res.userEvents = userEvents ?? this.userEvents;
    res.userEventsMap = userEventsMap ?? this.userEventsMap;
    res.currentMonthEvents = currentMonthEvents ?? this.currentMonthEvents;
    res.userUpcomingEvents = userUpcomingEvents ?? this.userUpcomingEvents;
    res.userPastEvents = userPastEvents ?? this.userPastEvents;
    res.focusedEvents = focusedEvents ?? this.focusedEvents;
    res.eventsMap = eventsMap ?? this.eventsMap;
    res.selectedCategory = selectedCategory ?? this.selectedCategory;
    res.calenderHeight = calenderHeight ?? this.calenderHeight;
    res.showingFavorites = showingFavorites ?? this.showingFavorites;
    res.focusedDay = focusedDay ?? this.focusedDay;
    res.loading = loading ?? this.loading;
    res.upcomingEvents = upcomingEvents ?? this.upcomingEvents;
    res.pastEvents = pastEvents ?? this.pastEvents;
    return res;
  }
}
