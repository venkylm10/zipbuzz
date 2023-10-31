import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool isSearching;
  final TextEditingController searchController;
  final Function(String) onSearch;
  final VoidCallback toggleSearching;

  const CustomAppBar({
    required this.title,
    required this.isSearching,
    required this.searchController,
    required this.onSearch,
    super.key,
    required this.toggleSearching,
  });
  @override
  Size get preferredSize => Size.fromHeight(
        isSearching
            ? AppBar().preferredSize.height + 65
            : AppBar().preferredSize.height + 5,
      );

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final searchFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.decelerate,
      height: widget.preferredSize.height + MediaQuery.of(context).padding.top,
      decoration: const BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 5),
            child: AppBar(
              backgroundColor: const Color(0xFF4A43EC),
              elevation: 0,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(30))),
              leading: Padding(
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset(
                  Assets.icons.geo,
                ),
              ),
              titleSpacing: -5,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "San Jose, USA",
                    style: AppStyles.h5.copyWith(color: Colors.white),
                  ),
                  Text(
                    "94088",
                    style: AppStyles.h5.copyWith(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  )
                ],
              ),
              actions: [
                if (!widget.isSearching)
                  GestureDetector(
                    onTap: () {
                      if (!widget.isSearching) {
                        widget.onSearch('');
                        FocusScope.of(context).requestFocus(searchFocusNode);
                      }
                    },
                    child: SvgPicture.asset(Assets.icons.search),
                  ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {},
                  child: SvgPicture.asset(Assets.icons.notification),
                ),
                const SizedBox(width: 12)
              ],
            ),
          ),
          if (widget.isSearching)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  controller: widget.searchController,
                  focusNode: searchFocusNode,
                  cursorHeight: 24,
                  style: AppStyles.h4.copyWith(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search for an event',
                    hintStyle: AppStyles.h4.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                    prefixIcon: Icon(CupertinoIcons.search,
                        color: Colors.white.withOpacity(0.7)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
