import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/events_tab_controler.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/interests/requests/user_interests_update_model.dart';
import 'package:zipbuzz/models/interests/responses/interest_model.dart';
import 'package:zipbuzz/pages/home/activities_sheet.dart';
import 'package:zipbuzz/pages/home/widgets/home_interest_chip.dart';
import 'package:zipbuzz/pages/home/widgets/home_upcoming_events.dart';
import 'package:zipbuzz/pages/splash/widgets/version_check_pop_up.dart';
import 'package:zipbuzz/services/contact_services.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/pages/home/widgets/custom_appbar.dart';
import 'package:zipbuzz/utils/tabs.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  double topPadding = 0;
  bool isMounted = true;

  @override
  void initState() {
    if (isMounted) {
      ref.read(homeTabControllerProvider.notifier).pageScrollController.addListener(() {
        if (!isMounted) return;
        final check = ref.read(homeTabControllerProvider.notifier).updatePageIndex(context);
        if (check && mounted) setState(() {});
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contactsServicesProvider).updateAllContacts();
      _checkLatestVersion();
    });
    super.initState();
  }

  @override
  void dispose() {
    isMounted = false;
    super.dispose();
  }

  void _checkLatestVersion() async {
    final isLatest = await ref.read(dioServicesProvider).isLatestAppVersion();
    if (!isLatest) {
      await showDialog(
        context: navigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (context) {
          return const LatestVersionCheckPopUp();
        },
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    topPadding = MediaQuery.of(context).padding.top;
    final homeTabController = ref.watch(homeTabControllerProvider.notifier);
    var isSearching = ref.watch(homeTabControllerProvider).isSearching;
    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dy > 120 && isSearching) {
          if (ref.read(homeTabControllerProvider).isSearching) {
            ref.read(homeTabControllerProvider.notifier).updateSearching(false);
            setState(() {});
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(isSearching, homeTabController),
        body: Stack(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInterests(context),
                  // homeTabController.queryController.text.trim().isNotEmpty
                  //     ? const EventsSearchResults()
                  //     : const SizedBox(),
                  const SizedBox(height: 8),
                  const HomeUpcomingEvents(),
                  const SizedBox(height: 200)
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: InkWell(
          onTap: () {
            ref.read(homeTabControllerProvider.notifier).updateSelectedTab(AppTabs.events);
            ref.read(eventTabControllerProvider.notifier).updateIndex(2);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(360),
              color: AppColors.buttonColor,
            ),
            child: Text(
              "Create Event",
              style: AppStyles.h4.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  CustomAppBar _buildAppBar(bool isSearching, HomeTabController homeTabController) {
    return CustomAppBar(
      isSearching: isSearching,
      toggleSearching: () {
        homeTabController.updateSearching(!isSearching);
        if (isSearching) {
          ref.read(eventsControllerProvider.notifier).fetchEvents();
        }
        setState(() {});
      },
      topPadding: topPadding,
    );
  }

  Widget _buildInterests(BuildContext context) {
    final isSearching = ref.watch(homeTabControllerProvider).isSearching;
    return AnimatedOpacity(
      key: ref.read(homeTabControllerProvider.notifier).categoryPageKey,
      duration: const Duration(milliseconds: 500),
      opacity: !isSearching ? 1 : 0.5,
      child: Consumer(
        builder: (context, ref, child) {
          final homeTabController = ref.watch(homeTabControllerProvider);
          final userInterests = homeTabController.currentInterests
            ..sort((a, b) => a.activity.compareTo(b.activity));
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "My Interests",
                      style: AppStyles.h3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildShowInterestModalButton(context, ref),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              _buildCategoryRow(userInterests.sublist(0, userInterests.length ~/ 2)),
              _buildCategoryRow(userInterests.sublist(userInterests.length ~/ 2)),
            ],
          );
        },
      ),
    );
  }

  InkWell _buildShowInterestModalButton(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          enableDrag: true,
          isDismissible: true,
          builder: (context) {
            return const ActivitiesSheet();
          },
        );
        await ref.read(dioServicesProvider).updateUserInterests(
              UserInterestsUpdateModel(
                userId: ref.read(userProvider).id,
                interests: ref
                    .read(homeTabControllerProvider)
                    .currentInterests
                    .map((e) => e.activity)
                    .toList(),
              ),
            );
        debugPrint("Updated homeTab interests");
        ref.read(eventsControllerProvider.notifier).fetchEvents();
        setState(() {});
      },
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryColor,
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryRow(List<InterestModel> interests) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          interests.length,
          (index) {
            final first = index == 0;
            final last = index == interests.length - 1;
            final interest = interests[index];
            return Padding(
              padding: EdgeInsets.only(left: first ? 12 : 0, right: last ? 12 : 0),
              child: HomeInterestChip(
                interest: interest,
                toggleHomeCategory: () {},
              ),
            );
          },
        ),
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}
