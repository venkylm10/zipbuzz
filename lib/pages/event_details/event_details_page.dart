import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/controllers/events/edit_event_controller.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/widgets/event_details_page/event_host_guest_list.dart';
import 'package:zipbuzz/widgets/event_details_page/friends_registered_box.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/defaults.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/models/user/user_model.dart';
import 'package:zipbuzz/widgets/common/attendee_numbers.dart';
import 'package:zipbuzz/widgets/common/event_chip.dart';
import 'package:zipbuzz/widgets/event_details_page/event_buttons.dart';
import 'package:zipbuzz/widgets/event_details_page/event_details.dart';
import 'package:zipbuzz/widgets/event_details_page/event_hosts.dart';
import 'package:zipbuzz/widgets/event_details_page/event_qrcode.dart';
import 'package:zipbuzz/widgets/event_details_page/guest_list.dart';

class EventDetailsPage extends ConsumerStatefulWidget {
  static const id = 'event/details';
  final EventModel event;
  final int? randInt;
  final bool? isPreview;
  final bool? rePublish;
  final Color dominantColor;
  const EventDetailsPage({
    super.key,
    required this.event,
    this.randInt = 0,
    this.isPreview = false,
    this.rePublish = false,
    required this.dominantColor,
  });

  @override
  ConsumerState<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends ConsumerState<EventDetailsPage> {
  final bodyScrollController = ScrollController();
  Color eventColor = Colors.white;
  double horizontalMargin = 16;
  List<String> defaultBanners = [];
  int maxImages = 0;
  List<UserModel> coHosts = [];

  void getEventColor() {
    eventColor = getInterestColor(widget.event.iconPath);
    setState(() {});
  }

  bool animateMargin() {
    if (horizontalMargin >= 0) {
      horizontalMargin = 12 - bodyScrollController.offset;
      if (horizontalMargin < 0) {
        horizontalMargin = 0;
      }
      setState(() {});
    }
    return true;
  }

  void initialise() async {
    maxImages = ref.read(newEventProvider.notifier).maxImages;
    defaultBanners = ref.read(defaultsProvider).bannerPaths;
    await ref.read(dbServicesProvider).getEventRequestMembers(widget.event.id);
    getEventColor();
  }

  @override
  void initState() {
    initialise();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.dominantColor,
      appBar: buildAppBar(),
      extendBodyBehindAppBar: true,
      body: NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification) => animateMargin(),
        child: SingleChildScrollView(
          controller: bodyScrollController,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              buildBanner(),
              Transform.translate(
                offset: const Offset(0, -40),
                child: AnimatedPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
                  duration: const Duration(milliseconds: 100),
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.event.title,
                              style: AppStyles.h2.copyWith(fontWeight: FontWeight.w600),
                              softWrap: true,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    EventChip(
                                      eventColor: eventColor,
                                      interest: widget.event.category,
                                      iconPath: widget.event.iconPath,
                                    ),
                                    const SizedBox(width: 10),
                                    Consumer(builder: (context, ref, child) {
                                      var attendees = 1;
                                      if (widget.isPreview!) {
                                        attendees = ref.watch(newEventProvider).attendees;
                                      } else if (widget.rePublish!) {
                                        attendees =
                                            ref.watch(editEventControllerProvider).attendees;
                                      } else {
                                        attendees = widget.event.attendees;
                                      }

                                      var total = 1;

                                      if (widget.isPreview!) {
                                        total = ref.watch(newEventProvider).capacity;
                                      } else if (widget.rePublish!) {
                                        total = ref.watch(editEventControllerProvider).capacity;
                                      } else {
                                        total = widget.event.capacity;
                                      }
                                      return AttendeeNumbers(
                                        attendees: attendees,
                                        total: total,
                                        backgroundColor: AppColors.greyColor.withOpacity(0.1),
                                      );
                                    }),
                                  ],
                                ),
                                const EventQRCode(),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Divider(
                              color: AppColors.greyColor.withOpacity(0.2),
                              thickness: 0,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Event details",
                              style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
                            ),
                            const SizedBox(height: 16),
                            EventDetails(event: widget.event),
                            const SizedBox(height: 16),
                            Divider(
                              color: AppColors.greyColor.withOpacity(0.2),
                              thickness: 0,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "About",
                              style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
                            ),
                            const SizedBox(height: 16),
                            Text(widget.event.about, style: AppStyles.h4),
                            const SizedBox(height: 16),
                            Divider(
                              color: AppColors.greyColor.withOpacity(0.2),
                              thickness: 0,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Sneak peaks",
                              style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
                            ),
                            const SizedBox(height: 16),
                            buildPhotos(widget.isPreview!, ref),
                            const SizedBox(height: 16),
                            Divider(
                              color: AppColors.greyColor.withOpacity(0.2),
                              thickness: 0,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                Text(
                                  "Hosts",
                                  style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
                                ),
                                const SizedBox(height: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    EventHosts(
                                      event: widget.event,
                                      isPreview: widget.isPreview!,
                                    ),
                                    const SizedBox(height: 16),
                                    Divider(
                                      color: AppColors.greyColor.withOpacity(0.2),
                                      thickness: 0,
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Guest list (${widget.event.eventMembers.length})",
                              style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
                            ),
                            const SizedBox(height: 16),
                            buildGuestList(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      const FriendsRegisteredBox()
                    ],
                  ),
                ),
              ),
              SizedBox(height: widget.isPreview! ? 100 : 40),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: EventButtons(
        event: widget.event,
        isPreview: widget.isPreview,
        rePublish: widget.rePublish,
      ),
    );
  }

  Widget buildGuestList() {
    final userId = GetStorage().read(BoxConstants.id);
    if (widget.isPreview!) {
      return EventGuestList(
        guests: widget.event.eventMembers,
      );
    }
    if (widget.event.hostId != userId) {
      return EventGuestList(
        guests: widget.event.eventMembers,
      );
    }
    return EventHostGuestList(
      guests: widget.event.eventMembers,
      eventId: widget.event.id,
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      shadowColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      leadingWidth: 0,
      leading: const SizedBox(),
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () => navigatorKey.currentState!.pop(),
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Center(
                    child: Icon(
                      Icons.arrow_back,
                      color: widget.dominantColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const Expanded(child: SizedBox()),
      ],
    );
  }

  Widget buildBanner() {
    final previewBanner = ref.read(newEventProvider.notifier).bannerImage;

    if (widget.isPreview!) {
      if (previewBanner != null) {
        return SizedBox(
          height: 300,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.file(
                  previewBanner,
                  fit: BoxFit.cover,
                ),
              ),
              buildBannerGradient(),
            ],
          ),
        );
      }

      return SizedBox(
        height: 300,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                defaultBanners[widget.randInt!],
                fit: BoxFit.cover,
              ),
            ),
            buildBannerGradient(),
          ],
        ),
      );
    } else {
      final newBanner = ref.read(editEventControllerProvider.notifier).bannerImage;
      if (newBanner == null) {
        return SizedBox(
          height: 300,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  widget.event.bannerPath,
                  fit: BoxFit.cover,
                ),
              ),
              buildBannerGradient(),
            ],
          ),
        );
      } else {
        return SizedBox(
          height: 300,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.file(
                  newBanner,
                  fit: BoxFit.cover,
                ),
              ),
              buildBannerGradient(),
            ],
          ),
        );
      }
    }
  }

  Positioned buildBannerGradient() {
    return Positioned(
      bottom: -10,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 300,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, widget.dominantColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.2, 1],
          ),
        ),
      ),
    );
  }

  Widget buildPhotos(bool isPreview, WidgetRef ref) {
    final imageFiles = ref.watch(newEventProvider.notifier).selectedImages;
    return isPreview
        ? Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: StaggeredGrid.count(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: List.generate(
                imageFiles.length,
                (index) => StaggeredGridTile.count(
                  crossAxisCellCount: index % (maxImages - 1) == 0
                      ? 2
                      : 1, // change this maxImages in newEventProvider
                  mainAxisCellCount: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      imageFiles[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          )
        : Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: StaggeredGrid.count(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: List.generate(
                7,
                (index) => StaggeredGridTile.count(
                  crossAxisCellCount: index % (maxImages - 1) == 0 ? 2 : 1,
                  mainAxisCellCount: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/about/Image-$index.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
