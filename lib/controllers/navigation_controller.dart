import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:zipbuzz/utils/constants/globals.dart';

final navigationProvider = Provider((ref) => NavigationController());

class NavigationController {
  static dynamic routeTo({required String route, Map<String, dynamic>? arguments}) {
    debugPrint("routeTo: $route");
    return navigatorKey.currentState?.pushNamed(route, arguments: arguments);
  }

  static dynamic routeOff({required String route, Map<String, dynamic>? arguments}) {
    debugPrint("routeOff: $route");
    return navigatorKey.currentState?.pushReplacementNamed(route, arguments: arguments);
  }

  static Route getTransition(Widget child) {
    return PageTransition(
      child: child,
      type: PageTransitionType.fade,
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 250),
    );
  }
}
