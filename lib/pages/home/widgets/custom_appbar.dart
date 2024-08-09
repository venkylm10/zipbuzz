import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/pages/notification/notification_page.dart';
import 'package:zipbuzz/services/location_services.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class CustomAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final bool isSearching;
  final VoidCallback toggleSearching;
  final double topPadding;

  const CustomAppBar({
    super.key,
    required this.isSearching,
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
                    Builder(builder: (context) {
                      var neighborhood = '';
                      if (userLocation.neighborhood.isNotEmpty &&
                          userLocation.neighborhood != 'None') {
                        neighborhood = "${userLocation.neighborhood}, ";
                      }
                      var city = '';
                      if (userLocation.city.isNotEmpty && userLocation.city != 'None') {
                        city = "${userLocation.city}, ";
                      }
                      var country = '';
                      if (userLocation.country.isNotEmpty && userLocation.country != 'None') {
                        country = userLocation.country;
                      }
                      return Text(
                        "$neighborhood$city$country",
                        style: AppStyles.h5.copyWith(color: Colors.white),
                      );
                    }),
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
                InkWell(
                  onTap: () async {
                    widget.toggleSearching();
                  },
                  child: SvgPicture.asset(Assets.icons.search, height: 40),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () async {
                    final events = ref.read(eventsControllerProvider).currentMonthEvents;
                    await navigatorKey.currentState!.pushNamed(NotificationPage.id);
                    ref.read(eventsControllerProvider.notifier).fixHomeEvents(events);
                    ref.read(eventsControllerProvider.notifier).fetchEvents();
                  },
                  child: SizedBox(
                    height: 44,
                    width: 40,
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 0,
                          child: SvgPicture.asset(
                            Assets.icons.notification,
                            height: 40,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: -6,
                          child: Consumer(
                            builder: (context, ref, child) {
                              final notificationCount = ref.watch(userProvider).notificationCount;
                              return notificationCount == 0
                                  ? const SizedBox()
                                  : Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.primaryColor, width: 4),
                                      ),
                                      child: Text(
                                        ref.read(userProvider).notificationCount.toString(),
                                        style: AppStyles.h6.copyWith(color: AppColors.primaryColor),
                                      ),
                                    );
                            },
                          ),
                        ),
                      ],
                    ),
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
          suffixIcon: InkWell(
            onTap: () {
              ref.read(homeTabControllerProvider.notifier).queryController.clear();
              widget.toggleSearching();
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
