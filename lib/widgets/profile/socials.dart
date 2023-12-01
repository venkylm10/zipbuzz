import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/constants/assets.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/controllers/user_controller.dart';
import 'package:zipbuzz/widgets/common/snackbar.dart';

class UserSocials extends ConsumerWidget {
  const UserSocials({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Social Links",
          style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
        ),
        const SizedBox(height: 16),
        if (user.linkedinId != null)
          buildHyperLink(Assets.icons.linkedin, "LinkedIn", user.linkedinId!),
        const SizedBox(height: 4),
        if (user.instagramId != null)
          buildHyperLink(
              Assets.icons.instagram, "Instagram", user.instagramId!),
        const SizedBox(height: 4),
        if (user.instagramId != null)
          buildHyperLink(Assets.icons.twitter, "Twitter", user.twitterId!),
      ],
    );
  }

  Row buildHyperLink(String iconPath, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          iconPath,
          height: 24,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppStyles.h4,
        ),
        const Expanded(child: SizedBox()),
        GestureDetector(
          onTap: showSnackBar,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderGrey),
            ),
            child: Row(
              children: [
                Text(
                  value,
                  style: AppStyles.h4.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(width: 8),
                SvgPicture.asset(Assets.icons.follow_link, height: 16)
              ],
            ),
          ),
        ),
      ],
    );
  }
}
