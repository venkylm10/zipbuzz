import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/models/events/event_member_model.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

final guestListTagProvider = StateProvider<String>((ref) => "All");

class EventHostGuestList extends StatelessWidget {
  const EventHostGuestList({super.key, required this.guests});

  final List<EventMemberModel> guests;

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
          child: ListView.builder(
            itemCount: guests.length,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final member = guests[index];
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
                                style: AppStyles.h6.copyWith(
                                    fontStyle: FontStyle.italic, color: AppColors.lightGreyColor),
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
            },
          ),
        )
      ],
    );
  }

  Consumer buildGuestTag() {
    return Consumer(
      builder: (context, ref, child) {
        final selectedTag = ref.watch(guestListTagProvider);
        if (selectedTag != "Confirmed") {
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
                  "${tags[index]} (${guests.length})",
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
