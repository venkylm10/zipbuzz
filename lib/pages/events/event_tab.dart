import 'package:flutter/material.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/pages/events/create_event_tab.dart';
import 'package:zipbuzz/pages/events/past_events.dart';
import 'package:zipbuzz/pages/events/upcoming_events.dart';

class EventsTab extends StatefulWidget {
  const EventsTab({super.key});

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  int selectedTab = 2;
  final tabs = ["Upcoming", "Past", "Create"];
  final tabPages = const [UpcomingEvents(), PastEvents(), CreateEvent()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Events",
          style: AppStyles.h2.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ),
        leading: const SizedBox(),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.borderGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: List.generate(
                    tabs.length,
                    (index) => Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTab = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: selectedTab == index
                                ? AppColors.bgGrey
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              tabs[index],
                              style: AppStyles.h5.copyWith(
                                color: selectedTab == index
                                    ? AppColors.primaryColor
                                    : AppColors.textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              tabPages[selectedTab],
            ],
          ),
        ),
      ),
    );
  }
}
