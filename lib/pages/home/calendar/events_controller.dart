import 'package:zipbuzz/models/event_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final eventsControllerProvider =
    StateNotifierProvider<EventsController, List<EventModel>>(
        (ref) => EventsController(ref: ref));

class EventsController extends StateNotifier<List<EventModel>> {
  final Ref ref;
  EventsController({required this.ref}) : super([]);
  List<EventModel> selectedDayEvents = events[DateTime.now()] ?? [];
  String selectedCategory = '';

  void updateEvents(DateTime focusedDay) {
    state = events[focusedDay] ?? [];
  }

  void updateCategory({String? category = ''}) {
    selectedCategory = category ?? '';
  }
}
