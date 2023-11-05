import 'package:flutter_riverpod/flutter_riverpod.dart';

final calendarControllerProvider = Provider((ref) => CalendarController());

class CalendarController {
  var focusedDay = DateTime.now();
  void updatedFocusedDay(DateTime dateTime) {
    focusedDay = dateTime;
  }
}
