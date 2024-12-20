import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/event_invite_members.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/models/events/event_request_member.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/defaults.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/broad_divider.dart';
import 'package:zipbuzz/utils/widgets/snackbar.dart';
import 'package:timeago/timeago.dart' as timeago;

final guestListTagProvider = StateProvider<String>((ref) => "Invited");
final eventRequestMembersProvider =
    StateProvider<List<EventRequestMember>>((ref) => []);

class EventHostGuestList extends ConsumerStatefulWidget {
  const EventHostGuestList({
    super.key,
    required this.event,
    required this.guests,
    this.interative = true,
  });

  final EventModel event;
  final List<EventInviteMember> guests;
  final bool interative;

  @override
  ConsumerState<EventHostGuestList> createState() => _EventHostGuestListState();
}

class _EventHostGuestListState extends ConsumerState<EventHostGuestList> {
  String formatName(String fullName) {
    List<String> nameParts = fullName.split(' ');
    if (nameParts.length < 2) {
      return fullName;
    }
    String firstName = nameParts[0];
    String lastInitial = nameParts[1][0];
    return '$firstName $lastInitial.';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildGuestListTitle(),
        const SizedBox(height: 16),
        buildMemberTags(),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderGrey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: buildMembersList(),
        ),
        broadDivider(host: true),
      ],
    );
  }

  Text buildGuestListTitle() {
    return Text(
      "Guest list",
      style: AppStyles.h5.copyWith(
        color: AppColors.lightGreyColor,
      ),
    );
  }

  Widget buildMembersList() {
    return Consumer(
      builder: (context, ref, child) {
        final selectedTag = ref.watch(guestListTagProvider);
        if (selectedTag == "Invited") {
          return buildInviteMembers();
        }
        if (selectedTag == "RSVPs") {
          return buildRespondedMembers();
        }

        if (selectedTag == "Confirmed") {
          return buildConfirmedMembers();
        }
        return const SizedBox(width: double.infinity);
      },
    );
  }

  Widget buildRespondedMembers() {
    return Consumer(builder: (context, ref, child) {
      final data = ref.watch(eventRequestMembersProvider);
      final responedMembers = data;
      return ListView.builder(
        itemCount: responedMembers.length,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final member = responedMembers[index];
          return buildRequestMemberCard(member, context, index,
              isPending: member.status == "pending",
              isLast: index == responedMembers.length - 1);
        },
      );
    });
  }

  Widget buildConfirmedMembers() {
    return Consumer(builder: (context, ref, child) {
      var data = ref.watch(eventRequestMembersProvider);
      final confirmedMembers = data
          .where((element) =>
              element.status == "confirm" || element.status == 'host')
          .toList();
      return ListView.builder(
        itemCount: confirmedMembers.length,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final member = confirmedMembers[index];
          return buildRequestMemberCard(member, context, index,
              isLast: index == confirmedMembers.length - 1);
        },
      );
    });
  }

  ListView buildInviteMembers() {
    return ListView.builder(
      itemCount: widget.guests.length,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final member = widget.guests[index];
        return buildMembercard(member, context, index);
      },
    );
  }

  Column buildRequestMemberCard(
      EventRequestMember member, BuildContext context, int index,
      {bool isPending = false, bool isLast = false}) {
    String formattedName = formatName(member.name);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                    member.image != "null"
                        ? member.image
                        : Defaults.contactAvatarUrl,
                    height: 32,
                    width: 32),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedName,
                      style: AppStyles.h5,
                    ),
                  ],
                ),
              ),
              if (member.attendees > 1)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "+${member.attendees - 1}",
                    style: AppStyles.h4.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              if (member.totalAmount > 0 &&
                  widget.event.hostId == ref.read(userProvider).id)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFEAF6ED),
                  ),
                  child: Text(
                    "\$${member.totalAmount.toStringAsFixed(2)}",
                    style: AppStyles.h5.copyWith(
                      color: Colors.green.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (widget.interative || member.status == "confirm")
                Consumer(
                  builder: (context, ref, child) {
                    return InkWell(
                      onTap: () async {
                        if (!widget.interative || !isPending) return;
                        if (member.status == "declined") return;
                        if (member.status == "host") return;
                        var newMember = member;
                        newMember.status = "confirm";
                        var updateMembers =
                            ref.read(eventRequestMembersProvider);
                        updateMembers.removeWhere(
                            (element) => element.userId == newMember.userId);
                        updateMembers.add(newMember);
                        ref
                            .read(eventRequestMembersProvider.notifier)
                            .update((state) => updateMembers);
                        showSnackBar(
                            message:
                                "${member.name} was confirmed for the event.");
                        ref
                            .read(guestListTagProvider.notifier)
                            .update((state) => "Confirmed");
                        await ref.read(dioServicesProvider).editUserStatus(
                            widget.event.id, member.userId, "confirm");
                        await ref
                            .read(dioServicesProvider)
                            .updateRespondedNotification(
                                member.userId, widget.event.hostId,
                                eventId: widget.event.id);
                      },
                      child: buildGuestTag(member.status),
                    );
                  },
                )
            ],
          ),
        ),
        if (member.ticketDetails != 'zipbuzz-null')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              member.ticketDetails,
              style: AppStyles.h5.copyWith(
                color: AppColors.greyColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        if (!isLast)
          Divider(
            color: AppColors.greyColor.withOpacity(0.2),
            thickness: 0,
          ),
      ],
    );
  }

  Column buildMembercard(
      EventInviteMember member, BuildContext context, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                    member.image != "null"
                        ? member.image
                        : Defaults.contactAvatarUrl,
                    height: 32,
                    width: 32),
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
                      style: AppStyles.h5,
                    ),
                    Text(
                      timeago.format(member.memberTime!, locale: 'en_short'),
                      style: AppStyles.h6.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.lightGreyColor,
                      ),
                    )
                  ],
                ),
              ),
              buildGuestTag(member.status)
            ],
          ),
        ),
        if (index != widget.guests.length - 1)
          Divider(
            color: AppColors.greyColor.withOpacity(0.2),
            thickness: 0,
          ),
      ],
    );
  }

  Consumer buildGuestTag(String status) {
    return Consumer(
      builder: (context, ref, child) {
        final selectedTag = ref.watch(guestListTagProvider);
        if (selectedTag == "Confirmed") {
          return const SizedBox();
        }
        var text = "";
        if (widget.interative) {
          if (status == "pending") {
            text = "Confirm";
          } else if (status == 'host') {
            text = "Host";
          } else if (status == "declined") {
            text = "Declined";
          } else if (status == "invited") {
            text = "Invited";
          } else {
            text = "Confirmed";
          }
        } else {
          return const SizedBox();
        }
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: status == "declined"
                ? const Color.fromARGB(255, 238, 201, 198)
                : status == "pending"
                    ? const Color(0xFFFAF5E0)
                    : const Color(0xFFEAF6ED),
          ),
          child: Text(
            text,
            style: AppStyles.h5.copyWith(
              color: status == "declined"
                  ? Colors.red.shade500
                  : status == "pending"
                      ? Colors.yellow.shade900
                      : Colors.green.shade500,
            ),
          ),
        );
      },
    );
  }

  SingleChildScrollView buildMemberTags() {
    const List<String> tags = [
      "Invited",
      "RSVPs",
      "Confirmed",
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          tags.length,
          (index) => Consumer(builder: (context, ref, child) {
            final selectedTag = ref.watch(guestListTagProvider);
            final allLength = widget.guests.length;
            var respondedLength = 0;
            var confirmedLength = 0;
            final data = ref.watch(eventRequestMembersProvider);
            final responedMembers = data;
            final confirmedMembers = data.where((element) {
              return element.status == "confirm" || element.status == 'host';
            }).toList();
            for (var e in responedMembers) {
              respondedLength += e.attendees;
            }
            for (var e in confirmedMembers) {
              confirmedLength += e.attendees;
            }
            return InkWell(
              onTap: () {
                ref
                    .read(guestListTagProvider.notifier)
                    .update((state) => tags[index]);
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selectedTag == tags[index]
                      ? AppColors.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: selectedTag == tags[index]
                        ? AppColors.primaryColor
                        : AppColors.borderGrey,
                  ),
                ),
                child: Text(
                  "${tags[index]} (${tags[index] == "Invited" ? allLength : tags[index] == "RSVPs" ? respondedLength : confirmedLength})",
                  style: AppStyles.h5.copyWith(
                    color: selectedTag == tags[index]
                        ? Colors.white
                        : AppColors.greyColor,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
