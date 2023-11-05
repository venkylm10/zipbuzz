import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/widgets/home/appbar.dart';
import 'package:zipbuzz/widgets/home/custom_calendar.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final pageScrollController = ScrollController();
  final bodyScrollController = ScrollController();
  final queryController = TextEditingController();
  double topPadding = 0;
  bool _isSearching = true;
  int index = 0;
  double previousOffset = 0;

  @override
  void initState() {
    pageScrollController.addListener(() {
      updateIndex(pageScrollController.offset);
    });
    bodyScrollController.addListener(() {
      print(bodyScrollController.offset);
      if (bodyScrollController.offset > 150 && _isSearching) {
        setState(() {
          _isSearching = false;
        });
      } else if (bodyScrollController.offset < 150 && !_isSearching) {
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

  @override
  Widget build(BuildContext context) {
    topPadding = MediaQuery.of(context).padding.top;
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
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _isSearching ? 0 : 1,
      child: Container(
        width: double.infinity,
        color: Colors.white,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              categories.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                  left: index == 0 ? 18 : 8,
                  right: index == categories.length - 1 ? 18 : 8,
                ),
                child: SvgPicture.asset(
                  categories[index]['iconPath']!,
                  height: 30,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCategories(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _isSearching ? 1 : 0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: _isSearching
            ? const PageScrollPhysics()
            : const BouncingScrollPhysics(),
        controller: pageScrollController,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _isSearching = false;
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              (categories.length / 8).ceil(),
              (index) => buildCategoryPage(index, context),
            ),
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
              Container(
                constraints: const BoxConstraints(minHeight: 50),
                child: SvgPicture.asset(
                  subCategories[index]['iconPath']!,
                  height: 40,
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
