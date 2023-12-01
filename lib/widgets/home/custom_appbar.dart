import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/controllers/user_controller.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

class CustomAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
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
  ConsumerState<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends ConsumerState<CustomAppBar>
    with SingleTickerProviderStateMixin {
  final city = "";
  final country = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider)!;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
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
                    "${user.city}, ${user.country}",
                    style: AppStyles.h5.copyWith(color: Colors.white),
                  ),
                  Text(
                    ref.read(userProvider)!.zipcode,
                    style: AppStyles.h5.copyWith(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  )
                ],
              ),
              actions: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
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
                  onTap: showSnackBar,
                  child: SvgPicture.asset(Assets.icons.notification),
                ),
                const SizedBox(width: 12)
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: widget.isSearching
                  ? AppBarSearchField(widget: widget)
                  : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}

class AppBarSearchField extends StatelessWidget {
  const AppBarSearchField({
    super.key,
    required this.widget,
  });

  final CustomAppBar widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.all(10),
      child: TextField(
        controller: widget.searchController,
        cursorHeight: 24,
        style: AppStyles.h4.copyWith(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search for an event',
          hintStyle: AppStyles.h4
              .copyWith(color: Colors.white.withOpacity(0.7), height: 1),
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
    );
  }
}
