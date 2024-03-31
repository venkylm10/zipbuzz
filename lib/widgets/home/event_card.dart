import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:zipbuzz/controllers/events/edit_event_controller.dart';
import 'package:zipbuzz/controllers/events/events_controller.dart';
import 'package:zipbuzz/controllers/events/events_tab_controler.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/controllers/home/home_tab_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/event_request_member.dart';
import 'package:zipbuzz/models/events/requests/event_members_request_model.dart';
import 'package:zipbuzz/services/contact_services.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/pages/event_details/event_details_page.dart';
import 'package:zipbuzz/widgets/common/attendee_numbers.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';
import 'package:zipbuzz/widgets/event_details_page/event_host_guest_list.dart';

// ignore: must_be_immutable
class EventCard extends ConsumerStatefulWidget {
  EventModel event;
  final bool focusedEvent;
  final bool showTag;
  final bool myEvent;

  EventCard({
    super.key,
    required this.event,
    this.focusedEvent = false,
    this.showTag = true,
    this.myEvent = false,
  });

  @override
  ConsumerState<EventCard> createState() => _EventCardState();
}

class _EventCardState extends ConsumerState<EventCard> {
  Color eventColor = Colors.white;
  int randInt = 0;
  bool isMounted = true;

  String getMonth(DateTime date) {
    final formatter = DateFormat.MMM();
    return formatter.format(date);
  }

  String getWeekDay(DateTime date) {
    return DateFormat.EEEE().format(date).substring(0, 3);
  }

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

  void getEventColor() {
    eventColor = interestColors[widget.event.category]!;
    setState(() {});
  }

  Future<void> addToFavorite() async {
    if (GetStorage().read(BoxConstants.guestUser) != null) {
      showSnackBar(message: "You need to be signed in", duration: 2);
      await Future.delayed(const Duration(seconds: 2));
      ref.read(newEventProvider.notifier).showSignInForm();
      return;
    }
    widget.event.isFavorite = !widget.event.isFavorite;
    setState(() {});
    if (widget.event.isFavorite) {
      await ref.read(eventsControllerProvider.notifier).addEventToFavorites(widget.event.id);
    } else {
      await ref.read(eventsControllerProvider.notifier).removeEventFromFavorites(widget.event.id);
    }
  }

  @override
  void initState() {
    getEventColor();
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
    final status = getUserTag(widget.event.status);
    return InkWell(
      onTap: () => navigateToEventDetails(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.focusedEvent)
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
                    child: Image.network(widget.event.iconPath),
                  )
                ],
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                children: [
                  if (status.isNotEmpty)
                    Container(
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
                    ),
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
                                  child: buildCardOptions(),
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: buildAttendees(),
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
                                    if (widget.focusedEvent) buildCategoryChip(),
                                    if (widget.focusedEvent) const SizedBox(width: 5),
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
                                if (widget.event.about.isNotEmpty) const SizedBox(height: 10),
                                Row(
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
                                const SizedBox(height: 5),
                                Row(
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
          ],
        ),
      ),
    );
  }

  void cloneEvent() {
    ref.read(homeTabControllerProvider.notifier).updateIndex(1);
    ref.read(newEventProvider.notifier).cloneEvent = true;
    final startTime = TimeOfDay.fromDateTime(DateTime.now());
    final formatedStartTime = ref.read(newEventProvider.notifier).getTimeFromTimeOfDay(startTime);
    final numbers = widget.event.eventMembers.map((e) => e.phone).toList();
    final matchingContacts = ref.read(contactsServicesProvider).getMatchingContacts(numbers);
    ref.read(newEventProvider.notifier).updateSelectedContactsList(matchingContacts);
    ref.read(newEventProvider.notifier).updateDate(DateTime.now());
    final clone = ref.read(newEventProvider).copyWith(
          title: widget.event.title,
          about: widget.event.about,
          category: widget.event.category,
          date: DateTime.now().toString(),
          startTime: formatedStartTime,
          endTime: "",
          location: widget.event.location,
          capacity: widget.event.capacity,
          bannerPath: widget.event.bannerPath,
          iconPath: widget.event.iconPath,
          attendees: widget.event.eventMembers.length,
          eventMembers: widget.event.eventMembers,
        );

    ref.read(eventTabControllerProvider.notifier).updateIndex(2);
    ref.read(newEventProvider.notifier).updateEvent(clone);
  }

  Widget buildCardOptions() {
    final hostId = widget.event.hostId;
    final userId = ref.read(userProvider).id;
    return Row(
      children: [
        if (hostId == userId)
          InkWell(
            onTap: () async {
              cloneEvent();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SvgPicture.asset(
                Assets.icons.copy,
                colorFilter: const ColorFilter.mode(
                  AppColors.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () async {
            await addToFavorite();
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.favorite_rounded,
              color: widget.event.isFavorite ? Colors.red[500] : Colors.grey[300],
            ),
          ),
        )
      ],
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

  Widget buildAttendees() {
    return FutureBuilder(
      future: getEventMembers(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.data!;
          final confirmedMembers =
              data.where((element) => element.status == "confirm").toList().length;
          final respondedMembers = data.length;
          final attendees =
              "${widget.event.eventMembers.length},$respondedMembers,$confirmedMembers";
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
    );
  }

  String getUserTag(String status) {
    if (!widget.showTag) {
      return "";
    }
    switch (status) {
      case "hosted":
        return "Hosted";
      case "requested":
        return "Requested";
      case "confirmed":
        return "Confirmed";
      case "invited":
        return "Invited";
      default:
        return "";
    }
  }

  Container buildHostChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2).copyWith(left: 2),
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

  Container buildCategoryChip() {
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
          Image.network(
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
            style: AppStyles.h2.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            getWeekDay(date),
            style: AppStyles.h4.copyWith(color: AppColors.greyColor),
          )
        ],
      ),
    );
  }
}
