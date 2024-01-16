import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/interests/responses/interest_model.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/widgets/home/custom_appbar.dart';
import 'package:zipbuzz/widgets/home/custom_calendar.dart';

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
        if (isMounted) ref.read(homeTabControllerProvider.notifier).updatePageIndex(context);
        if (isMounted) setState(() {});
      });
    }
    if (isMounted) {
      ref.read(homeTabControllerProvider.notifier).bodyScrollController.addListener(() {
        if (isMounted) ref.read(homeTabControllerProvider.notifier).updateBodyScrollController();
        if (isMounted) setState(() {});
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    isMounted = false;
    super.dispose();
  }

  void onTapRowCategory(String interest) {
    final selectedCategory = ref.read(eventsControllerProvider).selectedCategory;
    if (selectedCategory != interest) {
      ref.read(eventsControllerProvider.notifier).selectCategory(category: interest);
      setState(() {});
    } else {
      ref.read(eventsControllerProvider.notifier).selectCategory(category: '');
      setState(() {});
    }
  }

  void onTapGridCategory(String interest) {
    scrollDownInterests();
    ref.read(eventsControllerProvider.notifier).selectCategory(category: interest);
    setState(() {});
  }

  void scrollDownInterests() {
    final categoryPageKey = ref.read(homeTabControllerProvider.notifier).categoryPageKey;
    final RenderBox renderBox = categoryPageKey.currentContext!.findRenderObject() as RenderBox;
    final containerHeight = renderBox.size.height;
    ref.read(homeTabControllerProvider.notifier).bodyScrollController.animateTo(
          containerHeight - 50,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
  }

  @override
  Widget build(BuildContext context) {
    topPadding = MediaQuery.of(context).padding.top;
    final homeTabController = ref.watch(homeTabControllerProvider.notifier);
    var isSearching = homeTabController.isSearching;
    // ignore: unused_local_variable
    var showingFavorites = ref.watch(eventsControllerProvider).showingFavorites;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        isSearching: isSearching,
        searchController: homeTabController.queryController,
        onSearch: (query) => FocusScope.of(context).nextFocus(),
        toggleSearching: () {
          setState(() {
            isSearching = !isSearching;
          });
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
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                  child: Text(
                    "My Calendar Events",
                    style: AppStyles.h2,
                  ),
                ),
                const CustomCalendar(),
                const SizedBox(height: 400)
              ],
            ),
          ),
          buildCategoryRow(),
        ],
      ),
    );
  }

  Widget buildCategoryRow() {
    final isSearching = ref.watch(homeTabControllerProvider.notifier).isSearching;
    final index = ref.watch(homeTabControllerProvider.notifier).index;
    final selectedCategory = ref.watch(eventsControllerProvider).selectedCategory;
    final userInterests = allInterests
        .where(
          (element) => ref.read(userProvider).interests.contains(element.activity),
        )
        .toList();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: !isSearching
          ? Container(
              width: double.infinity,
              color: Colors.white,
              child: SingleChildScrollView(
                controller: ref.watch(homeTabControllerProvider.notifier).rowScrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: userInterests.map((e) {
                      final name = e.activity;
                      final iconPath = e.iconUrl;
                      return GestureDetector(
                        onTap: () => onTapRowCategory(name),
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
                            color: ref.watch(eventsControllerProvider).selectedCategory == name
                                ? Colors.green.withOpacity(0.15)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Opacity(
                            opacity: ref.watch(eventsControllerProvider).selectedCategory == name
                                ? 1
                                : 0.5,
                            child: Image.network(
                              iconPath,
                              height: 30,
                            ),
                          ),
                        ),
                      );
                    }).toList()),
              ),
            )
          : const SizedBox(),
    );
  }

  Widget buildInterests(BuildContext context) {
    final isSearching = ref.watch(homeTabControllerProvider.notifier).isSearching;
    final userInterests = allInterests
        .where(
          (element) => ref.read(userProvider).interests.contains(element.activity),
        )
        .toList();
    return AnimatedOpacity(
      key: ref.read(homeTabControllerProvider.notifier).categoryPageKey,
      duration: const Duration(milliseconds: 500),
      opacity: isSearching ? 1 : 0.5,
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
                interests = userInterests.sublist(index * 8,
                    (index + 1) * 8 > allInterests.length ? allInterests.length : (index + 1) * 8);
              }
              return buildCategoryPage(index, context, interests);
            },
          ),
        ),
      ),
    );
  }

  Widget buildPageIndicator() {
    final isSearching = ref.watch(homeTabControllerProvider.notifier).isSearching;
    final index = ref.watch(homeTabControllerProvider.notifier).index;
    final userInterests = allInterests
        .where(
          (element) => ref.read(userProvider).interests.contains(element.activity),
        )
        .toList();
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: isSearching ? 1 : 0,
      child: Row(
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
      ),
    );
  }

  Widget buildCategoryPage(int pageIndex, BuildContext context, List<InterestModel> interests) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: GridView.count(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        crossAxisSpacing: 20,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
          interests.length,
          (index) {
            final interest = interests[index];
            return GestureDetector(
              onTap: () => onTapGridCategory(interest.activity),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
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
