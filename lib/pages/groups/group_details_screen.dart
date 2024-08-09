import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/groups/group_model.dart';
import 'package:zipbuzz/pages/groups/group_members_screen.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class GroupDetailsScreen extends ConsumerStatefulWidget {
  static const id = '/groups/group-details';
  const GroupDetailsScreen({super.key});

  @override
  ConsumerState<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends ConsumerState<GroupDetailsScreen> {
  late GroupModel group;
  @override
  Widget build(BuildContext context) {
    final userId = ref.read(userProvider).id;
    final groupId = ref.read(groupControllerProvider).currentGroupDescription!.id;
    return Scaffold(
      appBar: _buildAppBar(),
      body: FutureBuilder(
          future: ref.read(dioServicesProvider).getGroupDetails(userId, groupId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ));
            }
            if (!snapshot.hasData) {
              return Center(
                child: IconButton(
                  onPressed: () {
                    setState(() {});
                  },
                  icon: const Icon(Icons.refresh_rounded),
                ),
              );
            }
            group = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildCoverImages(),
                  const SizedBox(height: 16),
                  Text(
                    group.name,
                    style: AppStyles.h2.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    group.description,
                    style: AppStyles.h3.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  _buildDescription(),
                  _buildDetailTab("Members", onTap: () {
                    ref.read(groupControllerProvider.notifier).getGroupMembers();
                    navigatorKey.currentState!.pushNamed(GroupMembersScreen.id);
                  }),
                  _buildDetailTab("Links and Media"),
                  // _buildPublicToggleButton(),
                  const SizedBox(height: 16),
                  _buildInviteMembersButton(),
                  _buildExitButton(),
                  _buildDeleteButton()
                ],
              ),
            );
          }),
    );
  }

  Widget _buildDeleteButton() {
    if (!ref.watch(groupControllerProvider).isAdmin) return const SizedBox();
    return InkWell(
      onTap: () {
       
        
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryColor),
        ),
        child: Text(
          "Archive/Delete Group",
          style: AppStyles.h4.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Container _buildExitButton() {
    return Container(
      margin: const EdgeInsets.only(top: 32, bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor),
      ),
      child: Text(
        "Exit from Group",
        style: AppStyles.h4.copyWith(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInviteMembersButton() {
    final user = ref.read(userProvider);
    final admin = ref.watch(groupControllerProvider).admins.any((e) => e.userId == user.id);
    if (!admin) return const SizedBox();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.buttonColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "Invite Members",
        style: AppStyles.h4.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Container _buildDescription() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.bgGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Text(
        group.description,
        style: AppStyles.h4,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        "Bible Study",
        style: AppStyles.h2.copyWith(fontWeight: FontWeight.w600),
      ),
      leading: IconButton(
        onPressed: () {
          navigatorKey.currentState!.pop();
        },
        icon: const Icon(Icons.arrow_back_ios),
      ),
      elevation: 0,
    );
  }

  Widget _buildPublicToggleButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Available to Public",
              style: AppStyles.h4.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.greyColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 74,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.borderGrey,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: group.listed ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Container(
                  height: 24,
                  width: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailTab(String title, {Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16).copyWith(top: 0),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.bgGrey,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppStyles.h4.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.greyColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14)
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImages() {
    return SizedBox(
      height: 160,
      child: Stack(
        children: [
          Positioned(
            left: 16,
            right: 16,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(group.banner),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(group.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
