import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';

class UserStats extends ConsumerWidget {
  const UserStats({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.bgGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          SvgPicture.asset(Assets.icons.hosts, height: 40),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                user.eventsHosted.toString(),
                style: AppStyles.h3.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                "Events hosted",
                style: AppStyles.h6.copyWith(
                  color: AppColors.lightGreyColor,
                ),
              )
            ],
          ),
          const Expanded(child: SizedBox()),
          Container(
            height: 24,
            width: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.borderGrey,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(1),
              ),
            ),
          ),
          SvgPicture.asset(Assets.icons.rating, height: 40),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                user.rating.toString(),
                style: AppStyles.h3.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                "Host rating",
                style: AppStyles.h6.copyWith(
                  color: AppColors.lightGreyColor,
                ),
              )
            ],
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}