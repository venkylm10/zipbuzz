import 'dart:math';
import 'package:flutter/material.dart';
import 'package:zipbuzz/models/events/event_invite_members.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class EventGuestList extends StatefulWidget {
  const EventGuestList({super.key, required this.guests});

  final List<EventInviteMember> guests;

  @override
  State<EventGuestList> createState() => _EventGuestListState();
}

class _EventGuestListState extends State<EventGuestList> {
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

  GridView buildGuests(BuildContext context) {
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
            (member) => Container(
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
                    child: Image.network(member.image, height: 32, width: 32),
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
                          '@zipbuzz_user',
                          style: AppStyles.h6.copyWith(
                              fontStyle: FontStyle.italic, color: AppColors.lightGreyColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
