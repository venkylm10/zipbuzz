import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/pages/home/notification_page.dart';
import 'package:zipbuzz/services/location_services.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

class CustomAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final bool isSearching;
  final void Function() updateFavoriteEvents;
  final VoidCallback toggleSearching;
  final double topPadding;

  const CustomAppBar({
    super.key,
    required this.isSearching,
    required this.updateFavoriteEvents,
    required this.toggleSearching,
    required this.topPadding,
  });
  @override
  Size get preferredSize =>
      Size.fromHeight(AppBar().preferredSize.height + (isSearching ? 65 : 5) + topPadding);

  @override
  ConsumerState<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends ConsumerState<CustomAppBar> with SingleTickerProviderStateMixin {
  final city = "";
  final country = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              forceMaterialTransparency: true,
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
              title: Consumer(builder: (context, ref, child) {
                final userLocation = ref.watch(userLocationProvider);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${userLocation.city}, ${userLocation.country}",
                      style: AppStyles.h5.copyWith(color: Colors.white),
                    ),
                    Text(
                      userLocation.zipcode,
                      style: AppStyles.h5.copyWith(
                        color: Colors.white.withOpacity(0.5),
                      ),
                    )
                  ],
                );
              }),
              actions: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: !widget.isSearching
                      ? GestureDetector(
                          onTap: () async {
                            widget.toggleSearching();
                          },
                          child: SvgPicture.asset(Assets.icons.search),
                        )
                      : const SizedBox(),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    navigatorKey.currentState!.pushNamed(NotificationPage.id);
                  },
                  child: SvgPicture.asset(Assets.icons.notification),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () async {
                    widget.toggleSearching();
                    if (GetStorage().read(BoxConstants.guestUser) != null) {
                      showSnackBar(message: "You need to be signed in", duration: 2);
                      await Future.delayed(const Duration(seconds: 2));
                      ref.read(newEventProvider.notifier).showSignInForm();
                      return;
                    }
                    widget.updateFavoriteEvents();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Consumer(builder: (context, ref, child) {
                      final showingFavorites = ref.watch(eventsControllerProvider).showingFavorites;
                      return SvgPicture.asset(
                        Assets.icons.heart_fill,
                        colorFilter: ColorFilter.mode(
                          showingFavorites ? Colors.red.shade500 : Colors.white,
                          BlendMode.srcIn,
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: widget.isSearching ? AppBarSearchField(widget: widget) : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}

class AppBarSearchField extends ConsumerWidget {
  const AppBarSearchField({
    super.key,
    required this.widget,
  });

  final CustomAppBar widget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 50,
      margin: const EdgeInsets.all(10),
      child: TextField(
        controller: ref.read(homeTabControllerProvider.notifier).queryController,
        cursorHeight: 24,
        style: AppStyles.h4.copyWith(color: Colors.white),
        onChanged: (value) {
          ref.read(homeTabControllerProvider.notifier).refresh();
        },
        decoration: InputDecoration(
          hintText: 'Search for an event',
          hintStyle: AppStyles.h4.copyWith(color: Colors.white.withOpacity(0.7), height: 1),
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
          suffixIcon: GestureDetector(
            onTap: () {
              ref.read(homeTabControllerProvider.notifier).queryController.clear();
              ref.read(homeTabControllerProvider.notifier).refresh();
            },
            child: Icon(
              Icons.cancel_outlined,
              color: Colors.white.withOpacity(0.7),
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
