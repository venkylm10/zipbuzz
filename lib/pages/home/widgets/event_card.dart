import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/models/events/event_request_member.dart';
import 'package:zipbuzz/models/events/requests/event_members_request_model.dart';
import 'package:zipbuzz/pages/home/widgets/add_to_calendar.dart';
import 'package:zipbuzz/pages/home/widgets/event_card_category_details.dart';
import 'package:zipbuzz/pages/home/widgets/event_card_clone_option.dart';
import 'package:zipbuzz/pages/home/widgets/event_card_host_chip.dart';
import 'package:zipbuzz/pages/home/widgets/event_card_rsvp_update_button.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/pages/events/event_details_page.dart';
import 'package:zipbuzz/pages/events/widgets/attendee_numbers.dart';
import 'package:zipbuzz/pages/events/widgets/event_host_guest_list.dart';

// ignore: must_be_immutable
class EventCard extends ConsumerStatefulWidget {
  EventModel event;
  final bool focusedEvent;
  final bool showTag;
  final bool myEvent;
  final bool changeRsvp;

  EventCard({
    super.key,
    required this.event,
    this.focusedEvent = false,
    this.showTag = true,
    this.myEvent = false,
    this.changeRsvp = true,
  });

  @override
  ConsumerState<EventCard> createState() => _EventCardState();
}

class _EventCardState extends ConsumerState<EventCard> {
  late Color eventColor;
  int randInt = 0;
  bool isMounted = true;

  void navigateToEventDetails() async {
    debugPrint(widget.event.id.toString());
    final dominantColor = await getDominantColor();
    ref.read(guestListTagProvider.notifier).update((state) => "Invited");
    await navigatorKey.currentState!.push(
      PageTransition(
        child: EventDetailsPage(
          event: widget.event,
          dominantColor: dominantColor,
          isPreview: false,
          rePublish: false,
          clone: false,
        ),
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 300),
      ),
    );
    if (isMounted) setState(() {});
  }

  Future<Color> getDominantColor() async {
    Color dominantColor = Colors.green;
    final image = NetworkImage(widget.event.bannerPath);
    final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
      image,
    );
    dominantColor = generator.dominantColor!.color;
    return dominantColor;
  }

  @override
  void initState() {
    eventColor = interestColors[widget.event.category]!;
    super.initState();
  }

  @override
  void dispose() {
    isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(widget.event.date);
    final status = _getUserTag(widget.event.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      margin: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () => navigateToEventDetails(),
        child: Column(
          children: [
            _buildStatus(status),
            Transform.translate(
              offset: Offset(0, status.isNotEmpty ? -20 : 0),
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
                          _buildBanner(),
                          EventCardActionItems(event: widget.event),
                          _buildAttendees(),
                          EventCardCategoryDetails(
                            event: widget.event,
                            date: date,
                          ),
                        ],
                      ),
                    ),
                    _buildDetails()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ClipRRect _buildBanner() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(20),
      ),
      child: Image.network(
        widget.event.bannerPath,
        fit: BoxFit.cover,
        width: double.infinity,
      ),
    );
  }

  Widget _buildStatus(String status) {
    if (status.isEmpty) {
      return const SizedBox();
    }
    return Container(
      height: 40,
      padding: const EdgeInsets.only(top: 4),
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(Assets.icons.stars, height: 12),
          const SizedBox(width: 8),
          Text(
            status,
            style: AppStyles.h6.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          SvgPicture.asset(Assets.icons.stars, height: 12),
        ],
      ),
    );
  }

  Padding _buildDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              EventCardHostChip(event: widget.event),
              const Spacer(),
              InkWell(
                onTap: () async {
                  await showModalBottomSheet(
                    context: navigatorKey.currentContext!,
                    isScrollControlled: true,
                    enableDrag: true,
                    isDismissible: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return AddToCalendar(event: widget.event);
                    },
                  );
                },
                child: Image.asset(
                  Assets.icons.addToCalendar,
                  height: 30,
                  width: 30,
                ),
              ),
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
          _buildAbout(),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildLocation(),
                    _buildTiming(),
                  ],
                ),
              ),
              if (widget.changeRsvp)
                EventCardRsvpUpdateButton(
                  event: widget.event,
                  updateStatus: (val, members) {
                    setState(() {
                      widget.event.status = val;
                      widget.event.members = members;
                    });
                  },
                ),
            ],
          )
        ],
      ),
    );
  }

  Row _buildTiming() {
    return Row(
      children: [
        SvgPicture.asset(
          Assets.icons.clock,
          height: 16,
        ),
        const SizedBox(width: 5),
        Text(
          "${widget.event.startTime}${widget.event.endTime != "null" ? " - ${widget.event.endTime}" : ""}",
          style: AppStyles.h5.copyWith(
            color: AppColors.lightGreyColor,
          ),
        ),
      ],
    );
  }

  Widget _buildLocation() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          SvgPicture.asset(
            Assets.icons.geo_mini,
            height: 16,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              widget.event.location,
              style: AppStyles.h5.copyWith(
                color: AppColors.lightGreyColor,
              ),
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbout() {
    if (widget.event.about.isEmpty) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        widget.event.about,
        softWrap: true,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppStyles.h5.copyWith(
          color: AppColors.lightGreyColor,
        ),
      ),
    );
  }

  Future<List<EventRequestMember>> getEventMembers() async {
    final data = ref.read(dioServicesProvider).getEventRequestMembers(widget.event.id);
    final members = await ref
        .read(dioServicesProvider)
        .getEventMembers(EventMembersRequestModel(eventId: widget.event.id));
    widget.event.eventMembers = members;
    return data;
  }

  Widget _buildAttendees() {
    return Positioned(
      bottom: 8,
      right: 8,
      child: FutureBuilder(
        future: getEventMembers(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data!;
            var responded = 0;
            var confirmed = 0;
            final responedMembers = data;
            final confirmedMembers = data.where((element) {
              return element.status == "confirm" || element.status == 'host';
            }).toList();
            for (var e in responedMembers) {
              responded += e.attendees;
            }
            for (var e in confirmedMembers) {
              confirmed += e.attendees;
            }
            final attendees = "${widget.event.eventMembers.length},$responded,$confirmed";
            return AttendeeNumbers(
              attendees: attendees,
              total: widget.event.capacity,
              backgroundColor: AppColors.greyColor.withOpacity(0.1),
            );
          }
          return AttendeeNumbers(
            attendees: "${ref.watch(newEventProvider).attendees},0,0",
            total: widget.event.capacity,
            backgroundColor: AppColors.greyColor.withOpacity(0.1),
          );
        },
      ),
    );
  }

  String _getUserTag(String status) {
    if (!widget.showTag) {
      return "";
    }
    switch (status) {
      case "hosted":
        return "Hosting";
      case "requested" || "pending":
        return "Requested";
      case "confirmed":
        return "Confirmed";
      case "invited":
        return "Invited";
      case "declined":
        return "Declined";
      default:
        return "Interested ?";
    }
  }
}
