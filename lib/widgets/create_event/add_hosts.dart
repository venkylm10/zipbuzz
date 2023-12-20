import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/controllers/events/new_event_controller.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/user/user_model.dart';

class AddHosts extends ConsumerStatefulWidget {
  const AddHosts({super.key});

  @override
  ConsumerState<AddHosts> createState() => _AddHostsState();
}

class _AddHostsState extends ConsumerState<AddHosts> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final coHosts = ref.watch(newEventProvider.notifier).coHosts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hosts & Co-hosts",
          style: AppStyles.h5.copyWith(color: AppColors.lightGreyColor),
        ),
        const SizedBox(height: 16),
        buildHost(user, false),
        ListView.builder(
            itemCount: coHosts.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return buildHost(coHosts[index], true);
            }),

        // TODO: Add CO-Hosts
        // GestureDetector(
        //   onTap: showSnackBar,
        //   child: Container(
        //     height: 44,
        //     width: double.infinity,
        //     decoration: BoxDecoration(
        //       color: AppColors.bgGrey,
        //       borderRadius: BorderRadius.circular(12),
        //       border: Border.all(color: AppColors.borderGrey),
        //     ),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       crossAxisAlignment: CrossAxisAlignment.center,
        //       children: [
        //         SvgPicture.asset(Assets.icons.add_circle, height: 20),
        //         const SizedBox(width: 8),
        //         Text(
        //           "Add Co-host",
        //           style: AppStyles.h4.copyWith(
        //             color: AppColors.greyColor,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Padding buildHost(UserModel user, bool coHost) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: AppColors.greyColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: AppColors.greyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Image.network(
                  user.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            user.name,
            style: AppStyles.h5,
          ),
          const Expanded(child: SizedBox()),
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: !coHost
                  ? AppColors.primaryColor.withOpacity(0.1)
                  : AppColors.borderGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: !coHost
                  ? Text(
                      "Host",
                      style:
                          AppStyles.h4.copyWith(color: AppColors.primaryColor),
                    )
                  : Row(
                      children: [
                        Text(
                          "Co-Host",
                          style: AppStyles.h4,
                        ),
                        const SizedBox(width: 4),
                        SvgPicture.asset(
                          Assets.icons.remove,
                          colorFilter: const ColorFilter.mode(
                            AppColors.textColor,
                            BlendMode.srcIn,
                          ),
                        )
                      ],
                    ),
            ),
          )
        ],
      ),
    );
  }
}
