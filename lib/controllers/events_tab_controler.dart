import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/pages/events/create_event_tab.dart';
import 'package:zipbuzz/pages/events/past_events.dart';
import 'package:zipbuzz/pages/events/upcoming_events.dart';

final eventTabControllerProvider =
    StateNotifierProvider<EventTabController, int>((ref) {
  return EventTabController();
});

class EventTabController extends StateNotifier<int> {
  EventTabController() : super(0);
  var selectedIndex = 0;
  var tabs = const [UpcomingEvents(), PastEvents(), CreateEvent()];
  var tabTitles = const ["Upcoming", "Past", "Create"];

  void updateIndex(int index) {
    selectedIndex = index;
    state = selectedIndex;
  }
}
