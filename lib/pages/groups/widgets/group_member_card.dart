import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/controllers/navigation_controller.dart';
import 'package:zipbuzz/env.dart';
import 'package:zipbuzz/models/groups/group_member_model.dart';
import 'package:zipbuzz/pages/groups/group_member_details_screen.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class GroupMemberCard extends ConsumerWidget {
  const GroupMemberCard({
    super.key,
    required this.member,
    this.isAdmin = false,
    this.invitee = false,
  });

  final GroupMemberModel member;
  final bool isAdmin;
  final bool invitee;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        if (invitee) return;
        ref.read(groupControllerProvider.notifier).updateCurrentGroupMember(member, isAdmin);
        navigatorKey.currentState!.push(
          NavigationController.getTransition(
            GroupMemberDetailsScreen(userId: member.userId),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.bgGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(member.profilePicture),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name == 'zipbuzz-null' ? "Un-Registered User" : member.name,
                    style: AppStyles.h4.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.greyColor,
                    ),
                  ),
                  if (member.phone != 'zipbuzz-null')
                    Text(
                      member.phone,
                      style: AppStyles.h5.copyWith(
                        color: AppColors.lightGreyColor,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (!invitee) const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            _buildInviteToBuzzMeButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteToBuzzMeButton() {
    if (!invitee || member.name != 'zipbuzz-null') return const SizedBox();
    return GestureDetector(
      onTap: () {
        launchUrlString(AppEnvironment.websiteUrl);
      },
      child: Container(
        margin: const EdgeInsets.only(left: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Text(
          "Invite to BuzzMe",
          style: AppStyles.h5.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
