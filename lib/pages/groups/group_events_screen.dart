import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/controllers/navigation_controller.dart';
import 'package:zipbuzz/models/groups/res/group_description_res.dart';
import 'package:zipbuzz/pages/groups/create_group_event_screen.dart';
import 'package:zipbuzz/pages/groups/group_details_screen.dart';
import 'package:zipbuzz/pages/groups/widgets/group_event_calendar.dart';
import 'package:zipbuzz/pages/groups/widgets/group_event_screen_tabs.dart';
import 'package:zipbuzz/pages/home/home.dart';
import 'package:zipbuzz/pages/home/widgets/bottom_bar.dart';
import 'package:zipbuzz/pages/home/widgets/event_card.dart';
import 'package:zipbuzz/pages/home/widgets/no_upcoming_events_banner.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/tabs.dart';
import 'package:zipbuzz/utils/widgets/custom_bezel.dart';

class GroupEventsScreen extends ConsumerStatefulWidget {
  static const id = '/groups/group-events';
  const GroupEventsScreen({super.key});

  @override
  ConsumerState<GroupEventsScreen> createState() => _GroupEventsScreenState();
}

class _GroupEventsScreenState extends ConsumerState<GroupEventsScreen> {
  late GroupDescriptionModel groupDescription;

  @override
  void initState() {
    groupDescription = ref.read(groupControllerProvider).currentGroupDescription!;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(groupControllerProvider.notifier).fetchGroupEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomBezel(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: ListView(
          children: [
            const GroupEventScreenTabs(),
            const SizedBox(height: 12),
            _buildCalendar(),
            _buildFocusedDayEvents(),
            _buildUpcomingEvents(),
          ],
        ),
        floatingActionButton: _floatingButton(),
        bottomNavigationBar: BottomBar(
          selectedTab: ref.watch(homeTabControllerProvider).selectedTab.index,
          pop: () {
            navigatorKey.currentState!.pushNamedAndRemoveUntil(Home.id, (route) => false);
          },
        ),
      ),
    );
  }

  Widget _floatingButton() {
    return Consumer(builder: (context, ref, child) {
      final eventMap = ref.watch(groupControllerProvider).currentGroupMonthEventsMap;
      final focusedDay = ref.watch(groupControllerProvider).focusedDay;
      final focusedEvents = eventMap[focusedDay] ?? [];
      final upcoming = ref.watch(groupControllerProvider).groupEventsTab == GroupEventsTab.upcoming;
      final today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      final calendar = ref.watch(groupControllerProvider).showCalendar;
      final events = ref.watch(groupControllerProvider).currentGroupMonthEvents.where((e) {
        final eventDay = DateFormat('yyyy-MM-dd').parse(e.date);
        return (upcoming
                ? eventDay.isAtSameMomentAs(today) || eventDay.isAfter(today)
                : eventDay.isBefore(today)) &&
            (!focusedEvents.contains(e) || !calendar);
      }).toList();
      if (events.isEmpty && focusedEvents.isEmpty) return const SizedBox();
      if (!upcoming && events.isEmpty) return const SizedBox();
      return GestureDetector(
        onTap: () {
          navigatorKey.currentState!.push(
            NavigationController.getTransition(const CreateGroupEventScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(360),
            color: const Color(0xff1F98A9),
          ),
          child: Text(
            "Create Group Event",
            style: AppStyles.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildUpcomingEvents() {
    return Consumer(
      builder: (context, ref, child) {
        final upcoming =
            ref.watch(groupControllerProvider).groupEventsTab == GroupEventsTab.upcoming;
        final today = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );
        final eventMap = ref.watch(groupControllerProvider).currentGroupMonthEventsMap;
        final focusedDay = ref.watch(groupControllerProvider).focusedDay;
        final focusedEvents = eventMap[focusedDay] ?? [];
        final calendar = ref.watch(groupControllerProvider).showCalendar;
        final events = ref.watch(groupControllerProvider).currentGroupMonthEvents.where((e) {
          final eventDay = DateFormat('yyyy-MM-dd').parse(e.date);
          return (upcoming
                  ? eventDay.isAtSameMomentAs(today) || eventDay.isAfter(today)
                  : eventDay.isBefore(today)) &&
              (!focusedEvents.contains(e) || !calendar);
        }).toList();
        if (events.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 44),
            child: NoUpcomingEventsBanner(
              title: "No ${upcoming ? "Upcoming " : "Past "}events lined up",
              subtitle: "Your group events will show up here",
              onTap: (ref) {
                navigatorKey.currentState!.push(
                  NavigationController.getTransition(const CreateGroupEventScreen()),
                );
              },
              buttonLabel: "Create Group Event",
            ),
          );
        }
        return ListView.builder(
          itemCount: events.length + (calendar ? 1 : 0),
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            if (index == 0 && calendar) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "Upcoming Events",
                    style: AppStyles.h3.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }
            return EventCard(event: events[index - (calendar ? 1 : 0)], groupEvent: true);
          },
        );
      },
    );
  }

  Widget _buildFocusedDayEvents() {
    return Consumer(builder: (context, ref, child) {
      final calendar = ref.watch(groupControllerProvider).showCalendar;
      if (!calendar) return const SizedBox();
      final eventMap = ref.watch(groupControllerProvider).currentGroupMonthEventsMap;
      final focusedDay = ref.watch(groupControllerProvider).focusedDay;
      final events = eventMap[focusedDay] ?? [];
      return ListView.builder(
        itemCount: events.length,
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return EventCard(event: events[index], groupEvent: true);
        },
      );
    });
  }

  Consumer _buildCalendar() {
    return Consumer(builder: (context, ref, child) {
      if (!ref.watch(groupControllerProvider).showCalendar) {
        return const SizedBox();
      }
      return const GroupEventCalendar();
    });
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        groupDescription.groupName,
        style: AppStyles.h2.copyWith(fontWeight: FontWeight.w600),
      ),
      leadingWidth: 80,
      leading: Row(
        children: [
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              navigatorKey.currentState!.pop();
            },
            child: const Icon(Icons.arrow_back_ios),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.network(
              groupDescription.groupProfileImage,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: CupertinoActivityIndicator(),
                  ),
                );
              },
            ),
          )
        ],
      ),
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () {
            ref.read(groupControllerProvider.notifier).updateLoading(false);
            navigatorKey.currentState!.pushNamed(GroupDetailsScreen.id);
          },
          icon: const Icon(
            Icons.more_horiz_rounded,
            color: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }
}
