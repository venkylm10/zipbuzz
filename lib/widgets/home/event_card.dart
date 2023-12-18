import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/pages/event_details/event_details_page.dart';
import 'package:zipbuzz/widgets/common/attendee_numbers.dart';

class EventCard extends ConsumerStatefulWidget {
  final EventModel event;
  final bool? focusedEvent;
  const EventCard({super.key, required this.event, this.focusedEvent = false});

  @override
  ConsumerState<EventCard> createState() => _EventCardState();
}

class _EventCardState extends ConsumerState<EventCard> {
  Color eventColor = Colors.white;

  String getMonth(DateTime date) {
    final formatter = DateFormat.MMM();
    return formatter.format(date);
  }

  String getWeekDay(DateTime date) {
    return DateFormat.EEEE().format(date).substring(0, 3);
  }

  void navigateToEventDetails() {
    navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (context) => EventDetailsPage(event: widget.event),
      ),
    );
  }

  void getEventColor() {
    eventColor = getInterestColor(widget.event.iconPath);
    setState(() {});
  }

  @override
  void initState() {
    getEventColor();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(widget.event.date);
    return GestureDetector(
      onTap: () => navigateToEventDetails(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.focusedEvent!)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildDate(date),
                  const SizedBox(height: 10),
                  Container(
                    height: 50,
                    width: 50,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: eventColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Image.asset(widget.event.iconPath),
                  )
                ],
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(-2, 4),
                      blurRadius: 10,
                      spreadRadius: 4,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            child: Image.network(
                              widget.event.bannerPath,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.favorite_rounded,
                                color: widget.event.favourite
                                    ? Colors.pink[400]
                                    : Colors.grey[300],
                              ),
                            ),
                          ),
                          const Positioned(
                            bottom: 8,
                            right: 8,
                            child: AttendeeNumbers(attendees: 8, total: 10),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (widget.focusedEvent!) buildDateBox(),
                              if (widget.focusedEvent!)
                                const SizedBox(width: 5),
                              buildHostChip(),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.event.title,
                            softWrap: true,
                            style: AppStyles.h4.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          if (widget.event.about.isNotEmpty)
                            Text(
                              widget.event.about,
                              softWrap: true,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppStyles.h5.copyWith(
                                color: AppColors.lightGreyColor,
                              ),
                            ),
                          if (widget.event.about.isNotEmpty)
                            const SizedBox(height: 10),
                          Row(
                            children: [
                              SvgPicture.asset(
                                Assets.icons.geo_mini,
                                height: 16,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                widget.event.location,
                                style: AppStyles.h5.copyWith(
                                  color: AppColors.lightGreyColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              SvgPicture.asset(
                                Assets.icons.clock,
                                height: 16,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "${widget.event.startTime} - ${widget.event.endTime ?? ''}",
                                style: AppStyles.h5.copyWith(
                                  color: AppColors.lightGreyColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildHostChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2)
          .copyWith(left: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              widget.event.hostPic,
              height: 22,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            widget.event.hostName,
            style: AppStyles.h5.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Container buildDateBox() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: eventColor.withOpacity(0.1),
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
            style: AppStyles.h5.copyWith(color: eventColor),
          ),
        ],
      ),
    );
  }

  Container buildDate(DateTime date) {
    return Container(
      padding: const EdgeInsets.all(2),
      constraints: const BoxConstraints(minWidth: 50),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: Text(
              getMonth(date),
              style: AppStyles.h4.copyWith(
                color: AppColors.greyColor,
              ),
            ),
          ),
          Text(
            date.day.toString(),
            style: AppStyles.h2,
          ),
          Text(
            getWeekDay(date),
            style: AppStyles.h4.copyWith(
              color: AppColors.greyColor,
            ),
          )
        ],
      ),
    );
  }
}
