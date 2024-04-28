import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/events_tab_controler.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/interests/requests/user_interests_update_model.dart';
import 'package:zipbuzz/models/interests/responses/interest_model.dart';
import 'package:zipbuzz/pages/home/activities_sheet.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/widgets/home/custom_appbar.dart';
import 'package:zipbuzz/widgets/home/home_calendar.dart';
import 'package:zipbuzz/widgets/home/event_search_results.dart';

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

  void onTapGridCategory(String interest) async {
    ref.read(homeTabControllerProvider.notifier).updateSearching(true);
    ref.read(homeTabControllerProvider.notifier).updateRowInterests(true);
    final selectedCategory = ref.read(homeTabControllerProvider).selectedCategory;
    if (selectedCategory != interest) {
      ref.read(homeTabControllerProvider.notifier).selectCategory(category: interest);
      scrollDownInterests();
      await Future.delayed(const Duration(milliseconds: 500));
      // ref.read(homeTabControllerProvider.notifier).scrollToRowCategory();
    } else {
      ref.read(homeTabControllerProvider.notifier).selectCategory(category: '');
    }
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
        appBar: CustomAppBar(
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
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: homeTabController.bodyScrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildInterests(context),
                  buildPageIndicator(),
                  buildHomeTabButtons(),
                  const SizedBox(height: 10),
                  homeTabController.queryController.text.trim().isNotEmpty
                      ? const EventsSearchResults()
                      : const SizedBox(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                    child: Text(
                      "My Calendar Events",
                      style: AppStyles.h2,
                    ),
                  ),
                  const HomeCalender(),
                  const SizedBox(height: 200)
                ],
              ),
            ),
            buildCategoryRow(),
          ],
        ),
      ),
    );
  }

  Widget buildHomeTabButtons() {
    return Row(
      key: ref.read(homeTabControllerProvider.notifier).homeButtonsKey,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Wrap(
          direction: Axis.horizontal,
          runAlignment: WrapAlignment.center,
          runSpacing: 8,
          spacing: 8,
          children: [
            InkWell(
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
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(360),
                  border: Border.all(color: Colors.white),
                  color: AppColors.primaryColor,
                ),
                child: Text(
                  "Explore",
                  style: AppStyles.h4.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                ref.read(homeTabControllerProvider.notifier).updateIndex(1);
                ref.read(eventTabControllerProvider.notifier).updateIndex(2);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(360),
                  border: Border.all(color: Colors.white),
                  color: AppColors.primaryColor,
                ),
                child: Text(
                  "Create Event",
                  style: AppStyles.h4.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                ref.read(homeTabControllerProvider.notifier).updateIndex(1);
                ref.read(eventTabControllerProvider.notifier).updateIndex(0);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(360),
                  border: Border.all(color: Colors.white),
                  color: AppColors.primaryColor,
                ),
                child: Text(
                  "My Events",
                  style: AppStyles.h4.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget buildCategoryRow() {
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
          return SizedBox(
            width: kIsWeb
                ? MediaQuery.of(context).size.height * Assets.images.border_ratio * 0.94 - 60
                : null,
            child: ScrollConfiguration(
              behavior: MyCustomScrollBehavior(),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: isSearching ? const PageScrollPhysics() : const BouncingScrollPhysics(),
                controller: ref.watch(homeTabControllerProvider.notifier).pageScrollController,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    (userInterests.length / 8).ceil(),
                    (index) {
                      var interests = userInterests;
                      if (interests.length > 8) {
                        interests = userInterests.sublist(
                            index * 8,
                            (index + 1) * 8 > userInterests.length
                                ? userInterests.length
                                : (index + 1) * 8);
                      }
                      return buildCategoryPage(index, context, interests);
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildPageIndicator() {
    final index = ref.watch(homeTabControllerProvider).index;
    return Consumer(
      builder: (context, ref, child) {
        final homeTabController = ref.watch(homeTabControllerProvider);
        final userInterests = homeTabController.currentInterests;
        return userInterests.length > 8
            ? Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  (userInterests.length / 8).ceil(),
                  (pageIndex) => Container(
                    height: 6,
                    width: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index == pageIndex ? AppColors.primaryColor : Colors.grey[350],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              )
            : const SizedBox();
      },
    );
  }

  Widget buildCategoryPage(
    int pageIndex,
    BuildContext context,
    List<InterestModel> interests,
  ) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      width:
          kIsWeb ? MediaQuery.of(context).size.height * Assets.images.border_ratio * 0.94 : width,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20).copyWith(top: 10),
      child: GridView.count(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
          interests.length,
          (index) {
            final interest = interests[index];
            return InkWell(
              onTap: () => onTapGridCategory(interest.activity),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    constraints: const BoxConstraints(minHeight: 50),
                    child: Image.network(
                      interest.iconUrl,
                      height: 40,
                    ),
                  ),
                  Text(
                    interest.activity,
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppStyles.h5,
                  ),
                ],
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
