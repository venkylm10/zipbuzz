import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/utils/constants/globals.dart';

final navigationProvider = Provider((ref) => NavigationController());

class NavigationController {
  static dynamic routeTo(
      {required String route, Map<String, dynamic>? arguments}) {
    return navigatorKey.currentState?.pushNamed(route, arguments: arguments);
  }

  static dynamic routeOff(
      {required String route, Map<String, dynamic>? arguments}) {
    return navigatorKey.currentState
        ?.pushReplacementNamed(route, arguments: arguments);
  }
}
