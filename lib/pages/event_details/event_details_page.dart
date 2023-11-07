import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/main.dart';
import 'package:zipbuzz/models/event_model.dart';
import 'package:zipbuzz/widgets/common/attendee_numbers.dart';

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
            padding: const EdgeInsets.only(left: 8),
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
            padding: const EdgeInsets.only(right: 8.0),
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
                height: 1200,
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
                        EventChip(eventColor: eventColor, widget: widget),
                        const SizedBox(width: 10),
                        AttendeeNumbers(
                          attendees: widget.event.attendees,
                          total: widget.event.maxAttendees,
                          backgroundColor: AppColors.greyColor.withOpacity(0.2),
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
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class EventChip extends StatelessWidget {
  const EventChip({
    super.key,
    required this.eventColor,
    required this.widget,
  });

  final Color eventColor;
  final EventDetailsPage widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: eventColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            widget.event.iconPath,
            height: 16,
          ),
          const SizedBox(width: 5),
          Text(
            widget.event.category,
            style: AppStyles.h5.copyWith(
              color: eventColor,
            ),
          ),
        ],
      ),
    );
  }
}
