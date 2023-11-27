import 'package:zipbuzz/models/event_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final eventsControllerProvider = Provider((ref) => EventsController(ref: ref));

class EventsController {
  final Ref ref;
  EventsController({required this.ref});

  List<EventModel> upcomingEvents = [];
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

  void getUpcomingEvents() {
    upcomingEvents.clear();
    events.forEach((key, value) {
      if (key.isAfter(today) || key.isAtSameMomentAs(today)) {
        upcomingEvents.addAll(value);
      }
    });
    upcomingEvents.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  void selectCategory({String? category = ''}) {
    selectedCategory = category ?? '';
  }
}
