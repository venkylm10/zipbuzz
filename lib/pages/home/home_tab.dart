import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/controllers/events_controller.dart';
import 'package:zipbuzz/widgets/home/custom_appbar.dart';
import 'package:zipbuzz/widgets/home/custom_calendar.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  final pageScrollController = ScrollController();
  final rowScrollController = ScrollController();
  final bodyScrollController = ScrollController();
  final queryController = TextEditingController();
  late GlobalKey categoryPageKey;
  late GlobalKey rowCategoryKey;
  double topPadding = 0;
  bool _isSearching = true;
  int index = 0;
  double previousOffset = 0;
  String selectedCategory = '';

  @override
  void initState() {
    categoryPageKey = GlobalKey();
    rowCategoryKey = GlobalKey();
    pageScrollController.addListener(() {
      updateIndex(pageScrollController.offset);
    });
    bodyScrollController.addListener(() {
      if (bodyScrollController.offset > 120 && _isSearching) {
        setState(() {
          _isSearching = false;
        });
      } else if (bodyScrollController.offset < 120 && !_isSearching) {
        setState(() {
          _isSearching = true;
        });
      }
      previousOffset = bodyScrollController.offset;
    });
    super.initState();
  }

  void updateIndex(double offset) {
    index = ((offset + 100) / MediaQuery.of(context).size.width).floor();
    setState(() {});
  }

  void scrollDownInterests() {
    final RenderBox renderBox =
        categoryPageKey.currentContext!.findRenderObject() as RenderBox;
    final containerHeight = renderBox.size.height;
    bodyScrollController.animateTo(
      containerHeight - 50,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // void scrollToSelectedCategory() {
  //   final RenderBox renderBox =
  //       rowCategoryKey.currentContext!.findRenderObject() as RenderBox;
  //   final position = renderBox.localToGlobal(Offset.zero);
  //   rowScrollController.animateTo(
  //     position.dx,
  //     duration: const Duration(milliseconds: 300),
  //     curve: Curves.easeInOut,
  //   );
  // }

  void onTapRowCategory(String interest) {
    if (selectedCategory != interest) {
      ref.read(eventsControllerProvider).selectCategory(category: interest);
      setState(() {});
    } else {
      ref.read(eventsControllerProvider).selectCategory(category: '');
      setState(() {});
    }
  }

  void onTapGridCategory(String interest) {
    scrollDownInterests();
    ref.read(eventsControllerProvider).selectCategory(category: interest);
  }

  @override
  Widget build(BuildContext context) {
    topPadding = MediaQuery.of(context).padding.top;
    selectedCategory = ref.watch(eventsControllerProvider).selectedCategory;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        isSearching: _isSearching,
        searchController: queryController,
        onSearch: (query) {
          FocusScope.of(context).nextFocus();
        },
        toggleSearching: () {
          setState(() {
            _isSearching = !_isSearching;
          });
        },
        topPadding: topPadding,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            controller: bodyScrollController,
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
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: !_isSearching
          ? Container(
              width: double.infinity,
              color: Colors.white,
              child: SingleChildScrollView(
                controller: rowScrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: allInterests.entries.map((e) {
                      final name = e.key;
                      final iconPath = e.value;
                      return GestureDetector(
                        onTap: () => onTapRowCategory(name),
                        child: Container(
                          key: selectedCategory == name ? rowCategoryKey : null,
                          margin: EdgeInsets.only(
                            top: 5,
                            left: index == 0 ? 12 : 2,
                            right: index == allInterests.length - 1 ? 12 : 2,
                            bottom: 5,
                          ),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: ref
                                        .watch(eventsControllerProvider)
                                        .selectedCategory ==
                                    name
                                ? Colors.green.withOpacity(0.15)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Opacity(
                            opacity: ref
                                        .watch(eventsControllerProvider)
                                        .selectedCategory ==
                                    name
                                ? 1
                                : 0.5,
                            child: Image.asset(
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
    return AnimatedOpacity(
      key: categoryPageKey,
      duration: const Duration(milliseconds: 500),
      opacity: _isSearching ? 1 : 0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: _isSearching
            ? const PageScrollPhysics()
            : const BouncingScrollPhysics(),
        controller: pageScrollController,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            (allInterests.length / 8).ceil(),
            (index) => buildCategoryPage(index, context),
          ),
        ),
      ),
    );
  }

  Widget buildPageIndicator() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _isSearching ? 1 : 0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          (allInterests.length / 8).ceil(),
          (pageIndex) => Container(
            height: 6,
            width: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: index == pageIndex
                  ? AppColors.primaryColor
                  : Colors.grey[350],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCategoryPage(int pageIndex, BuildContext context) {
    final subInterests = allInterests.entries
        .map((e) => e.key)
        .toList()
        .sublist(
            pageIndex * 8,
            (pageIndex + 1) * 8 > allInterests.length
                ? allInterests.length
                : (pageIndex + 1) * 8);
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
          subInterests.length,
          (index) {
            final name = subInterests[index];
            return GestureDetector(
              onTap: () => onTapGridCategory(subInterests[index]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    constraints: const BoxConstraints(minHeight: 50),
                    child: Image.asset(
                      allInterests[name]!,
                      height: 40,
                    ),
                  ),
                  Text(
                    name,
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
