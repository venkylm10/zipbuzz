import 'package:zipbuzz/models/event_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final eventsControllerProvider =
    StateNotifierProvider<EventsController, List<EventModel>>(
        (ref) => EventsController());

class EventsController extends StateNotifier<List<EventModel>> {
  EventsController() : super([]);
  List<EventModel> selectedDayEvents = events[DateTime.now()] ?? [];

  void updateEvents(DateTime focusedDay) {
    state = events[focusedDay] ?? [];
  }
}
