import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/models/events/event_invite_members.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/defaults.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class EventGuestList extends ConsumerStatefulWidget {
  const EventGuestList({super.key, required this.guests, required this.clone});

  final List<EventInviteMember> guests;
  final bool clone;

  @override
  ConsumerState<EventGuestList> createState() => _EventGuestListState();
}

class _EventGuestListState extends ConsumerState<EventGuestList> {
  int subListLength = 8;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildGuests(context),
        if (widget.guests.length > subListLength) const SizedBox(height: 16),
        if (widget.guests.length > subListLength) loadMoreButton()
      ],
    );
  }

  GestureDetector loadMoreButton() {
    return GestureDetector(
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
    return Consumer(builder: (context, ref, child) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        childAspectRatio: 3.2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        children: widget.guests
            .sublist(0, min(subListLength, widget.guests.length))
            .map(
              (member) => Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderGrey),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            member.image != "null" ? member.image : Defaults().contactAvatarUrl,
                            height: 32,
                            width: 32,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: Text(
                                member.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: AppStyles.h5,
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: Text(
                                member.phone,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: AppStyles.h6.copyWith(
                                    fontStyle: FontStyle.italic, color: AppColors.lightGreyColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (widget.clone)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Transform.translate(
                        offset: const Offset(4, -4),
                        child: GestureDetector(
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
                    ),
                ],
              ),
            )
            .toList(),
      );
    });
  }
}
