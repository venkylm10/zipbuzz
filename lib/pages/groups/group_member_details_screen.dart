import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/pages/home/widgets/home_interest_chip.dart';
import 'package:zipbuzz/services/db_services.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class GroupMemberDetailsScreen extends ConsumerStatefulWidget {
  static const id = '/groups/group-details/group-members/member-details';
  const GroupMemberDetailsScreen({super.key, required this.userId});
  final int userId;

  @override
  ConsumerState<GroupMemberDetailsScreen> createState() => _GroupMemberDetailsScreenState();
}

class _GroupMemberDetailsScreenState extends ConsumerState<GroupMemberDetailsScreen> {
  @override
  Widget build(BuildContext context) {
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
        child: FutureBuilder(
            future: ref.read(dbServicesProvider).getUserModel(widget.userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              } else if (!snapshot.hasData) {
                return Center(
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {});
                        },
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                      const Text("Something went wrong!")
                    ],
                  ),
                );
              }
              final user = snapshot.data!;
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: AppStyles.h2),
                            Text(user.about, style: AppStyles.h5),
                            Text(user.zipcode, style: AppStyles.h5),
                          ],
                        ),
                      ),
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(user.imageUrl),
                            fit: BoxFit.cover,
                          ),
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
                        user.interests.length,
                        (index) {
                          final interest =
                              allInterests.firstWhere((e) => e.activity == user.interests[index]);
                          return HomeInterestChip(
                            interest: interest,
                            toggleHomeCategory: () {
                              // toggleHomeCategory(interest.activity);
                            },
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
              );
            }),
      ),
    );
  }

  Widget _buildRemoveFromGroupButton() {
    final admin = ref.watch(groupControllerProvider).isAdmin;
    if (!admin) return const SizedBox();
    var clicked = false;
    return GestureDetector(
      onTap: () async {
        if (clicked) return;
        clicked = true;
        await ref.read(groupControllerProvider.notifier).deleteGroupMember(widget.userId);
        clicked = false;
        navigatorKey.currentState!.pop();
      },
      child: Container(
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
      ),
    );
  }

  Widget _buildRemoveAdminButton() {
    final admin = ref.watch(groupControllerProvider).isAdmin;
    if (!admin) return const SizedBox();
    final isMemberAdmin =
        ref.watch(groupControllerProvider).admins.any((e) => e.userId == widget.userId);
    var clicked = false;
    return GestureDetector(
      onTap: () async {
        if (clicked) return;
        await ref
            .read(groupControllerProvider.notifier)
            .updateGroupMemberStatus(widget.userId, isMemberAdmin ? 'm' : 'a');
        await ref.read(groupControllerProvider.notifier).getGroupMembers();
        clicked = false;
      },
      child: Container(
        margin: const EdgeInsets.only(top: 16, bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryColor),
        ),
        child: Text(
          "${isMemberAdmin ? "Remove as" : "Make"} Admin",
          style: AppStyles.h4.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w500,
          ),
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
