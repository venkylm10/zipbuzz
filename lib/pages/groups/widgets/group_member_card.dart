import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/controllers/navigation_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/groups/group_member_model.dart';
import 'package:zipbuzz/models/groups/post/invite_group_member_model.dart';
import 'package:zipbuzz/pages/groups/group_member_details_screen.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/defaults.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:zipbuzz/utils/widgets/snackbar.dart';

class GroupMemberCard extends ConsumerStatefulWidget {
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
  ConsumerState<GroupMemberCard> createState() => _GroupMemberCardState();
}

class _GroupMemberCardState extends ConsumerState<GroupMemberCard> {
  var loader = false;
  @override
  Widget build(BuildContext context) {
    final borderColor = widget.member.permissionType == GroupPermissionType.invite
        ? Colors.red.withOpacity(0.6)
        : widget.member.permissionType == GroupPermissionType.pending
            ? Colors.green.withOpacity(0.6)
            : AppColors.borderGrey;
    return GestureDetector(
      onTap: () {
        if (widget.invitee) return;
        ref.read(groupControllerProvider.notifier).updateCurrentGroupMember(widget.member);
        navigatorKey.currentState!.push(
          NavigationController.getTransition(
            GroupMemberDetailsScreen(userId: widget.member.userId),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.bgGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                    widget.member.userId == 0
                        ? Defaults.contactAvatarUrl
                        : widget.member.profilePicture,
                  ),
                  backgroundColor: AppColors.bgGrey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.member.name,
                        style: AppStyles.h4.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.greyColor,
                        ),
                      ),
                      if (widget.member.permissionType == GroupPermissionType.invite)
                        Text(
                          timeago.format(widget.member.relatedTime, locale: 'en_short'),
                          style: AppStyles.h5.copyWith(
                            color: AppColors.lightGreyColor,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (!widget.invitee) const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                _buildInviteToBuzzMeButton(ref),
                _buildMemberAcceptButton(ref),
                if (widget.member.permissionType == GroupPermissionType.invite)
                  _buildInviteAgainButton(ref),
              ],
            ),
          ),
          if (loader)
            const Positioned.fill(
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  GestureDetector _buildInviteAgainButton(WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final group = ref.read(groupControllerProvider).currentGroup!;
        setState(() {
          loader = true;
        });
        try {
          await ref.read(dioServicesProvider).inviteToGroup(
                InviteGroupMemberModel(
                  groupId: group.id,
                  userId: ref.read(userProvider).id,
                  title: group.name,
                  inviteName: widget.member.name,
                  phoneNumber: widget.member.phone,
                  invitingUserName: ref.read(userProvider).name,
                ),
              );
          showSnackBar(message: "Successfully invited ${widget.member.name} again");
          if (mounted) {
            setState(() {
              loader = false;
            });
          }
          await Future.delayed(const Duration(seconds: 2));
        } catch (e) {
          debugPrint("Error inviting member: $e");
          showSnackBar(message: "Error inviting ${widget.member.name} again");
        }
        if (mounted) {
          setState(() {
            loader = false;
          });
        }
        await ref.read(groupControllerProvider.notifier).getGroupMembers(loader: false);
      },
      child: Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          "Invite again",
          style: AppStyles.h5.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMemberAcceptButton(WidgetRef ref) {
    if (!widget.invitee || widget.member.userId == 0) return const SizedBox();
    return Consumer(builder: (context, ref, child) {
      final admin = ref.watch(groupControllerProvider).isAdmin;
      if (!admin) return const SizedBox();
      if (widget.member.permissionType != GroupPermissionType.pending) return const SizedBox();
      return GestureDetector(
        onTap: () async {
          final groupId = ref.read(groupControllerProvider).currentGroup!.id;
          await ref
              .read(groupControllerProvider.notifier)
              .addMemberToGroup(widget.member.userId, groupId);
        },
        child: Container(
          margin: const EdgeInsets.only(left: 6),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            "Confirm",
            style: AppStyles.h5.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildInviteToBuzzMeButton(WidgetRef ref) {
    if (!widget.invitee || widget.member.userId != 0) return const SizedBox();
    return GestureDetector(
      onTap: () {
        final user = ref.read(userProvider);
        final shareText =
            "${user.name} invites to you to join Buzz.Me\n\nDownload Buzz.Me at https://buzzme.site/download";
        Share.share(shareText);
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
