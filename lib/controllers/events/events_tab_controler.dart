import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/pages/events/create_event_tab.dart';
import 'package:zipbuzz/pages/events/past_events.dart';
import 'package:zipbuzz/pages/events/upcoming_events.dart';

final eventTabControllerProvider = StateNotifierProvider<EventTabController, int>((ref) {
  return EventTabController(ref: ref);
});

class EventTabController extends StateNotifier<int> {
  final Ref ref;
  EventTabController({required this.ref}) : super(0);
  var selectedIndex = 0;
  var tabs = const [UpcomingEvents(), PastEvents(), CreateEventTab()];
  var tabTitles = const ["Upcoming", "Past", "Create"];

  void updateIndex(int index) {
    selectedIndex = index;
    state = selectedIndex;
    ref.read(eventsControllerProvider.notifier).fetchUserEvents();
  }
}
