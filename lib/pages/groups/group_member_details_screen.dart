import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/pages/home/widgets/home_interest_chip.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class GroupMemberDetailsScreen extends ConsumerStatefulWidget {
  static const id = '/groups/group-details/group-members/member-details';
  const GroupMemberDetailsScreen({super.key});

  @override
  ConsumerState<GroupMemberDetailsScreen> createState() => _GroupMemberDetailsScreenState();
}

class _GroupMemberDetailsScreenState extends ConsumerState<GroupMemberDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final interests = allInterests.sublist(0, 5);
    final member = ref.read(groupControllerProvider).currentGroupMember;
    final groupDes = ref.read(groupControllerProvider).currentGroupDescription;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          groupDes!.groupName,
          style: AppStyles.h2.copyWith(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () {
            navigatorKey.currentState!.pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member!.name, style: AppStyles.h2),
                      Text("[About Me]", style: AppStyles.h5),
                      Text("95120", style: AppStyles.h5),
                    ],
                  ),
                ),
                Container(
                  height: 80,
                  width: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightGreyColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.start,
                children: List.generate(
                  interests.length,
                  (index) {
                    final first = index == 0;
                    final last = index == interests.length - 1;
                    final interest = interests[index];
                    return Padding(
                      padding: EdgeInsets.only(left: first ? 12 : 0, right: last ? 12 : 0),
                      child: HomeInterestChip(
                        interest: interest,
                        toggleHomeCategory: () {
                          // toggleHomeCategory(interest.activity);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildMessageButton(),
            _buildRemoveAdminButton(),
            _buildRemoveFromGroupButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoveFromGroupButton() {
    if (!ref.read(groupControllerProvider).isAdmin) return const SizedBox();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor),
      ),
      child: Text(
        "Remove from Group",
        style: AppStyles.h4.copyWith(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRemoveAdminButton() {
    if (!ref.read(groupControllerProvider).isAdmin) return const SizedBox();
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor),
      ),
      child: Text(
        "Remove as Admin",
        style: AppStyles.h4.copyWith(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Container _buildMessageButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.buttonColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "Send Message",
        style: AppStyles.h4.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
