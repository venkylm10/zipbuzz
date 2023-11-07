import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/pages/home/calendar/events_controller.dart';
import 'package:zipbuzz/widgets/home/custom_appbar.dart';
import 'package:zipbuzz/widgets/home/custom_calendar.dart';

final categoryPageKey = GlobalKey();
final rowCategoryKey = GlobalKey();

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
  double topPadding = 0;
  bool _isSearching = true;
  int index = 0;
  double previousOffset = 0;
  String selectedCategory = '';

  @override
  void initState() {
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

  void scrollDownCategories() {
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

  void onTapRowCategory(Map<String, String> category) {
    if (selectedCategory != category['name']) {
      ref
          .read(eventsControllerProvider)
          .selectCategory(category: category['name'] ?? '');
      setState(() {});
    } else {
      ref.read(eventsControllerProvider).selectCategory(category: '');
      setState(() {});
    }
  }

  void onTapGridCategory(Map<String, String> category) {
    scrollDownCategories();
    ref
        .read(eventsControllerProvider)
        .selectCategory(category: category['name']);
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
                buildCategories(context),
                buildPageIndicator(),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                  child: Text(
                    "My Calendar Events",
                    style: AppStyles.titleStyle,
                  ),
                ),
                const CustomCalendar(),
                const SizedBox(height: 200)
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
                  children: List.generate(
                    categories.length,
                    (index) {
                      final category = categories[index];
                      return GestureDetector(
                        onTap: () => onTapRowCategory(category),
                        child: Container(
                          key: selectedCategory == category['name']
                              ? rowCategoryKey
                              : null,
                          margin: EdgeInsets.only(
                            top: 5,
                            left: index == 0 ? 12 : 2,
                            right: index == categories.length - 1 ? 12 : 2,
                            bottom: 5,
                          ),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: ref
                                        .watch(eventsControllerProvider)
                                        .selectedCategory ==
                                    category['name']
                                ? Colors.green.withOpacity(0.15)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Opacity(
                            opacity: ref
                                        .watch(eventsControllerProvider)
                                        .selectedCategory ==
                                    category['name']
                                ? 1
                                : 0.5,
                            child: Image.asset(
                              categories[index]['iconPath']!,
                              height: 30,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            )
          : const SizedBox(),
    );
  }

  Widget buildCategories(BuildContext context) {
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
            (categories.length / 8).ceil(),
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
          (categories.length / 8).ceil(),
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
    final subCategories = categories.sublist(
        pageIndex * 8,
        (pageIndex + 1) * 8 > categories.length
            ? categories.length
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
          subCategories.length,
          (index) => Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => onTapGridCategory(subCategories[index]),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 50),
                  child: Image.asset(
                    subCategories[index]['iconPath']!,
                    height: 40,
                  ),
                ),
              ),
              Text(
                subCategories[index]['name']!,
                softWrap: true,
                textAlign: TextAlign.center,
                style: AppStyles.h5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
