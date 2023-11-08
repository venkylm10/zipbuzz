import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/main.dart';
import 'package:zipbuzz/models/event_model.dart';
import 'package:zipbuzz/models/host_model.dart';
import 'package:zipbuzz/widgets/common/attendee_numbers.dart';
import 'package:zipbuzz/widgets/common/event_chip.dart';
import 'package:zipbuzz/widgets/event_details_page/event_details.dart';
import 'package:zipbuzz/widgets/event_details_page/event_hosts.dart';

class EventDetailsPage extends StatefulWidget {
  final EventModel event;
  const EventDetailsPage({super.key, required this.event});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  Color dominantColor = Colors.white;
  Color eventColor = Colors.white;

  Future<void> getDominantColor() async {
    final image = AssetImage(widget.event.bannerPath);
    final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
      image,
    );
    dominantColor = generator.dominantColor!.color;
    setState(() {});
  }

  Future<void> getEventColor() async {
    final image = AssetImage(widget.event.iconPath);
    final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
      image,
    );
    eventColor = generator.dominantColor!.color;
    setState(() {});
  }

  @override
  void initState() {
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
                child: Center(
                  child: Icon(
                    Icons.arrow_back,
                    color: dominantColor,
                  ),
                ),
              ),
            ),
          ),
          const Expanded(child: SizedBox()),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => navigatorKey.currentState!.pop(),
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.favorite_rounded,
                    color: AppColors.lightGreyColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              widget.event.bannerPath,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
            Transform.translate(
              offset: const Offset(0, -40),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
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
                      style: AppStyles.titleStyle,
                      softWrap: true,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        EventChip(
                          eventColor: eventColor,
                          category: widget.event.category,
                          iconPath: widget.event.iconPath,
                        ),
                        const SizedBox(width: 10),
                        AttendeeNumbers(
                          attendees: widget.event.attendees,
                          total: widget.event.maxAttendees,
                          backgroundColor: AppColors.greyColor.withOpacity(0.1),
                        ),
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
                    const SizedBox(height: 16),
                    Text(
                      "Hosts",
                      style: AppStyles.h5
                          .copyWith(color: AppColors.lightGreyColor),
                    ),
                    const SizedBox(height: 16),
                    EventHosts(hosts: widget.event.hosts),
                    const SizedBox(height: 16),
                    Divider(
                      color: AppColors.greyColor.withOpacity(0.2),
                      thickness: 0,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "About",
                      style: AppStyles.h5
                          .copyWith(color: AppColors.lightGreyColor),
                    ),
                    const SizedBox(height: 16),
                    // about text
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
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.lightGreyColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text("Images"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: EventButtons(event: widget.event),
    );
  }
}

class EventButtons extends StatelessWidget {
  const EventButtons({
    required this.event,
    super.key,
  });

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Join ",
                      style: AppStyles.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "(${event.attendees}/${event.maxAttendees})",
                      style: AppStyles.h4.copyWith(color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  "Share",
                  style: AppStyles.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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
