import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool isSearching;
  final TextEditingController searchController;
  final Function(String) onSearch;
  final VoidCallback toggleSearching;
  final double topPadding;

  const CustomAppBar({
    required this.isSearching,
    required this.searchController,
    required this.onSearch,
    super.key,
    required this.toggleSearching,
    required this.topPadding,
  });
  @override
  Size get preferredSize => Size.fromHeight(
      AppBar().preferredSize.height + (isSearching ? 65 : 5) + topPadding);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: widget.preferredSize.height,
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 5),
            child: AppBar(
              backgroundColor: AppColors.primaryColor,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
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
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: !widget.isSearching
                      ? GestureDetector(
                          onTap: () {
                            widget.toggleSearching();
                            widget.onSearch(widget.searchController.text);
                          },
                          child: SvgPicture.asset(Assets.icons.search),
                        )
                      : const SizedBox(),
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
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                margin: const EdgeInsets.all(10),
                child: TextField(
                  controller: widget.searchController,
                  cursorHeight: 24,
                  style: AppStyles.h4.copyWith(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search for an event',
                    hintStyle: AppStyles.h4.copyWith(
                        color: Colors.white.withOpacity(0.7), height: 1),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset(
                        Assets.icons.searchBarIcon,
                        colorFilter: ColorFilter.mode(
                          Colors.white.withOpacity(0.7),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
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