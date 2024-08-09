import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zipbuzz/controllers/groups/group_controller.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/custom_text_field.dart';
import 'package:zipbuzz/utils/widgets/hyperlink_fields.dart';

class CreateGroupForm extends ConsumerWidget {
  const CreateGroupForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildClosingButton(ref),
              _buildFieldTitle("Group Name", true),
              CustomTextField(
                controller: ref.read(groupControllerProvider.notifier).nameController,
                hintText: "Group Name",
              ),
              _buildFieldTitle("Group Description", true),
              CustomTextField(
                controller: ref.read(groupControllerProvider.notifier).descriptionController,
                hintText: "Group Description",
                maxLines: 4,
              ),
              _buildFieldTitle("Group Profile Image", false),
              _buildAddButton(ref, isProfile: true),
              _buildFieldTitle("Group Banner Image", false),
              _buildAddButton(ref, isProfile: false),
              _buildFieldTitle("Group url", false),
              HyperlinkFields(
                nameController: TextEditingController(),
                urlController: TextEditingController(),
                onDelete: () {},
              ),
              // _buildFieldTitle("Group visibility", false),
              // Row(
              //   children: [
              //     groupTypeCard(ref, "Public group", "Shown to All", false),
              //     const SizedBox(width: 8),
              //     groupTypeCard(ref, "Private group", "By Invitation Only", true),
              //   ],
              // ),
              const SizedBox(height: 16),
              createGroupButton(ref),
              const SizedBox(height: 32),
            ],
          ),
        ),
        _buildLoader(ref),
      ],
    );
  }

  Widget _buildLoader(WidgetRef ref) {
    if (!ref.watch(groupControllerProvider).loading) return const SizedBox();
    return Positioned.fill(
      child: Container(
        color: Colors.white.withOpacity(0.6),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primaryColor),
              Text("Please don't move to other screen or close the App"),
            ],
          ),
        ),
      ),
    );
  }

  Widget createGroupButton(WidgetRef ref) {
    return InkWell(
      onTap: () {
        ref.read(groupControllerProvider.notifier).createGroup();
      },
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(Assets.icons.save_event),
            const SizedBox(width: 8),
            Text(
              "Save & Invite Members",
              style: AppStyles.h3.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget groupTypeCard(
    WidgetRef ref,
    String title,
    String subTitle,
    bool value,
  ) {
    final selected = ref.watch(groupControllerProvider).privateGroup;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (value == selected) return;
          ref.read(groupControllerProvider.notifier).updateGroupVisibility(value);
        },
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.bgGrey,
            border: Border.all(
              color: selected == value ? AppColors.primaryColor : AppColors.borderGrey,
            ),
          ),
          child: Row(
            children: [
              Radio(
                value: value,
                groupValue: selected,
                activeColor: AppColors.primaryColor,
                onChanged: (value) {
                  if (value == null || value == selected) return;
                  ref.read(groupControllerProvider.notifier).updateGroupVisibility(value);
                },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppStyles.h4),
                  Text(
                    subTitle,
                    style: AppStyles.h5.copyWith(
                      color: AppColors.lightGreyColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InkWell _buildAddButton(WidgetRef ref, {bool isProfile = true}) {
    final image = isProfile
        ? ref.watch(groupControllerProvider).profileImage
        : ref.watch(groupControllerProvider).bannerImage;
    return InkWell(
      onTap: () {
        if (isProfile) {
          ref.read(groupControllerProvider.notifier).pickProfileImage();
        } else {
          ref.read(groupControllerProvider.notifier).pickBannerImage();
        }
      },
      child: image == null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bgGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(Assets.icons.add_circle),
                  const SizedBox(width: 8),
                  Text(
                    "Add",
                    style: AppStyles.h4.copyWith(
                      color: AppColors.greyColor,
                    ),
                  ),
                ],
              ),
            )
          : isProfile
              ? _buildProfileImage(image, ref)
              : _buildBannerImage(image, ref),
    );
  }

  Widget _buildBannerImage(File image, WidgetRef ref) {
    return Align(
      alignment: Alignment.center,
      child: InkWell(
        onTap: () {
          ref.read(groupControllerProvider.notifier).pickProfileImage();
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            image,
            width: double.infinity,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(File image, WidgetRef ref) {
    return Align(
      alignment: Alignment.center,
      child: InkWell(
        onTap: () {
          ref.read(groupControllerProvider.notifier).pickProfileImage();
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Image.file(
            image,
            height: 100,
            width: 100,
          ),
        ),
      ),
    );
  }

  Widget _buildFieldTitle(String title, bool isNecessary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 16),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: title,
              style: AppStyles.h4.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
                color: const Color(0xff67686A),
              ),
            ),
            if (isNecessary)
              TextSpan(
                text: "*",
                style: AppStyles.h4.copyWith(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  Row _buildClosingButton(WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Create Group",
          style: AppStyles.h3.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xff373739),
          ),
        ),
        InkWell(
          onTap: () => ref.read(groupControllerProvider.notifier).toggleCreatingGroup(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey,
              ),
            ),
            child: const Icon(Icons.close, size: 12),
          ),
        ),
      ],
    );
  }
}
