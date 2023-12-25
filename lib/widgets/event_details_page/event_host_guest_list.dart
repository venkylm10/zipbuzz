import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/models/events/event_invite_members.dart';
import 'package:zipbuzz/models/events/event_request_member.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/defaults.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

final guestListTagProvider = StateProvider<String>((ref) => "All");
final eventRequestMembersProvider = StateProvider<List<EventRequestMember>>((ref) => []);

class EventHostGuestList extends StatelessWidget {
  const EventHostGuestList({super.key, required this.guests, required this.eventId});

  final int eventId;
  final List<EventInviteMember> guests;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildMemberTags(),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderGrey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: buildMembersList(),
        )
      ],
    );
  }

  Widget buildMembersList() {
    return Consumer(
      builder: (context, ref, child) {
        final selectedTag = ref.watch(guestListTagProvider);
        if (selectedTag == "All") {
          return buildInviteMembers();
        }
        if (selectedTag == "Pending") {
          return buildPendingMembers();
        }

        if (selectedTag == "Confirmed") {
          return buildConfirmedMembers();
        }
        return const SizedBox(width: double.infinity);
      },
    );
  }

  Widget buildPendingMembers() {
    return Consumer(builder: (context, ref, child) {
      final data = ref.watch(eventRequestMembersProvider);
      final pendingMembers = data.where((element) => element.status == "pending").toList();
      return ListView.builder(
        itemCount: pendingMembers.length,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final member = pendingMembers[index];
          return buildRequestMemberCard(member, context, index, isPending: true);
        },
      );
    });
  }

  Widget buildConfirmedMembers() {
    return Consumer(builder: (context, ref, child) {
      var data = ref.watch(eventRequestMembersProvider);
      final pendingMembers = data.where((element) => element.status == "confirm").toList();
      return ListView.builder(
        itemCount: pendingMembers.length,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final member = pendingMembers[index];
          return buildRequestMemberCard(member, context, index);
        },
      );
    });
  }

  ListView buildInviteMembers() {
    return ListView.builder(
      itemCount: guests.length,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final member = guests[index];
        return buildMembercard(member, context, index);
      },
    );
  }

  Column buildRequestMemberCard(EventRequestMember member, BuildContext context, int index,
      {bool isPending = false}) {
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
                    member.image != "null" ? member.image : Defaults().contactAvatarUrl,
                    height: 32,
                    width: 32),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      member.name,
                      style: AppStyles.h5,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      '@zipbuzz_user',
                      style: AppStyles.h6
                          .copyWith(fontStyle: FontStyle.italic, color: AppColors.lightGreyColor),
                    ),
                  ),
                ],
              ),
              const Expanded(child: SizedBox()),
              Consumer(builder: (context, ref, child) {
                return GestureDetector(
                  onTap: () async {
                    if (isPending) {
                      var newMember = member;
                      newMember.status = "confirm";
                      var updateMembers = ref.read(eventRequestMembersProvider);
                      updateMembers.removeAt(index);
                      updateMembers.insert(index, newMember);
                      ref
                          .read(eventRequestMembersProvider.notifier)
                          .update((state) => updateMembers);
                      await ref.read(dioServicesProvider).editUserStatus(member.id, "confirm");
                      ref.read(guestListTagProvider.notifier).update((state) => "Confirmed");
                    }
                  },
                  child: buildGuestTag(),
                );
              })
            ],
          ),
        ),
        if (index != guests.length - 1)
          Divider(
            color: AppColors.greyColor.withOpacity(0.2),
            thickness: 0,
          ),
      ],
    );
  }

  Column buildMembercard(EventInviteMember member, BuildContext context, int index) {
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
                child: Image.network(member.image, height: 32, width: 32),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      member.name,
                      style: AppStyles.h5,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      '@zipbuzz_user',
                      style: AppStyles.h6
                          .copyWith(fontStyle: FontStyle.italic, color: AppColors.lightGreyColor),
                    ),
                  ),
                ],
              ),
              const Expanded(child: SizedBox()),
              buildGuestTag()
            ],
          ),
        ),
        if (index != guests.length - 1)
          Divider(
            color: AppColors.greyColor.withOpacity(0.2),
            thickness: 0,
          ),
      ],
    );
  }

  Consumer buildGuestTag() {
    return Consumer(
      builder: (context, ref, child) {
        final selectedTag = ref.watch(guestListTagProvider);
        if (selectedTag == "Confirmed") {
          return const SizedBox();
        } else if (selectedTag == "Pending") {
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFEAF6ED),
            ),
            child: Text(
              "Confirm",
              style: AppStyles.h5.copyWith(
                color: Colors.green.shade500,
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  SingleChildScrollView buildMemberTags() {
    const List<String> tags = [
      "All",
      "Pending",
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
            final allLength = guests.length;
            var pendingLength = ref
                .watch(eventRequestMembersProvider)
                .where((element) => element.status == "pending")
                .toList()
                .length;
            var confirmedLength = ref
                .watch(eventRequestMembersProvider)
                .where((element) => element.status == "confirm")
                .toList()
                .length;
            return GestureDetector(
              onTap: () {
                ref.read(guestListTagProvider.notifier).update((state) => tags[index]);
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selectedTag == tags[index] ? AppColors.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color:
                        selectedTag == tags[index] ? AppColors.primaryColor : AppColors.borderGrey,
                  ),
                ),
                child: Text(
                  "${tags[index]} (${tags[index] == "All" ? allLength : tags[index] == "Pending" ? pendingLength : confirmedLength})",
                  style: AppStyles.h5.copyWith(
                    color: selectedTag == tags[index] ? Colors.white : AppColors.greyColor,
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
