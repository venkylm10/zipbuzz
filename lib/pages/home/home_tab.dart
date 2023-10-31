import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/models/event_model.dart';
import 'package:zipbuzz/widgets/home/appbar.dart';
import 'package:zipbuzz/widgets/home/custom_calendar.dart';
import 'package:zipbuzz/widgets/home/event_card.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final scrollController = ScrollController();
  bool _isSearching = false;
  int index = 0;

  @override
  void initState() {
    scrollController.addListener(() {
      updateIndex(scrollController.offset);
    });
    super.initState();
  }

  void updateIndex(double offset) {
    index = ((offset + 100) / MediaQuery.of(context).size.width).floor();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Your App Title',
        isSearching: _isSearching,
        searchController: TextEditingController(),
        onSearch: (query) {
          setState(() {
            _isSearching = !_isSearching;
          });
        },
        toggleSearching: () {
          setState(() {
            _isSearching = !_isSearching;
          });
        },
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildCategories(context),
            if (_isSearching) buildPageIndicator(),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
              child: Text(
                "My Calendar Events",
                style: AppStyles.titleStyle,
              ),
            ),
            const CustomCalendar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 10),
              child: Text(
                "Upcoming Events",
                style: AppStyles.titleStyle,
              ),
            ),
            Column(
              children: dummyEvents.map((e) => EventCard(event: e)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  SingleChildScrollView buildCategories(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: _isSearching
          ? const PageScrollPhysics()
          : const BouncingScrollPhysics(),
      controller: scrollController,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isSearching = false;
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _isSearching
              ? List.generate(
                  (categories.length / 8).ceil(),
                  (index) => buildCategoryPage(index, context),
                )
              : List.generate(
                  categories.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      top: 20,
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
    );
  }

  Row buildPageIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        (categories.length / 8).ceil(),
        (pageIndex) => Container(
          height: 6,
          width: 6,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color:
                index == pageIndex ? AppColors.primaryColor : Colors.grey[350],
            borderRadius: BorderRadius.circular(3),
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
