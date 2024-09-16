import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:zipbuzz/pages/chat/chat_page.dart';
import 'package:zipbuzz/pages/events/event_details_page.dart';
import 'package:zipbuzz/pages/events/edit_event_page.dart';
import 'package:zipbuzz/pages/groups/add_group_members.dart';
import 'package:zipbuzz/pages/groups/group_details_screen.dart';
import 'package:zipbuzz/pages/groups/group_events_screen.dart';
import 'package:zipbuzz/pages/groups/group_members_screen.dart';
import 'package:zipbuzz/pages/home/home.dart';
import 'package:zipbuzz/pages/notification/notification_page.dart';
import 'package:zipbuzz/pages/personalise/personalise_page.dart';
import 'package:zipbuzz/pages/profile/edit_profile_page.dart';
import 'package:zipbuzz/pages/settings/faqs_page.dart';
import 'package:zipbuzz/pages/settings/settings_notification_page.dart';
import 'package:zipbuzz/pages/sign-in/web_sign_page.dart';
import 'package:zipbuzz/pages/welcome/welcome_page.dart';
import 'package:zipbuzz/pages/splash/splash_screen.dart';
import 'package:zipbuzz/utils/widgets/no_internet_screen.dart';

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case WelcomePage.id:
      return PageTransition(
        child: const WelcomePage(),
        type: PageTransitionType.fade,
        settings: settings,
        duration: const Duration(milliseconds: 250),
        reverseDuration: const Duration(milliseconds: 250),
      );

    case PersonalisePage.id:
      return PageTransition(
        child: const PersonalisePage(),
        type: PageTransitionType.fade,
        settings: settings,
        duration: const Duration(milliseconds: 250),
        reverseDuration: const Duration(milliseconds: 250),
      );

    case Home.id:
      return PageTransition(
        child: const Home(),
        type: PageTransitionType.fade,
        settings: settings,
        duration: const Duration(milliseconds: 250),
        reverseDuration: const Duration(milliseconds: 250),
      );
    case NotificationPage.id:
      return PageTransition(
        child: const NotificationPage(),
        type: PageTransitionType.fade,
        settings: settings,
        duration: const Duration(milliseconds: 250),
        reverseDuration: const Duration(milliseconds: 250),
      );

    case FAQsPage.id:
      return PageTransition(
        child: const FAQsPage(),
        type: PageTransitionType.fade,
        settings: settings,
        duration: const Duration(milliseconds: 250),
        reverseDuration: const Duration(milliseconds: 250),
      );

    case EditProfilePage.id:
      return PageTransition(
        child: const EditProfilePage(),
        type: PageTransitionType.fade,
        settings: settings,
        duration: const Duration(milliseconds: 250),
        reverseDuration: const Duration(milliseconds: 250),
      );
    case EditEventPage.id:
      return PageTransition(
        child: const EditEventPage(),
        type: PageTransitionType.fade,
        settings: settings,
        duration: const Duration(milliseconds: 250),
        reverseDuration: const Duration(milliseconds: 250),
      );

    case ChatPage.id:
      return MaterialPageRoute(
        builder: (context) {
          final args = settings.arguments as Map<String, dynamic>;
          final event = args['event'];
          return ChatPage(event: event);
        },
      );
    case WebSignInPage.id:
      return PageTransition(
        child: const WebSignInPage(),
        type: PageTransitionType.fade,
        settings: settings,
        duration: const Duration(milliseconds: 250),
        reverseDuration: const Duration(milliseconds: 250),
      );
    case SettingsNotificationPage.id:
      return PageTransition(
        child: const SettingsNotificationPage(),
        type: PageTransitionType.fade,
        settings: settings,
        duration: const Duration(milliseconds: 250),
        reverseDuration: const Duration(milliseconds: 250),
      );
    case EventDetailsPage.id:
      final args = settings.arguments as Map<String, dynamic>;
      final event = args['event'];
      final isPreview = args['isPreview'] ?? false;
      final rePublish = args['rePublish'] ?? false;
      final dominantColor = args['dominantColor'] as Color;
      final randInt = args['randInt'] as int?;
      final clone = args['clone'] ?? false;
      final showBottomBar = args['showBottomBar'] ?? false;
      return PageTransition(
        child: EventDetailsPage(
          event: event,
          isPreview: isPreview,
          dominantColor: dominantColor,
          randInt: randInt ?? 0,
          rePublish: rePublish,
          clone: clone,
          showBottomBar: showBottomBar,
        ),
        type: PageTransitionType.fade,
        settings: settings,
        duration: const Duration(milliseconds: 250),
        reverseDuration: const Duration(milliseconds: 250),
      );

    case NoInternetScreen.id:
      return PageTransition(
        child: const NoInternetScreen(),
        type: PageTransitionType.fade,
        settings: settings,
        duration: const Duration(milliseconds: 250),
        reverseDuration: const Duration(milliseconds: 250),
      );
    case GroupEventsScreen.id:
      return PageTransition(
        child: const GroupEventsScreen(),
        type: PageTransitionType.fade,
        settings: settings,
        duration: const Duration(milliseconds: 250),
        reverseDuration: const Duration(milliseconds: 250),
      );
    case GroupDetailsScreen.id:
      return PageTransition(
        child: const GroupDetailsScreen(),
        type: PageTransitionType.fade,
        settings: settings,
        duration: const Duration(milliseconds: 250),
        reverseDuration: const Duration(milliseconds: 250),
      );
    case GroupMembersScreen.id:
      return PageTransition(
        child: const GroupMembersScreen(),
        type: PageTransitionType.fade,
        settings: settings,
        duration: const Duration(milliseconds: 250),
        reverseDuration: const Duration(milliseconds: 250),
      );
    case AddGroupMembers.id:
      return PageTransition(
        child: const AddGroupMembers(),
        type: PageTransitionType.fade,
        settings: settings,
        duration: const Duration(milliseconds: 250),
        reverseDuration: const Duration(milliseconds: 250),
      );

    default:
      return PageTransition(
        child: const SplashScreen(),
        type: PageTransitionType.fade,
        settings: settings,
        duration: const Duration(milliseconds: 250),
        reverseDuration: const Duration(milliseconds: 250),
      );
  }
}
