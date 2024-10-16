import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/models/events/event_invite_members.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/pages/events/widgets/event_host_guest_list.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/defaults.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class EventDetailsGuestList extends ConsumerStatefulWidget {
  const EventDetailsGuestList({
    super.key,
    required this.event,
    required this.guests,
    required this.isPreview,
    required this.clone,
    this.addRSVPToList = false,
  });

  final List<EventInviteMember> guests;
  final EventModel event;
  final bool isPreview;
  final bool clone;
  final bool addRSVPToList;

  @override
  ConsumerState<EventDetailsGuestList> createState() => _EventDetailsGuestListState();
}

class _EventDetailsGuestListState extends ConsumerState<EventDetailsGuestList> {
  int subListLength = 8;
  late List<EventInviteMember> guests;

  final guestColors = {
    'confirm': AppColors.positiveGreen,
    'declined': AppColors.negativeRed,
    'invited': AppColors.borderGrey,
    'accepted': Colors.orange,
    'pending': Colors.yellow,
  };

  @override
  void initState() {
    guests = widget.guests;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildGuestListTitle(),
        const SizedBox(height: 16),
        buildGuests(context),
        if (widget.guests.length > subListLength) const SizedBox(height: 16),
        if (widget.guests.length > subListLength) loadMoreButton()
      ],
    );
  }

  Consumer buildGuestListTitle() {
    return Consumer(builder: (context, ref, child) {
      final newEvent = ref.watch(newEventProvider);
      var num = widget.event.eventMembers.length;
      if (widget.isPreview) {
        num = newEvent.eventMembers.length;
      }
      return Text(
        "Guest list ($num)",
        style: AppStyles.h5.copyWith(
          color: AppColors.lightGreyColor,
        ),
      );
    });
  }

  InkWell loadMoreButton() {
    return InkWell(
      onTap: () {
        setState(() {
          if (subListLength + 8 > widget.guests.length) {
            subListLength = widget.guests.length;
          } else {
            subListLength += 8;
          }
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Center(
          child: Text(
            "Load more",
            style: AppStyles.h5.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGuests(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final rsvpMembers = ref.watch(eventRequestMembersProvider);
        final allGuests = widget.addRSVPToList
            ? rsvpMembers
                .map((e) => EventInviteMember(
                      name: e.name,
                      phone: e.phone,
                      image: e.image,
                      status: e.status,
                    ))
                .toList()
            : widget.guests;

        if (widget.addRSVPToList) {
          for (var e in widget.guests) {
            final contains = allGuests.any((element) => element.phone.contains(e.phone));
            if (!contains) {
              allGuests.add(e);
            }
          }
        }
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          childAspectRatio: 3.2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          children: allGuests
              .sublist(0, min(subListLength, allGuests.length))
              .map(
                (member) => Stack(
                  children: [
                    _buildMemberCard(member, context),
                    _buildRemoveButton(ref, member),
                  ],
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildRemoveButton(WidgetRef ref, EventInviteMember member) {
    if (!widget.clone) {
      return const SizedBox();
    }
    return Positioned(
      right: 0,
      top: 0,
      child: Transform.translate(
        offset: const Offset(4, -4),
        child: InkWell(
          onTap: () {
            ref.read(newEventProvider.notifier).removeInviteMember(member.phone);
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.borderGrey,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Transform.rotate(
              angle: pi / 4,
              child: const Icon(Icons.add, size: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard(EventInviteMember member, BuildContext context) {
    final borderColor = widget.addRSVPToList
        ? guestColors[member.status] ?? AppColors.borderGrey
        : AppColors.borderGrey;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              member.image != "null" ? member.image : Defaults.contactAvatarUrl,
              height: 32,
              width: 32,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: AppStyles.h5,
                ),
                // SizedBox(
                //   width: MediaQuery.of(context).size.width * 0.25,
                //   child: Text(
                //     member.phone != "zipbuzz-null" ? member.phone : "",
                //     overflow: TextOverflow.ellipsis,
                //     maxLines: 1,
                //     style: AppStyles.h6
                //         .copyWith(fontStyle: FontStyle.italic, color: AppColors.lightGreyColor),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
