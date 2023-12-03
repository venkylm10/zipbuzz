import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/defaults.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/controllers/events_controller.dart';
import 'package:zipbuzz/main.dart';
import 'package:zipbuzz/models/event_model.dart';
import 'package:zipbuzz/widgets/common/attendee_numbers.dart';
import 'package:zipbuzz/widgets/common/event_chip.dart';
import 'package:zipbuzz/widgets/event_details_page/event_buttons.dart';
import 'package:zipbuzz/widgets/event_details_page/event_details.dart';
import 'package:zipbuzz/widgets/event_details_page/event_hosts.dart';
import 'package:zipbuzz/widgets/event_details_page/event_qrcode.dart';

class EventDetailsPage extends ConsumerStatefulWidget {
  static const id = 'event/details';
  final EventModel event;
  final bool? isPreview;
  const EventDetailsPage(
      {super.key, required this.event, this.isPreview = false});

  @override
  ConsumerState<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends ConsumerState<EventDetailsPage> {
  Color dominantColor = Colors.white;
  Color eventColor = Colors.white;
  final bodyScrollController = ScrollController();
  String dummyText = '';
  double horizontalMargin = 16;
  List<String> defaultBanners = [];
  int rand = 0;
  int maxImages = 0;

  Future<void> getDominantColor() async {
    final previewBanner = ref.read(newEventProvider.notifier).bannerImage;
    if (widget.isPreview!) {
      if (previewBanner != null) {
        final image = AssetImage(widget.event.bannerPath);
        final PaletteGenerator generator =
            await PaletteGenerator.fromImageProvider(
          image,
        );
        dominantColor = generator.dominantColor!.color;
        setState(() {});
      }
      final image = AssetImage(defaultBanners[rand]);
      final PaletteGenerator generator =
          await PaletteGenerator.fromImageProvider(
        image,
      );
      dominantColor = generator.dominantColor!.color;
      setState(() {});
    } else {
      final PaletteGenerator generator =
          await PaletteGenerator.fromImageProvider(
        NetworkImage(widget.event.bannerPath),
      );
      dominantColor = generator.dominantColor!.color;
      setState(() {});
    }
  }

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

  @override
  void initState() {
    maxImages = ref.read(newEventProvider.notifier).maxImages;
    Random random = Random();
    defaultBanners = ref.read(defaultsProvider).defaultBannerPaths;
    rand = random.nextInt(defaultBanners.length);
    getDominantColor();
    getEventColor();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dominantColor,
      appBar: AppBar(
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
                        color: dominantColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
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
                  child: Container(
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
                          style: AppStyles.h2
                              .copyWith(fontWeight: FontWeight.w600),
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
                                AttendeeNumbers(
                                  attendees: widget.event.attendees,
                                  total: widget.event.capacity,
                                  backgroundColor:
                                      AppColors.greyColor.withOpacity(0.1),
                                ),
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
                          style: AppStyles.h5
                              .copyWith(color: AppColors.lightGreyColor),
                        ),
                        const SizedBox(height: 16),
                        EventDetails(event: widget.event),
                        const SizedBox(height: 16),
                        Divider(
                          color: AppColors.greyColor.withOpacity(0.2),
                          thickness: 0,
                        ),
                        if (widget.event.host != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Text(
                                "Hosts",
                                style: AppStyles.h5
                                    .copyWith(color: AppColors.lightGreyColor),
                              ),
                              const SizedBox(height: 16),
                              EventHosts(
                                host: widget.event.host,
                                coHosts: widget.event.coHosts,
                              ),
                              const SizedBox(height: 16),
                              Divider(
                                color: AppColors.greyColor.withOpacity(0.2),
                                thickness: 0,
                              ),
                            ],
                          ),
                        const SizedBox(height: 16),
                        Text(
                          "About",
                          style: AppStyles.h5
                              .copyWith(color: AppColors.lightGreyColor),
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
                          style: AppStyles.h5
                              .copyWith(color: AppColors.lightGreyColor),
                        ),
                        const SizedBox(height: 16),
                        buildPhotos(widget.isPreview!, ref),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: widget.isPreview! ? 100 : 40),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          EventButtons(event: widget.event, isPreview: widget.isPreview),
    );
  }

  Widget buildBanner() {
    final previewBanner = ref.read(newEventProvider.notifier).bannerImage;
    if (widget.isPreview!) {
      if (previewBanner != null) {
        return Container(
          constraints: const BoxConstraints(maxHeight: 300),
          child: Image.file(
            previewBanner,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        );
      }

      return Image.asset(
        defaultBanners[rand],
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } else {
      return Container(
        constraints: const BoxConstraints(maxHeight: 300),
        child: Image.network(
          widget.event.bannerPath,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    }
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
                  crossAxisCellCount: index % (maxImages - 1) == 0 ? 2 : 1, // change this maxImages in newEventProvider
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
