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
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/pages/home/widgets/custom_appbar.dart';
import 'package:zipbuzz/pages/home/widgets/event_search_results.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  double topPadding = 0;
  bool isMounted = true;
  double width = 0;

  @override
  void initState() {
    if (isMounted) {
      ref.read(homeTabControllerProvider.notifier).pageScrollController.addListener(() {
        if (!isMounted) return;
        final check = ref.read(homeTabControllerProvider.notifier).updatePageIndex(context);
        if (check && mounted) setState(() {});
      });
    }
    ref.read(homeTabControllerProvider.notifier).bodyScrollController.addListener(
      () {
        if (!isMounted) return;
        final check =
            ref.read(homeTabControllerProvider.notifier).bodyScrollController.offset == 0 &&
                ref.read(homeTabControllerProvider).isSearching;
        if (check) {
          if (isMounted) ref.read(homeTabControllerProvider.notifier).selectCategory(category: '');
          if (isMounted) ref.read(homeTabControllerProvider.notifier).updateSearching(false);
        }
        if (width == 0) {
          width = MediaQuery.of(context).size.width * 0.6;
        }
        final rowInterests = ref.read(homeTabControllerProvider).rowInterests;
        if (ref.read(homeTabControllerProvider.notifier).bodyScrollController.offset > width &&
            !rowInterests) {
          if (mounted) ref.read(homeTabControllerProvider.notifier).updateRowInterests(true);
        }
        if (ref.read(homeTabControllerProvider.notifier).bodyScrollController.offset < width &&
            rowInterests) {
          if (mounted) ref.read(homeTabControllerProvider.notifier).updateRowInterests(false);
        }
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    isMounted = false;
    super.dispose();
  }

  void onTapRowCategory(String interest) {
    final selectedCategory = ref.read(homeTabControllerProvider).selectedCategory;
    if (selectedCategory != interest) {
      ref.read(homeTabControllerProvider.notifier).selectCategory(category: interest);
    } else {
      ref.read(homeTabControllerProvider.notifier).selectCategory(category: '');
    }
    setState(() {});
  }

  void toggleHomeCategory(String interest) async {
    await ref.read(homeTabControllerProvider.notifier).toggleHomeCategory(interest);
    scrollDownInterests();
  }

  void scrollDownInterests() {
    ref.read(homeTabControllerProvider.notifier).bodyScrollController.animateTo(width * 1.1,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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
              controller: homeTabController.bodyScrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildInterests(context),
                  homeTabController.queryController.text.trim().isNotEmpty
                      ? const EventsSearchResults()
                      : const SizedBox(),
                  const SizedBox(height: 8),
                  const HomeUpcomingEvents(),
                  const SizedBox(height: 200)
                ],
              ),
            ),
            _buildScrolledCategoryRow(),
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
              color: const Color(0xff1F98A9),
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
        setState(() {});
      },
      updateFavoriteEvents: () async {
        await ref.read(eventsControllerProvider.notifier).updateFavoriteEvents();
        setState(() {});
      },
      topPadding: topPadding,
    );
  }

  Widget _buildScrolledCategoryRow() {
    final index = ref.watch(homeTabControllerProvider).index;
    final selectedCategory = ref.watch(eventsControllerProvider).selectedCategory;
    final rowInterests = ref.watch(homeTabControllerProvider).rowInterests;
    return rowInterests
        ? AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Consumer(
              builder: (context, ref, child) {
                final homeTabController = ref.watch(homeTabControllerProvider);
                final userInterests = homeTabController.currentInterests;
                return Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: ScrollConfiguration(
                    behavior: MyCustomScrollBehavior(),
                    child: SingleChildScrollView(
                      controller: ref.watch(homeTabControllerProvider.notifier).rowScrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: userInterests.map((e) {
                            final name = e.activity;
                            final iconPath = e.iconUrl;
                            return InkWell(
                              onTap: () {
                                onTapRowCategory(name);
                              },
                              child: Container(
                                key: selectedCategory == name
                                    ? ref.read(homeTabControllerProvider.notifier).rowCategoryKey
                                    : null,
                                margin: EdgeInsets.only(
                                  top: 5,
                                  left: index == 0 ? 12 : 2,
                                  right: index == allInterests.length - 1 ? 12 : 2,
                                  bottom: 5,
                                ),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: homeTabController.selectedCategory == name
                                      ? Colors.green.withOpacity(0.15)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Image.network(
                                  iconPath,
                                  height: 30,
                                ),
                              ),
                            );
                          }).toList()),
                    ),
                  ),
                );
              },
            ),
          )
        : const SizedBox();
  }

  Widget buildInterests(BuildContext context) {
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
                toggleHomeCategory: () {
                  toggleHomeCategory(interest.activity);
                },
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
