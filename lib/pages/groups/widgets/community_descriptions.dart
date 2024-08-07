import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/groups/res/group_description_res.dart';
import 'package:zipbuzz/pages/groups/group_events_screen.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class CommunityDescriptions extends ConsumerWidget {
  const CommunityDescriptions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(dioServicesProvider).getGroupDescriptions(ref.read(userProvider).id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          );
        }
        if (!snapshot.hasData) {
          return const SizedBox();
        }
        final groupDescriptions = snapshot.data!.results;
        return ListView.builder(
          itemCount: groupDescriptions.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return _buildGroupTitleCard(groupDescriptions[index], ref);
          },
        );
      },
    );
  }

  Widget _buildGroupTitleCard(GroupDescriptionModel groupDescription, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        // Update the current group description
        ref.read(groupControllerProvider.notifier).updateCurrentGroupDescription(groupDescription);
        await navigatorKey.currentState!.pushNamed(GroupEventsScreen.id);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderGrey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                groupDescription.groupName,
                style: AppStyles.h4.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              ">",
              style: AppStyles.h4.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
